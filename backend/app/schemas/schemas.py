from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# ==================== USER & AUTH ====================

class UserBase(BaseModel):
    username: str
    fullName: str
    phone: str
    email: EmailStr
    role: str = "SHOP_OWNER" # PLATFORM_ADMIN, SHOP_OWNER, CUSTOMER
    profilePhotoUrl: Optional[str] = None
    isActive: bool = True

class UserCreate(UserBase):
    password: str
    shopName: Optional[str] = None # For creating first shop on registration (if SHOP_OWNER)
    businessType: Optional[str] = "supermarket" # For first shop

class UserLogin(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    password: str

class UserProfileUpdate(BaseModel):
    fullName: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[EmailStr] = None

class User(UserBase):
    id: str
    isEmailVerified: bool
    createdAt: datetime
    updatedAt: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    token: str
    refreshToken: Optional[str] = None
    user: User

# ==================== SHOP ====================

class ShopBase(BaseModel):
    name: str
    businessType: str
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    address: Optional[str] = None
    logoUrl: Optional[str] = None
    currency: str = "ETB"
    timezone: str = "Africa/Addis_Ababa"

class ShopCreate(ShopBase):
    pass

class Shop(ShopBase):
    id: str
    ownerId: str
    slug: str
    inviteCode: str
    isActive: bool
    createdAt: datetime
    updatedAt: datetime

    class Config:
        from_attributes = True

# ==================== MEMBERSHIP ====================

class CustomerShopMembershipBase(BaseModel):
    displayName: Optional[str] = None
    phone: Optional[str] = ""
    address: Optional[str] = ""
    notes: Optional[str] = ""

class CustomerShopMembershipCreate(BaseModel):
    shopId: str
    username: str

class CustomerShopMembership(CustomerShopMembershipBase):
    id: str
    customerId: Optional[str] = None
    shopId: str
    status: str
    walletBalance: float = 0.0
    approvalStatus: str = "approved"
    joinedAt: datetime
    updatedAt: datetime
    fullName: str
    totalDebt: float = 0.0
    totalPaid: float = 0.0
    outstandingBalance: float = 0.0
    shop: Optional[Shop] = None

    class Config:
        from_attributes = True

# ==================== CREDIT ITEM ====================

class CreditItemBase(BaseModel):
    itemName: str
    unitType: str
    quantity: float
    unitPrice: float

class CreditItemCreate(CreditItemBase):
    pass

class CreditItem(CreditItemBase):
    id: str
    sessionId: str
    totalPrice: float
    itemNotes: Optional[str] = None
    createdByUserId: Optional[str] = None
    createdAt: datetime
    updatedAt: Optional[datetime] = None

    class Config:
        from_attributes = True

# ==================== CREDIT SESSION ====================

class CreditSessionBase(BaseModel):
    deadline: Optional[datetime] = None
    notes: Optional[str] = ""

class CreditSessionCreate(CreditSessionBase):
    items: Optional[List[CreditItemCreate]] = []
    ethiopianDeadline: Optional[dict] = None # {year, month, day}

class CreditSession(CreditSessionBase):
    id: str
    membershipId: str
    shopId: str
    createdBy: str
    totalAmount: float
    paidAmount: float
    remainingAmount: float
    status: str
    createdAt: datetime
    updatedAt: datetime
    items: List[CreditItem]

    class Config:
        from_attributes = True

# ==================== PAYMENT ====================

class PaymentBase(BaseModel):
    amountPaid: float
    paymentMethod: str
    note: Optional[str] = None

class PaymentCreate(PaymentBase):
    sessionId: Optional[str] = None

class Payment(PaymentBase):
    id: str
    sessionId: Optional[str] = None
    membershipId: str
    shopId: str
    recordedBy: str
    balanceBefore: float
    balanceAfter: float
    paidAt: datetime
    createdAt: datetime

    class Config:
        from_attributes = True

# ==================== NOTIFICATION ====================

class NotificationBase(BaseModel):
    title: str
    message: str
    type: str
    isRead: bool = False

class Notification(NotificationBase):
    id: str
    userId: str
    shopId: Optional[str] = None
    sessionId: Optional[str] = None
    createdAt: datetime

    class Config:
        from_attributes = True

# ==================== SUMMARIES & DASHBOARDS ====================

class CreditAccountSummary(BaseModel):
    account: CustomerShopMembership
    sessions: List[CreditSession]
    paymentHistory: List[Payment]

class CustomerDashboard(BaseModel):
    totalAggregateDebt: float
    linkedAccounts: List[CustomerShopMembership]

class OwnerDashboard(BaseModel):
    totalCustomers: int
    totalActiveCredits: int
    totalOverdueCredits: int
    monthlyCollections: float
    outstandingAmount: float

# ==================== AUDIT LOG ====================

class AuditLog(BaseModel):
    id: str
    userId: Optional[str] = None
    action: str
    tableName: str
    recordId: Optional[str] = None
    oldValues: Optional[str] = None
    newValues: Optional[str] = None
    createdAt: datetime

    class Config:
        from_attributes = True

# ==================== DISPUTE ====================

class DisputeCreate(BaseModel):
    sessionId: Optional[str] = None
    message: str
