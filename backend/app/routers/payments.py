from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user
from ..services import services

router = APIRouter(prefix="/payments", tags=["payments"])

@router.post("", response_model=schemas.Payment, status_code=status.HTTP_201_CREATED)
async def record_payment(
    membershipId: str,
    payment_in: schemas.PaymentCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can record payments")
        
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membershipId,
        models.CustomerShopMembership.isDeleted == False
    ).first()
    if not membership:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    if membership.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    # Calculate balance before payment
    sessions = db.query(models.CreditSession).filter(
        models.CreditSession.membershipId == membershipId,
        models.CreditSession.status != "settled",
        models.CreditSession.status != "cancelled"
    ).all()
    
    balance_before = sum(s.remainingAmount for s in sessions)
    balance_after = max(0.0, balance_before - payment_in.amountPaid)
    
    # Create payment record
    new_payment = models.Payment(
        sessionId=payment_in.sessionId,
        membershipId=membership.id,
        shopId=membership.shopId,
        recordedBy=current_user.id,
        amountPaid=payment_in.amountPaid,
        paymentMethod=payment_in.paymentMethod,
        note=payment_in.note,
        balanceBefore=balance_before,
        balanceAfter=balance_after,
        paidAt=datetime.now(timezone.utc)
    )
    db.add(new_payment)
    db.commit()
    db.refresh(new_payment)
    
    # Recalculate sessions and update membership status using FIFO
    services.recalculate_account_balance(db, membership.id)
    db.refresh(membership)
    
    # Log Audit Transaction
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="CREATE",
        table_name="payments",
        record_id=new_payment.id,
        new_values={
            "membershipId": membership.id,
            "amountPaid": new_payment.amountPaid,
            "paymentMethod": new_payment.paymentMethod,
            "walletBalanceAfter": membership.walletBalance
        }
    )
    
    # Send notification to customer if linked
    if membership.customerId:
        services.add_notification(
            db,
            user_id=membership.customerId,
            title="Payment Recorded",
            message=f"Payment of {payment_in.amountPaid:.2f} ETB received by {membership.shop.name}. New balance: {balance_after:.2f} ETB.",
            notification_type="system",
            shop_id=membership.shopId
        )
        
    return new_payment

@router.get("", response_model=List[schemas.Payment])
async def list_payments(
    shopId: Optional[str] = None,
    membershipId: Optional[str] = None,
    fromDate: Optional[str] = None,
    toDate: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role == "CUSTOMER":
        # Customers can only list their own payments
        query = db.query(models.Payment).filter(
            models.Payment.membership.has(customerId=current_user.id, isDeleted=False)
        )
        if shopId:
            query = query.filter(models.Payment.shopId == shopId)
            
    elif current_user.role == "SHOP_OWNER":
        # Owners can list payments for their shops
        query = db.query(models.Payment).join(models.Shop).filter(
            models.Shop.ownerId == current_user.id,
            models.Payment.membership.has(isDeleted=False)
        )
        if shopId:
            query = query.filter(models.Payment.shopId == shopId)
        if membershipId:
            query = query.filter(models.Payment.membershipId == membershipId)
            
    else:
        raise HTTPException(status_code=403, detail="Unauthorized")
        
    # Date Filtering
    if fromDate:
        try:
            from_dt = datetime.fromisoformat(fromDate)
            query = query.filter(models.Payment.paidAt >= from_dt)
        except ValueError:
            pass
    if toDate:
        try:
            to_dt = datetime.fromisoformat(toDate)
            query = query.filter(models.Payment.paidAt <= to_dt)
        except ValueError:
            pass
            
    return query.order_by(models.Payment.paidAt.desc()).all()

@router.get("/{payment_id}", response_model=schemas.Payment)
async def get_payment(
    payment_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    payment = db.query(models.Payment).filter(models.Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment record not found")
        
    # Permission check
    if current_user.role == "CUSTOMER" and payment.membership.customerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role == "SHOP_OWNER" and payment.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    return payment
