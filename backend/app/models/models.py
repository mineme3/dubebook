import uuid
from sqlalchemy import Column, String, Float, DateTime, Boolean, ForeignKey, Integer, Text
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from ..database import Base

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=generate_uuid)
    username = Column(String, unique=True, index=True, nullable=False)
    fullName = Column(String, nullable=False)
    phone = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    passwordHash = Column(String, nullable=False)
    role = Column(String, default="SHOP_OWNER") # PLATFORM_ADMIN, SHOP_OWNER, CUSTOMER
    isEmailVerified = Column(Boolean, default=False)
    emailVerifyToken = Column(String, nullable=True)
    emailVerifyExpires = Column(DateTime, nullable=True)
    passwordResetToken = Column(String, nullable=True)
    passwordResetExpires = Column(DateTime, nullable=True)
    profilePhotoUrl = Column(String, nullable=True)
    isActive = Column(Boolean, default=True)
    createdAt = Column(DateTime, default=datetime.utcnow)
    updatedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    shops = relationship("Shop", back_populates="owner", cascade="all, delete-orphan")
    memberships = relationship("CustomerShopMembership", back_populates="customer", foreign_keys="[CustomerShopMembership.customerId]", cascade="all, delete-orphan")
    refreshTokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(String, primary_key=True, default=generate_uuid)
    userId = Column(String, ForeignKey("users.id"), nullable=False)
    token = Column(String, unique=True, index=True, nullable=False)
    expiresAt = Column(DateTime, nullable=False)
    revoked = Column(Boolean, default=False)
    createdAt = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="refreshTokens")

class Shop(Base):
    __tablename__ = "shops"

    id = Column(String, primary_key=True, default=generate_uuid)
    ownerId = Column(String, ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False)
    slug = Column(String, unique=True, index=True, nullable=False)
    businessType = Column(String, nullable=False) # supermarket, grocery, etc.
    phone = Column(String, nullable=True)
    email = Column(String, nullable=True)
    address = Column(String, nullable=True)
    logoUrl = Column(String, nullable=True)
    currency = Column(String, default="ETB")
    timezone = Column(String, default="Africa/Addis_Ababa")
    inviteCode = Column(String, unique=True, index=True, nullable=False)
    isActive = Column(Boolean, default=True)
    createdAt = Column(DateTime, default=datetime.utcnow)
    updatedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    owner = relationship("User", back_populates="shops")
    memberships = relationship("CustomerShopMembership", back_populates="shop", cascade="all, delete-orphan")
    creditSessions = relationship("CreditSession", back_populates="shop", cascade="all, delete-orphan")
    payments = relationship("Payment", back_populates="shop", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="shop", cascade="all, delete-orphan")

class CustomerShopMembership(Base):
    __tablename__ = "customer_shop_memberships"

    id = Column(String, primary_key=True, default=generate_uuid)
    customerId = Column(String, ForeignKey("users.id"), nullable=True)
    shopId = Column(String, ForeignKey("shops.id"), nullable=False)
    displayName = Column(String, nullable=False) # Owner's name for this customer
    phone = Column(String, nullable=False)
    address = Column(String, default="")
    notes = Column(String, default="")
    status = Column(String, default="active") # active, suspended, archived
    walletBalance = Column(Float, default=0.0) # Overpayment stored as positive balance
    isDeleted = Column(Boolean, default=False) # Soft-delete: owner hides, admin sees
    deletedAt = Column(DateTime, nullable=True)
    deletedBy = Column(String, ForeignKey("users.id"), nullable=True)
    approvalStatus = Column(String, default="approved") # pending, approved, rejected
    joinedAt = Column(DateTime, default=datetime.utcnow)
    updatedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    customer = relationship("User", back_populates="memberships", foreign_keys=[customerId])
    shop = relationship("Shop", back_populates="memberships")
    creditSessions = relationship("CreditSession", back_populates="membership", cascade="all, delete-orphan")
    payments = relationship("Payment", back_populates="membership", cascade="all, delete-orphan")

    @property
    def fullName(self):
        return self.displayName

    @property
    def totalDebt(self):
        return sum(s.totalAmount for s in self.creditSessions if s.status != "cancelled")

    @property
    def totalPaid(self):
        return sum(p.amountPaid for p in self.payments)

    @property
    def outstandingBalance(self):
        return max(0.0, self.totalDebt - self.totalPaid)

class CreditSession(Base):
    __tablename__ = "credit_sessions"

    id = Column(String, primary_key=True, default=generate_uuid)
    membershipId = Column(String, ForeignKey("customer_shop_memberships.id"), nullable=False)
    shopId = Column(String, ForeignKey("shops.id"), nullable=False)
    createdBy = Column(String, ForeignKey("users.id"), nullable=False)
    totalAmount = Column(Float, default=0.0)
    paidAmount = Column(Float, default=0.0)
    remainingAmount = Column(Float, default=0.0)
    deadline = Column(DateTime, nullable=True)
    status = Column(String, default="active") # active, partially_paid, paid/settled, overdue, cancelled
    notes = Column(String, default="")
    createdAt = Column(DateTime, default=datetime.utcnow)
    updatedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    membership = relationship("CustomerShopMembership", back_populates="creditSessions")
    shop = relationship("Shop", back_populates="creditSessions")
    items = relationship("CreditItem", back_populates="session", cascade="all, delete-orphan")
    payments = relationship("Payment", back_populates="session")
    notifications = relationship("Notification", back_populates="session")

class CreditItem(Base):
    __tablename__ = "credit_items"

    id = Column(String, primary_key=True, default=generate_uuid)
    sessionId = Column(String, ForeignKey("credit_sessions.id"), nullable=False)
    itemName = Column(String, nullable=False)
    unitType = Column(String, nullable=False)
    quantity = Column(Float, nullable=False)
    unitPrice = Column(Float, nullable=False)
    totalPrice = Column(Float, nullable=False)
    itemNotes = Column(String, nullable=True)
    createdByUserId = Column(String, ForeignKey("users.id"), nullable=True)
    createdAt = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updatedAt = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    session = relationship("CreditSession", back_populates="items")

class Payment(Base):
    __tablename__ = "payments"

    id = Column(String, primary_key=True, default=generate_uuid)
    sessionId = Column(String, ForeignKey("credit_sessions.id"), nullable=True)
    membershipId = Column(String, ForeignKey("customer_shop_memberships.id"), nullable=False)
    shopId = Column(String, ForeignKey("shops.id"), nullable=False)
    recordedBy = Column(String, ForeignKey("users.id"), nullable=False)
    amountPaid = Column(Float, nullable=False)
    paymentMethod = Column(String, nullable=False) # cash, mobile_money, bank_transfer, other
    note = Column(String, nullable=True)
    balanceBefore = Column(Float, nullable=False)
    balanceAfter = Column(Float, nullable=False)
    paidAt = Column(DateTime, default=datetime.utcnow)
    createdAt = Column(DateTime, default=datetime.utcnow)

    session = relationship("CreditSession", back_populates="payments")
    membership = relationship("CustomerShopMembership", back_populates="payments")
    shop = relationship("Shop", back_populates="payments")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, default=generate_uuid)
    userId = Column(String, ForeignKey("users.id"), nullable=False)
    shopId = Column(String, ForeignKey("shops.id"), nullable=True)
    sessionId = Column(String, ForeignKey("credit_sessions.id"), nullable=True)
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    type = Column(String, nullable=False) # deadline_warning, deadline_reached, payment_received, system
    isRead = Column(Boolean, default=False)
    createdAt = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="notifications")
    shop = relationship("Shop", back_populates="notifications")
    session = relationship("CreditSession", back_populates="notifications")

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String, primary_key=True, default=generate_uuid)
    userId = Column(String, nullable=True) # who performed action
    action = Column(String, nullable=False) # CREATE, UPDATE, DELETE
    tableName = Column(String, nullable=False) # which table
    recordId = Column(String, nullable=True) # which record
    oldValues = Column(Text, nullable=True) # JSON of old values
    newValues = Column(Text, nullable=True) # JSON of new values
    ipAddress = Column(String, nullable=True)
    createdAt = Column(DateTime, default=lambda: datetime.now(timezone.utc))
