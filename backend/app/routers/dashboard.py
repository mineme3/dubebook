from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/owner/{shop_id}", response_model=schemas.OwnerDashboard)
async def get_owner_dashboard(
    shop_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can view this dashboard")
        
    # Verify shop ownership
    shop = db.query(models.Shop).filter(models.Shop.id == shop_id, models.Shop.ownerId == current_user.id).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found or access denied")
        
    # 1. Total Customers
    total_customers = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.shopId == shop_id,
        models.CustomerShopMembership.isDeleted == False,
        models.CustomerShopMembership.status != "archived"
    ).count()
    
    # 2. Total Active Credits
    total_active_credits = db.query(models.CreditSession).filter(
        models.CreditSession.shopId == shop_id,
        models.CreditSession.status.in_(["active", "partially_paid"])
    ).count()
    
    # 3. Total Overdue Credits
    total_overdue_credits = db.query(models.CreditSession).filter(
        models.CreditSession.shopId == shop_id,
        models.CreditSession.status == "overdue"
    ).count()
    
    # 4. Monthly Collections (payments in current calendar month)
    now = datetime.utcnow()
    start_of_month = datetime(now.year, now.month, 1)
    payments = db.query(models.Payment).filter(
        models.Payment.shopId == shop_id,
        models.Payment.paidAt >= start_of_month
    ).all()
    monthly_collections = sum(p.amountPaid for p in payments)
    
    # 5. Outstanding Amount
    sessions = db.query(models.CreditSession).filter(
        models.CreditSession.shopId == shop_id,
        models.CreditSession.status.in_(["active", "partially_paid", "overdue"])
    ).all()
    outstanding_amount = sum(s.remainingAmount for s in sessions)
    
    return {
        "totalCustomers": total_customers,
        "totalActiveCredits": total_active_credits,
        "totalOverdueCredits": total_overdue_credits,
        "monthlyCollections": monthly_collections,
        "outstandingAmount": outstanding_amount
    }
