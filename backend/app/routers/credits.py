from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user
from ..services import services

router = APIRouter(prefix="/credits", tags=["credits"])

@router.post("", response_model=schemas.CreditSession, status_code=status.HTTP_201_CREATED)
async def create_credit_session(
    membershipId: str,
    session_in: schemas.CreditSessionCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can create credit sessions")
        
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membershipId,
        models.CustomerShopMembership.isDeleted == False
    ).first()
    if not membership:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    if membership.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied to this shop")
        
    # Create the session first
    new_session = models.CreditSession(
        membershipId=membership.id,
        shopId=membership.shopId,
        createdBy=current_user.id,
        deadline=session_in.deadline,
        notes=session_in.notes,
        totalAmount=0.0,
        paidAmount=0.0,
        remainingAmount=0.0,
        status="active"
    )
    db.add(new_session)
    db.commit()
    db.refresh(new_session)
    
    # Create items if provided
    total_amount = 0.0
    if session_in.items:
        for idx, item in enumerate(session_in.items):
            item_total = item.quantity * item.unitPrice
            total_amount += item_total
            # Ensure unique high-precision timestamp per item
            db_item = models.CreditItem(
                sessionId=new_session.id,
                itemName=item.itemName,
                unitType=item.unitType,
                quantity=item.quantity,
                unitPrice=item.unitPrice,
                totalPrice=item_total,
                createdByUserId=current_user.id,
                createdAt=datetime.now(timezone.utc)
            )
            db.add(db_item)
            
        new_session.totalAmount = total_amount
        new_session.remainingAmount = total_amount
        db.commit()
        db.refresh(new_session)
        
        # Apply any wallet balance before running recalculation
        services.apply_wallet_to_session(db, membership.id, new_session)
        
        # Run FIFO balance recalculation
        services.recalculate_account_balance(db, membership.id)
        db.refresh(new_session)
        
        # Log Audit Transaction
        services.log_audit(
            db=db,
            user_id=current_user.id,
            action="CREATE",
            table_name="credit_sessions",
            record_id=new_session.id,
            new_values={
                "membershipId": membership.id,
                "totalAmount": new_session.totalAmount,
                "remainingAmount": new_session.remainingAmount,
                "walletApplied": total_amount - new_session.remainingAmount
            }
        )
        
        # Send notification to customer if linked
        if membership.customerId:
            services.add_notification(
                db,
                user_id=membership.customerId,
                title="New Credit Session",
                message=f"New credit of {total_amount:.2f} ETB recorded at {membership.shop.name}.",
                notification_type="system",
                shop_id=membership.shopId,
                session_id=new_session.id
            )
            
    return new_session

@router.get("/{session_id}", response_model=schemas.CreditSession)
async def get_credit_session(
    session_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    session = db.query(models.CreditSession).filter(models.CreditSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Credit session not found")
        
    # Permission check
    if current_user.role == "CUSTOMER" and session.membership.customerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role == "SHOP_OWNER" and session.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    return session

@router.patch("/{session_id}", response_model=schemas.CreditSession)
async def update_credit_session(
    session_id: str,
    session_update: schemas.CreditSessionBase,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can update credit sessions")
        
    session = db.query(models.CreditSession).filter(models.CreditSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Credit session not found")
        
    if session.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    old_values = {
        "deadline": session.deadline.isoformat() if session.deadline else None,
        "notes": session.notes
    }
    
    if session_update.deadline is not None:
        session.deadline = session_update.deadline
    if session_update.notes is not None:
        session.notes = session_update.notes
        
    session.updatedAt = datetime.now(timezone.utc)
    db.commit()
    db.refresh(session)
    
    # Recalculate to update overdue status if deadline changed
    services.recalculate_account_balance(db, session.membershipId)
    db.refresh(session)
    
    # Log Audit Transaction
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="UPDATE",
        table_name="credit_sessions",
        record_id=session.id,
        old_values=old_values,
        new_values={
            "deadline": session.deadline.isoformat() if session.deadline else None,
            "notes": session.notes
        }
    )
    
    return session

@router.delete("/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def cancel_credit_session(
    session_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can cancel credit sessions")
        
    session = db.query(models.CreditSession).filter(models.CreditSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Credit session not found")
        
    if session.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    session.status = "cancelled"
    session.updatedAt = datetime.now(timezone.utc)
    db.commit()
    
    # Recalculate to refund payments that were allocated to this session
    services.recalculate_account_balance(db, session.membershipId)
    
    # Log Audit Transaction
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="DELETE_SOFT",
        table_name="credit_sessions",
        record_id=session.id,
        old_values={"status": "active"},
        new_values={"status": "cancelled"}
    )
    
    return None

@router.post("/{session_id}/items", response_model=schemas.CreditItem, status_code=status.HTTP_201_CREATED)
async def add_item_to_session(
    session_id: str,
    item_in: schemas.CreditItemCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can add items to sessions")
        
    session = db.query(models.CreditSession).filter(models.CreditSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Credit session not found")
        
    if session.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    item_total = item_in.quantity * item_in.unitPrice
    new_item = models.CreditItem(
        sessionId=session.id,
        itemName=item_in.itemName,
        unitType=item_in.unitType,
        quantity=item_in.quantity,
        unitPrice=item_in.unitPrice,
        totalPrice=item_total,
        createdByUserId=current_user.id,
        createdAt=datetime.now(timezone.utc)
    )
    db.add(new_item)
    
    session.totalAmount += item_total
    session.remainingAmount += item_total
    db.commit()
    db.refresh(new_item)
    
    # Apply wallet balance before recalculation
    services.apply_wallet_to_session(db, session.membershipId, session)
    
    # Run FIFO balance recalculation
    services.recalculate_account_balance(db, session.membershipId)
    
    # Log Audit Transaction
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="CREATE",
        table_name="credit_items",
        record_id=new_item.id,
        new_values={
            "sessionId": session.id,
            "itemName": new_item.itemName,
            "totalPrice": new_item.totalPrice
        }
    )
    
    # Send notification if customer linked
    if session.membership.customerId:
        services.add_notification(
            db,
            user_id=session.membership.customerId,
            title="Credit Item Added",
            message=f"Added item '{item_in.itemName}' ({item_total:.2f} ETB) to credit session at {session.shop.name}.",
            notification_type="system",
            shop_id=session.shopId,
            session_id=session.id
        )
        
    return new_item

@router.patch("/{session_id}/items/{item_id}", response_model=schemas.CreditItem)
async def update_item_in_session(
    session_id: str,
    item_id: str,
    item_in: schemas.CreditItemCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can update items")
        
    session = db.query(models.CreditSession).filter(models.CreditSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Credit session not found")
        
    if session.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    item = db.query(models.CreditItem).filter(
        models.CreditItem.id == item_id,
        models.CreditItem.sessionId == session_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Credit item not found")
        
    old_values = {
        "itemName": item.itemName,
        "quantity": item.quantity,
        "unitPrice": item.unitPrice,
        "totalPrice": item.totalPrice
    }
    
    old_total_price = item.totalPrice
    new_total_price = item_in.quantity * item_in.unitPrice
    price_difference = new_total_price - old_total_price
    
    item.itemName = item_in.itemName
    item.unitType = item_in.unitType
    item.quantity = item_in.quantity
    item.unitPrice = item_in.unitPrice
    item.totalPrice = new_total_price
    item.updatedAt = datetime.now(timezone.utc)
    
    session.totalAmount += price_difference
    session.remainingAmount += price_difference
    
    db.commit()
    db.refresh(item)
    
    # Run FIFO balance recalculation
    services.recalculate_account_balance(db, session.membershipId)
    
    # Log Audit Transaction
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="UPDATE",
        table_name="credit_items",
        record_id=item.id,
        old_values=old_values,
        new_values={
            "itemName": item.itemName,
            "quantity": item.quantity,
            "unitPrice": item.unitPrice,
            "totalPrice": item.totalPrice
        }
    )
    
    return item

@router.delete("/{session_id}/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item_from_session(
    session_id: str,
    item_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can delete items")
        
    session = db.query(models.CreditSession).filter(models.CreditSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Credit session not found")
        
    if session.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    item = db.query(models.CreditItem).filter(
        models.CreditItem.id == item_id,
        models.CreditItem.sessionId == session_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Credit item not found")
        
    item_price = item.totalPrice
    
    # Log Audit Transaction before deletion
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="DELETE",
        table_name="credit_items",
        record_id=item.id,
        old_values={
            "itemName": item.itemName,
            "totalPrice": item.totalPrice
        }
    )
    
    db.delete(item)
    session.totalAmount -= item_price
    session.remainingAmount -= item_price
    
    db.commit()
    
    # Run FIFO balance recalculation
    services.recalculate_account_balance(db, session.membershipId)
    
    return None
