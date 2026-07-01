from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from ..database import get_db
from ..models import models
from ..schemas import schemas
from ..auth import (
    create_access_token, 
    create_refresh_token, 
    verify_refresh_token, 
    revoke_refresh_token,
    get_password_hash, 
    verify_password,
    get_current_user
)
from ..services import services

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=schemas.Token, status_code=status.HTTP_201_CREATED)
async def register(user_in: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check duplicate
    db_user = db.query(models.User).filter(
        (models.User.email == user_in.email) | 
        (models.User.phone == user_in.phone) | 
        (models.User.username == user_in.username)
    ).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User with this email, phone, or username already exists"
        )
    
    # Validation for owner's shopName
    if user_in.role == "SHOP_OWNER" and not user_in.shopName:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Shop name is required for shop owner registration"
        )

    hashed_password = get_password_hash(user_in.password)
    new_user = models.User(
        username=user_in.username,
        fullName=user_in.fullName,
        phone=user_in.phone,
        email=user_in.email,
        passwordHash=hashed_password,
        role=user_in.role
    )
    
    try:
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        
        # Auto-create shop if owner
        if new_user.role == "SHOP_OWNER":
            shop_slug = services.generate_slug(user_in.shopName)
            # Make sure slug is unique
            count = 1
            original_slug = shop_slug
            while db.query(models.Shop).filter(models.Shop.slug == shop_slug).first():
                shop_slug = f"{original_slug}-{count}"
                count += 1
                
            invite_code = services.generate_invite_code()
            while db.query(models.Shop).filter(models.Shop.inviteCode == invite_code).first():
                invite_code = services.generate_invite_code()

            new_shop = models.Shop(
                ownerId=new_user.id,
                name=user_in.shopName,
                slug=shop_slug,
                businessType=user_in.businessType or "supermarket",
                inviteCode=invite_code
            )
            db.add(new_shop)
            db.commit()
            db.refresh(new_shop)
            
        # Link existing memberships if this is a CUSTOMER registering
        elif new_user.role == "CUSTOMER":
            services.link_memberships_to_customer(db, new_user.id, new_user.phone)
            
    except IntegrityError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Database integrity error: {str(e.orig) if hasattr(e, 'orig') else str(e)}"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An unexpected error occurred: {str(e)}"
        )
    
    access_token = create_access_token(data={"sub": new_user.id})
    refresh_token = create_refresh_token(db, new_user.id)
    return {
        "token": access_token, 
        "refreshToken": refresh_token,
        "user": new_user
    }

@router.post("/login", response_model=schemas.Token)
async def login(form_data: schemas.UserLogin, db: Session = Depends(get_db)):
    # Look up by email or username
    user = db.query(models.User).filter(
        (models.User.email == form_data.email) | (models.User.username == form_data.username)
    ).first()
    
    if not user or not verify_password(form_data.password, user.passwordHash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.isActive:
        raise HTTPException(status_code=400, detail="Account is deactivated")

    access_token = create_access_token(data={"sub": user.id})
    refresh_token = create_refresh_token(db, user.id)
    return {
        "token": access_token, 
        "refreshToken": refresh_token,
        "user": user
    }

@router.post("/refresh", response_model=dict)
async def refresh(token_data: dict, db: Session = Depends(get_db)):
    ref_token = token_data.get("refreshToken")
    if not ref_token:
        raise HTTPException(status_code=400, detail="Missing refresh token")
    
    user = verify_refresh_token(db, ref_token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")
        
    new_access_token = create_access_token(data={"sub": user.id})
    return {"token": new_access_token}

@router.post("/logout")
async def logout(token_data: dict, db: Session = Depends(get_db)):
    ref_token = token_data.get("refreshToken")
    if ref_token:
        revoke_refresh_token(db, ref_token)
    return {"success": True, "message": "Successfully logged out"}

@router.patch("/profile", response_model=schemas.User)
async def update_profile(
    profile_in: schemas.UserProfileUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    if profile_in.fullName is not None:
        current_user.fullName = profile_in.fullName
    if profile_in.phone is not None:
        if profile_in.phone != current_user.phone:
            existing = db.query(models.User).filter(models.User.phone == profile_in.phone).first()
            if existing:
                raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already in use")
            current_user.phone = profile_in.phone
    if profile_in.email is not None:
        if profile_in.email != current_user.email:
            existing = db.query(models.User).filter(models.User.email == profile_in.email).first()
            if existing:
                raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already in use")
            current_user.email = profile_in.email
    
    current_user.updatedAt = datetime.utcnow()
    db.commit()
    db.refresh(current_user)
    return current_user
