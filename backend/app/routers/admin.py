from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user
from ..services import services

router = APIRouter(prefix="/admin", tags=["admin"])

def require_admin(current_user: models.User = Depends(get_current_user)):
    if current_user.role != "PLATFORM_ADMIN":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Platform admin privileges required"
        )
    return current_user

@router.get("/statistics")
async def get_admin_statistics(
    db: Session = Depends(get_db),
    admin: models.User = Depends(require_admin)
):
    total_users = db.query(models.User).count()
    owners_count = db.query(models.User).filter(models.User.role == "SHOP_OWNER").count()
    customers_count = db.query(models.User).filter(models.User.role == "CUSTOMER").count()
    
    total_shops = db.query(models.Shop).count()
    total_memberships = db.query(models.CustomerShopMembership).count()
    active_memberships = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.isDeleted == False
    ).count()
    deleted_memberships = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.isDeleted == True
    ).count()
    
    sessions = db.query(models.CreditSession).all()
    total_credit_volume = sum(s.totalAmount for s in sessions if s.status != "cancelled")
    outstanding_credit = sum(s.remainingAmount for s in sessions if s.status != "cancelled")
    
    payments = db.query(models.Payment).all()
    total_payments_collected = sum(p.amountPaid for p in payments)
    
    return {
        "users": {
            "total": total_users,
            "shopOwners": owners_count,
            "customers": customers_count
        },
        "shops": {
            "total": total_shops,
            "totalMemberships": total_memberships,
            "activeMemberships": active_memberships,
            "deletedMemberships": deleted_memberships
        },
        "financials": {
            "totalCreditVolume": total_credit_volume,
            "outstandingCredit": outstanding_credit,
            "totalPaymentsCollected": total_payments_collected
        }
    }

@router.get("/users", response_model=List[schemas.User])
async def list_all_users(
    db: Session = Depends(get_db),
    admin: models.User = Depends(require_admin)
):
    return db.query(models.User).all()

@router.get("/shops", response_model=List[schemas.Shop])
async def list_all_shops(
    db: Session = Depends(get_db),
    admin: models.User = Depends(require_admin)
):
    return db.query(models.Shop).all()

@router.get("/customers", response_model=List[schemas.CustomerShopMembership])
async def list_all_customers_including_deleted(
    db: Session = Depends(get_db),
    admin: models.User = Depends(require_admin)
):
    # Returns all memberships, even soft-deleted ones
    return db.query(models.CustomerShopMembership).all()

@router.get("/audit-log", response_model=List[schemas.AuditLog])
async def list_audit_logs(
    db: Session = Depends(get_db),
    admin: models.User = Depends(require_admin)
):
    return db.query(models.AuditLog).order_by(models.AuditLog.createdAt.desc()).limit(100).all()

@router.delete("/customers/{membership_id}/permanent", status_code=status.HTTP_204_NO_CONTENT)
async def permanently_delete_customer(
    membership_id: str,
    db: Session = Depends(get_db),
    admin: models.User = Depends(require_admin)
):
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id
    ).first()
    if not membership:
        raise HTTPException(status_code=404, detail="Customer membership not found")
        
    services.log_audit(
        db=db,
        user_id=admin.id,
        action="PERMANENT_DELETE",
        table_name="customer_shop_memberships",
        record_id=membership.id,
        old_values={"displayName": membership.displayName, "phone": membership.phone}
    )
    
    db.delete(membership)
    db.commit()
    return None
