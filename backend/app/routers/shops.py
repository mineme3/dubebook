from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import get_current_user
from ..services import services

router = APIRouter(prefix="/shops", tags=["shops"])

@router.post("", response_model=schemas.Shop, status_code=status.HTTP_201_CREATED)
async def create_shop(
    shop_in: schemas.ShopCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only shop owners can create shops"
        )
        
    shop_slug = services.generate_slug(shop_in.name)
    # Ensure unique slug
    count = 1
    original_slug = shop_slug
    while db.query(models.Shop).filter(models.Shop.slug == shop_slug).first():
        shop_slug = f"{original_slug}-{count}"
        count += 1
        
    invite_code = services.generate_invite_code()
    while db.query(models.Shop).filter(models.Shop.inviteCode == invite_code).first():
        invite_code = services.generate_invite_code()

    new_shop = models.Shop(
        ownerId=current_user.id,
        name=shop_in.name,
        slug=shop_slug,
        businessType=shop_in.businessType,
        phone=shop_in.phone,
        email=shop_in.email,
        address=shop_in.address,
        logoUrl=shop_in.logoUrl,
        currency=shop_in.currency,
        timezone=shop_in.timezone,
        inviteCode=invite_code
    )
    db.add(new_shop)
    db.commit()
    db.refresh(new_shop)
    return new_shop

@router.get("", response_model=List[schemas.Shop])
async def list_my_shops(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only shop owners can list their shops"
        )
    return db.query(models.Shop).filter(models.Shop.ownerId == current_user.id, models.Shop.isActive == True).all()

@router.get("/my-shops", response_model=List[schemas.Shop])
async def customer_joined_shops(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "CUSTOMER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only customers can view joined shops"
        )
    memberships = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.customerId == current_user.id,
        models.CustomerShopMembership.isDeleted == False,
        models.CustomerShopMembership.status != "archived"
    ).all()
    
    return [m.shop for m in memberships]

@router.post("/join", response_model=schemas.CustomerShopMembership)
async def join_shop_via_invite(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "CUSTOMER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only customers can join shops"
        )
        
    invite_code = payload.get("inviteCode")
    if not invite_code:
        raise HTTPException(status_code=400, detail="Invite code is required")
        
    shop = db.query(models.Shop).filter(models.Shop.inviteCode == invite_code.strip().upper()).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Invalid invite code")
        
    # Check if already a member
    existing = db.query(models.CustomerShopMembership).filter(
        models.CustomerShopMembership.customerId == current_user.id,
        models.CustomerShopMembership.shopId == shop.id
    ).first()
    if existing:
        if existing.status != "archived" and not existing.isDeleted:
            return existing
        existing.status = "active"
        existing.isDeleted = False
        existing.updatedAt = datetime.utcnow()
        db.commit()
        db.refresh(existing)
        return existing
        
    # Create new membership
    new_membership = models.CustomerShopMembership(
        customerId=current_user.id,
        shopId=shop.id,
        displayName=current_user.fullName,
        phone=current_user.phone,
        status="active"
    )
    db.add(new_membership)
    db.commit()
    db.refresh(new_membership)
    
    # Notify shop owner
    services.add_notification(
        db,
        user_id=shop.ownerId,
        title="Customer Joined",
        message=f"{current_user.fullName} joined your shop {shop.name}.",
        notification_type="system",
        shop_id=shop.id
    )
    
    return new_membership

@router.post("/{shop_id}/regenerate-invite", response_model=schemas.Shop)
async def regenerate_invite_code(
    shop_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    shop = db.query(models.Shop).filter(models.Shop.id == shop_id, models.Shop.ownerId == current_user.id).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found or access denied")
        
    invite_code = services.generate_invite_code()
    while db.query(models.Shop).filter(models.Shop.inviteCode == invite_code).first():
        invite_code = services.generate_invite_code()
        
    shop.inviteCode = invite_code
    shop.updatedAt = datetime.utcnow()
    db.commit()
    db.refresh(shop)
    return shop

@router.put("/{shop_id}", response_model=schemas.Shop)
async def update_shop(
    shop_id: str,
    shop_in: schemas.ShopCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role != "SHOP_OWNER":
        raise HTTPException(status_code=403, detail="Only shop owners can update shop details")
        
    shop = db.query(models.Shop).filter(
        models.Shop.id == shop_id,
        models.Shop.ownerId == current_user.id
    ).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found or access denied")
        
    shop.name = shop_in.name
    shop.businessType = shop_in.businessType
    shop.phone = shop_in.phone
    shop.email = shop_in.email
    shop.address = shop_in.address
    shop.logoUrl = shop_in.logoUrl
    if shop_in.currency:
        shop.currency = shop_in.currency
    if shop_in.timezone:
        shop.timezone = shop_in.timezone
        
    shop.updatedAt = datetime.utcnow()
    db.commit()
    db.refresh(shop)
    return shop
