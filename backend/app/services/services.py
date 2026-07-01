import json
import random
import string
import re
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from ..models import models

def generate_invite_code() -> str:
    # 6 character uppercase alphanumeric code
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def generate_slug(name: str) -> str:
    # URL friendly slug generator
    name = name.lower().strip()
    name = re.sub(r'[^\w\s-]', '', name)
    name = re.sub(r'[\s_-]+', '-', name)
    return name

def link_memberships_to_customer(db: Session, customer_id: str, phone: str) -> int:
    """Links all existing memberships with this phone number to the new customer user ID."""
    memberships = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.phone == phone,
        models.CustomerShopMembership.customerId == None
    ).all()
    
    for membership in memberships:
        membership.customerId = customer_id
        membership.updatedAt = datetime.utcnow()
    
    db.commit()
    return len(memberships)

def recalculate_account_balance(db: Session, membership_id: str):
    """
    FIFO settlement logic with wallet (overpayment) support.
    
    1. Total up all non-cancelled session amounts
    2. Apply total payments via FIFO (oldest session first)
    3. If payments exceed total debt, store the overpayment as walletBalance
    4. NEVER set membership.status to 'settled' — customer stays visible on dashboard
    """
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id
    ).first()
    if not membership:
        return None

    # Get sessions and payments for this membership
    sessions = db.query(models.CreditSession).filter(
        models.CreditSession.membershipId == membership_id
    ).all()
    payments = db.query(models.Payment).filter(
        models.Payment.membershipId == membership_id
    ).all()

    total_debt = sum(s.totalAmount for s in sessions if s.status != "cancelled")
    total_paid = sum(p.amountPaid for p in payments)
    
    # FIFO settlement logic
    remaining_payment = total_paid
    sorted_sessions = sorted(
        [s for s in sessions if s.status != "cancelled"],
        key=lambda x: x.createdAt
    )
    
    for session in sorted_sessions:
        if remaining_payment >= session.totalAmount:
            session.paidAmount = session.totalAmount
            session.remainingAmount = 0.0
            session.status = "settled"
            remaining_payment -= session.totalAmount
        else:
            session.paidAmount = remaining_payment
            session.remainingAmount = session.totalAmount - remaining_payment
            remaining_payment = 0.0
            
            # Check for overdue
            now = datetime.utcnow()
            if session.deadline and session.deadline < now:
                session.status = "overdue"
            elif session.paidAmount > 0:
                session.status = "partially_paid"
            else:
                session.status = "active"

    # Store overpayment as wallet balance
    membership.walletBalance = max(0.0, remaining_payment)
    
    outstanding = max(0.0, total_debt - total_paid)

    # IMPORTANT: Never set status to "settled" — customer must always remain
    # visible on the shop owner's dashboard. Only "archived" hides them (manual action).
    if any(s.status == "overdue" for s in sorted_sessions):
        membership.status = "overdue" if membership.status != "archived" else "archived"
    elif membership.status != "archived":
        membership.status = "active"

    membership.updatedAt = datetime.utcnow()
    db.commit()
    db.refresh(membership)
    return membership

def apply_wallet_to_session(db: Session, membership_id: str, session: models.CreditSession):
    """
    When a new credit session is created with items, auto-deduct from wallet balance.
    
    Example: wallet has 35 ETB, new item costs 50 ETB
    → wallet becomes 0, session.remainingAmount = 15 ETB (recorded as credit)
    """
    membership = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.id == membership_id
    ).first()
    if not membership or membership.walletBalance <= 0:
        return
    
    deduction = min(membership.walletBalance, session.totalAmount)
    membership.walletBalance -= deduction
    session.paidAmount += deduction
    session.remainingAmount = session.totalAmount - session.paidAmount
    
    if session.remainingAmount <= 0:
        session.remainingAmount = 0.0
        session.status = "settled"
    
    membership.updatedAt = datetime.utcnow()
    db.commit()

def add_notification(db: Session, user_id: str, title: str, message: str, notification_type: str, shop_id: str = None, session_id: str = None):
    notification = models.Notification(
        userId=user_id,
        shopId=shop_id,
        sessionId=session_id,
        title=title,
        message=message,
        type=notification_type,
        isRead=False
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification

def log_audit(db: Session, user_id: str, action: str, table_name: str,
              record_id: str = None, old_values: dict = None, new_values: dict = None):
    """Record an audit log entry for any database mutation."""
    log = models.AuditLog(
        userId=user_id,
        action=action,
        tableName=table_name,
        recordId=record_id,
        oldValues=json.dumps(old_values) if old_values else None,
        newValues=json.dumps(new_values) if new_values else None,
    )
    db.add(log)
    db.commit()
    return log
