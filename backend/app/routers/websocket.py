from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from typing import Optional
from ..auth import SECRET_KEY, ALGORITHM
from ..database import SessionLocal
from ..models import models
import logging
import json

router = APIRouter(prefix="/ws", tags=["websocket"])
logger = logging.getLogger("websocket")

class ConnectionManager:
    def __init__(self):
        # Maps user_id -> list of active WebSockets
        self.active_connections: dict[str, list[WebSocket]] = {}
    
    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)
        logger.info(f"User {user_id} connected to WebSocket. Total active connections: {len(self.active_connections[user_id])}")
    
    def disconnect(self, user_id: str, websocket: WebSocket):
        if user_id in self.active_connections:
            if websocket in self.active_connections[user_id]:
                self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        logger.info(f"User {user_id} disconnected from WebSocket.")
        
    async def notify_user(self, user_id: str, event_type: str, payload: dict):
        if user_id in self.active_connections:
            message = json.dumps({"event": event_type, "data": payload})
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_text(message)
                except Exception as e:
                    logger.error(f"Error sending message to user {user_id}: {e}")

manager = ConnectionManager()

def get_user_from_token(token: str) -> Optional[models.User]:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            return None
        
        db = SessionLocal()
        try:
            user = db.query(models.User).filter(models.User.id == user_id).first()
            if user and user.isActive:
                return user
        finally:
            db.close()
    except JWTError:
        pass
    return None

@router.websocket("/{token}")
async def websocket_endpoint(websocket: WebSocket, token: str):
    user = get_user_from_token(token)
    if not user:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return
        
    await manager.connect(user.id, websocket)
    try:
        while True:
            # Keep connection alive, listen for client messages (heartbeats/pings)
            data = await websocket.receive_text()
            # Just echo ping/pong back
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(user.id, websocket)
    except Exception as e:
        logger.error(f"WebSocket error for user {user.id}: {e}")
        manager.disconnect(user.id, websocket)
