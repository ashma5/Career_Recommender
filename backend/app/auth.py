from datetime import datetime, timedelta
import jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user_models import User
from app.config import SECRET_KEY, ALGORITHM, ADMIN_CREDENTIALS, ACCESS_TOKEN_EXPIRE_MINUTES

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")  # for user login

# ---------------- Password helpers ----------------
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

# ---------------- Token helpers ----------------
def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=30))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# ---------------- User auth ----------------
async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        role: str = payload.get("role")
        if email is None:
            raise credentials_exception
    except jwt.ExpiredSignatureError:
        raise credentials_exception
    except jwt.InvalidTokenError:
        raise credentials_exception

    # If it's an admin token, skip DB lookup
    if role == "admin" and email == ADMIN_CREDENTIALS["admin_username"]:
        return {"email": email, "role": "admin"}

    # Otherwise check user in DB
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

# ---------------- Admin auth ----------------
def authenticate_admin(username: str, password: str):
    if (
        username == ADMIN_CREDENTIALS["admin_username"]
        and password == ADMIN_CREDENTIALS["admin_password"]
    ):
        return {"username": username, "role": "admin"}
    return None

def create_admin_token():
    """Create admin token with role=admin"""
    return create_access_token(
        data={"sub": ADMIN_CREDENTIALS["admin_username"], "role": "admin"},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

async def get_current_admin(current_user=Depends(get_current_user)):
    """Verify that the current user is an admin"""
    if isinstance(current_user, dict) and current_user.get("role") == "admin":
        return current_user
    if hasattr(current_user, "email") and current_user.email == ADMIN_CREDENTIALS["admin_username"]:
        return current_user
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Admin privileges required"
    )
