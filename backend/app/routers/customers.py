from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user
from ..services import services

router = APIRouter(prefix="/customers", tags=["customers"])

@router.get("", response_model=List[schemas.CustomerShopMembership])
async def list_customers(
    shopId: Optional[str] = None,
    includeArchived: bool = False,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role == "CUSTOMER":
        # Customers only see their own active, non-deleted memberships
        return db.query(models.CustomerShopMembership).filter(
            models.CustomerShopMembership.customerId == current_user.id,
            models.CustomerShopMembership.isDeleted == False,
            models.CustomerShopMembership.status != "archived"
        ).all()
        
    elif current_user.role == "SHOP_OWNER":
        # Owners see memberships of their shops
        query = db.query(models.CustomerShopMembership).join(models.Shop).filter(
            models.Shop.ownerId == current_user.id,
            models.CustomerShopMembership.isDeleted == False
        )
        if not includeArchived:
            query = query.filter(models.CustomerShopMembership.status != "archived")
        if shopId:
            query = query.filter(models.CustomerShopMembership.shopId == shopId)
        return query.all()
        
    raise HTTPException(status_code=403, detail="Unauthorized role")

@router.post("", response_model=schemas.CustomerShopMembership, status_code=status.HTTP_201_CREATED)
async def create_customer(
    customer_in: schemas.CustomerShopMembershipCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can add customers")
        
    # Verify shop ownership
    shop = db.query(models.Shop).filter(
        models.Shop.id == customer_in.shopId,
        models.Shop.ownerId == current_user.id
    ).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found or access denied")
        
    # Find customer user by username
    linked_user = db.query(models.User).filter(
        models.User.username == customer_in.username,
        models.User.role == "CUSTOMER"
    ).first()
    if not linked_user:
        raise HTTPException(status_code=404, detail="Customer username not found")

    # Check if membership already exists in this shop
    existing = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.customerId == linked_user.id,
        models.CustomerShopMembership.shopId == customer_in.shopId
    ).first()

    display_name = linked_user.fullName or linked_user.username
    phone_number = linked_user.phone or ""

    if existing:
        # If deleted/archived, reactivate
        if existing.isDeleted or existing.status == "archived":
            existing.isDeleted = False
            existing.status = "active"
            existing.approvalStatus = "pending"  # Owner registers, needs approval
            existing.displayName = display_name
            existing.phone = phone_number
            existing.updatedAt = datetime.now(timezone.utc)
            db.commit()
            db.refresh(existing)
            
            # Log Audit
            services.log_audit(
                db=db,
                user_id=current_user.id,
                action="UPDATE",
                table_name="customer_shop_memberships",
                record_id=existing.id,
                new_values={"isDeleted": False, "status": "active", "approvalStatus": "pending"}
            )
            return existing
            
        raise HTTPException(status_code=400, detail="Customer already registered in this shop")

    # Created by owner -> status is pending customer approval
    new_membership = models.CustomerShopMembership(
        customerId=linked_user.id,
        shopId=customer_in.shopId,
        displayName=display_name,
        phone=phone_number,
        address="",
        notes="",
        status="active",
        approvalStatus="pending"
    )
    db.add(new_membership)
    db.commit()
    db.refresh(new_membership)
    
    # Log Audit
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="CREATE",
        table_name="customer_shop_memberships",
        record_id=new_membership.id,
        new_values={"customerId": linked_user.id, "shopId": customer_in.shopId, "approvalStatus": "pending"}
    )
    
    # Notify customer to approve membership
    services.add_notification(
        db,
        user_id=linked_user.id,
        title="Pending Shop Registration",
        message=f"{shop.name} wants to register you as a customer. Please approve this request.",
        notification_type="system",
        shop_id=shop.id
    )
    
    return new_membership

@router.get("/my-dashboard", response_model=schemas.CustomerDashboard)
async def get_my_dashboard(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "CUSTOMER":
        raise HTTPException(status_code=403, detail="Only customers can view the customer portal")
        
    memberships = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.customerId == current_user.id,
        models.CustomerShopMembership.isDeleted == False,
        models.CustomerShopMembership.status != "archived",
        models.CustomerShopMembership.approvalStatus == "approved"
    ).all()
    
    total_debt = 0.0
    for membership in memberships:
        # Calculate remaining amount across all credit sessions
        sessions = db.query(models.CreditSession).filter(
            models.CreditSession.membershipId == membership.id,
            models.CreditSession.status != "settled",
            models.CreditSession.status != "cancelled"
        ).all()
        total_debt += sum(s.remainingAmount for s in sessions)
        
    return {
        "totalAggregateDebt": total_debt,
        "linkedAccounts": memberships
    }

@router.get("/{membership_id}", response_model=schemas.CustomerShopMembership)
async def get_customer(
    membership_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id
    ).first()
    if not membership or membership.isDeleted:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    # Permission check
    if current_user.role == "CUSTOMER" and membership.customerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role == "SHOP_OWNER" and membership.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    return membership

@router.get("/{membership_id}/summary", response_model=schemas.CreditAccountSummary)
async def get_customer_summary(
    membership_id: str,
    fromDate: Optional[str] = None,
    toDate: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id
    ).first()
    if not membership or membership.isDeleted:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    # Permission check
    if current_user.role == "CUSTOMER" and membership.customerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role == "SHOP_OWNER" and membership.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    sessions_query = db.query(models.CreditSession).filter(
        models.CreditSession.membershipId == membership_id
    )
    payments_query = db.query(models.Payment).filter(
        models.Payment.membershipId == membership_id
    )
    
    # Optional Date Filtering
    if fromDate:
        try:
            from_dt = datetime.fromisoformat(fromDate)
            sessions_query = sessions_query.filter(models.CreditSession.createdAt >= from_dt)
            payments_query = payments_query.filter(models.Payment.paidAt >= from_dt)
        except ValueError:
            pass
            
    if toDate:
        try:
            to_dt = datetime.fromisoformat(toDate)
            sessions_query = sessions_query.filter(models.CreditSession.createdAt <= to_dt)
            payments_query = payments_query.filter(models.Payment.paidAt <= to_dt)
        except ValueError:
            pass

    sessions = sessions_query.order_by(models.CreditSession.createdAt.desc()).all()
    payments = payments_query.order_by(models.Payment.paidAt.desc()).all()
    
    return {
        "account": membership,
        "sessions": sessions,
        "paymentHistory": payments
    }

@router.patch("/{membership_id}", response_model=schemas.CustomerShopMembership)
async def update_customer(
    membership_id: str,
    customer_in: schemas.CustomerShopMembershipBase,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can edit customers")
        
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id,
        models.CustomerShopMembership.isDeleted == False
    ).first()
    if not membership:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    if membership.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    old_values = {
        "displayName": membership.displayName,
        "phone": membership.phone,
        "address": membership.address,
        "notes": membership.notes
    }
    
    membership.displayName = customer_in.displayName
    membership.phone = customer_in.phone
    membership.address = customer_in.address
    membership.notes = customer_in.notes
    membership.updatedAt = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(membership)
    
    # Log Audit
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="UPDATE",
        table_name="customer_shop_memberships",
        record_id=membership.id,
        old_values=old_values,
        new_values={
            "displayName": membership.displayName,
            "phone": membership.phone,
            "address": membership.address,
            "notes": membership.notes
        }
    )
    
    return membership

@router.delete("/{membership_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_customer(
    membership_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can delete customers")
        
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id,
        models.CustomerShopMembership.isDeleted == False
    ).first()
    if not membership:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    if membership.shop.ownerId != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
        
    # Soft delete
    membership.isDeleted = True
    membership.deletedAt = datetime.now(timezone.utc)
    membership.deletedBy = current_user.id
    membership.status = "archived"
    membership.updatedAt = datetime.now(timezone.utc)
    db.commit()
    
    # Log Audit
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="DELETE_SOFT",
        table_name="customer_shop_memberships",
        record_id=membership.id,
        old_values={"isDeleted": False},
        new_values={"isDeleted": True, "status": "archived"}
    )
    
    return None

@router.patch("/{membership_id}/approve", response_model=schemas.CustomerShopMembership)
async def approve_customer_membership(
    membership_id: str,
    approve: bool = True,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "CUSTOMER":
        raise HTTPException(status_code=403, detail="Only customers can approve registrations")
        
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id,
        models.CustomerShopMembership.customerId == current_user.id,
        models.CustomerShopMembership.isDeleted == False
    ).first()
    
    if not membership:
        raise HTTPException(status_code=404, detail="Membership invitation not found")
        
    old_status = membership.approvalStatus
    membership.approvalStatus = "approved" if approve else "rejected"
    membership.updatedAt = datetime.now(timezone.utc)
    db.commit()
    db.refresh(membership)
    
    # Log Audit
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="UPDATE",
        table_name="customer_shop_memberships",
        record_id=membership.id,
        old_values={"approvalStatus": old_status},
        new_values={"approvalStatus": membership.approvalStatus}
    )
    
    # Notify shop owner
    services.add_notification(
        db,
        user_id=membership.shop.ownerId,
        title="Membership Approved" if approve else "Membership Rejected",
        message=f"{current_user.fullName} has {'approved' if approve else 'rejected'} your customer registration request for {membership.shop.name}.",
        notification_type="system",
        shop_id=membership.shopId
    )
    
    return membership

@router.post("/{membership_id}/dispute")
async def create_dispute(
    membership_id: str,
    dispute: schemas.DisputeCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "CUSTOMER":
        raise HTTPException(status_code=403, detail="Only customers can raise disputes")
        
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id,
        models.CustomerShopMembership.customerId == current_user.id,
        models.CustomerShopMembership.isDeleted == False
    ).first()
    
    if not membership:
        raise HTTPException(status_code=404, detail="Membership not found")
        
    # Send notification to the shop owner
    services.add_notification(
        db,
        user_id=membership.shop.ownerId,
        title="Customer Dispute Raised",
        message=f"Customer {current_user.fullName} raised a dispute: {dispute.message}",
        notification_type="system",
        shop_id=membership.shopId,
        session_id=dispute.sessionId
    )
    
    # Log Audit
    services.log_audit(
        db=db,
        user_id=current_user.id,
        action="CREATE_DISPUTE",
        table_name="notifications",
        new_values={
            "membershipId": membership_id,
            "sessionId": dispute.sessionId,
            "message": dispute.message
        }
    )
    
    return {"success": True, "message": "Dispute sent to the shop owner."}
