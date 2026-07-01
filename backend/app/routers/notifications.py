from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user
from ..services import services

router = APIRouter(prefix="/notifications", tags=["notifications"])

@router.get("", response_model=List[schemas.Notification])
async def get_my_notifications(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return db.query(models.Notification).filter(
        models.Notification.userId == current_user.id
    ).order_by(models.Notification.createdAt.desc()).all()

@router.patch("/{id}/read", response_model=schemas.Notification)
async def mark_notification_as_read(
    id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    notification = db.query(models.Notification).filter(
        models.Notification.id == id,
        models.Notification.userId == current_user.id
    ).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
        
    notification.isRead = True
    db.commit()
    db.refresh(notification)
    return notification

@router.post("/mark-all-read")
async def mark_all_notifications_as_read(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    notifications = db.query(models.Notification).filter(
        models.Notification.userId == current_user.id,
        models.Notification.isRead == False
    ).all()
    
    for notification in notifications:
        notification.isRead = True
        
    db.commit()
    return {"success": True, "count": len(notifications)}

@router.delete("/clear-read")
async def clear_read_notifications(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    db.query(models.Notification).filter(
        models.Notification.userId == current_user.id,
        models.Notification.isRead == True
    ).delete(synchronize_session=False)
    db.commit()
    return {"success": True, "message": "All read notifications cleared"}

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_notification(
    id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    notification = db.query(models.Notification).filter(
        models.Notification.id == id,
        models.Notification.userId == current_user.id
    ).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    db.delete(notification)
    db.commit()
    return None

@router.post("/send-deadline")
async def run_daily_deadline_check(
    db: Session = Depends(get_db),
):
    now = datetime.utcnow()
    overdue_sessions = db.query(models.CreditSession).filter(
        models.CreditSession.deadline != None,
        models.CreditSession.deadline < now,
        models.CreditSession.remainingAmount > 0,
        models.CreditSession.status != "overdue",
        models.CreditSession.status != "cancelled",
        models.CreditSession.status != "settled"
    ).all()
    
    for session in overdue_sessions:
        session.status = "overdue"
        session.updatedAt = now
        
        # Recalculate membership balance
        services.recalculate_account_balance(db, session.membershipId)
        
        # Notify shop owner
        services.add_notification(
            db,
            user_id=session.shop.ownerId,
            title="Overdue Credit",
            message=f"Credit session of {session.totalAmount:.2f} ETB for {session.membership.displayName} is now overdue.",
            notification_type="deadline_reached",
            shop_id=session.shopId,
            session_id=session.id
        )
        
        # Notify customer if linked
        if session.membership.customerId:
            services.add_notification(
                db,
                user_id=session.membership.customerId,
                title="Overdue Credit",
                message=f"Your credit session of {session.totalAmount:.2f} ETB at {session.shop.name} is overdue.",
                notification_type="deadline_reached",
                shop_id=session.shopId,
                session_id=session.id
            )
            
    db.commit()
    return {"success": True, "message": f"Daily deadline check completed. {len(overdue_sessions)} sessions updated."}
