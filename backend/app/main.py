from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from .database import engine, Base
from .routers import auth, customers, notifications, shops, credits, payments, dashboard, websocket, admin
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Create database tables (SQLite fallback / Dev environment)
Base.metadata.create_all(bind=engine)

app = FastAPI(title="DubeBook SaaS API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Exception Handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logging.error(f"Unhandled exception at {request.url.path}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "detail": "An unexpected server error occurred. Please try again later.",
            "error_type": type(exc).__name__
        }
    )

app.include_router(auth.router)
app.include_router(shops.router)
app.include_router(customers.router)
app.include_router(credits.router)
app.include_router(payments.router)
app.include_router(notifications.router)
app.include_router(dashboard.router)
app.include_router(websocket.router)
app.include_router(admin.router)

@app.get("/")
async def root():
    return {"message": "Welcome to DubeBook Multi-Tenant SaaS API"}
