from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from typing import List, Dict, Any

from app.database import get_db
from app.auth import (
    authenticate_admin,
    create_admin_token,
    get_password_hash,
    get_current_admin,
)
from app.schemas import (
    AdminLogin,
    CareerRoadmapCreate,
    CareerRoadmapResponse,
    AdminDashboardStats,
    UserRoadmapDetail,
    UserUpdateAdmin,
    UserAdminResponse,
    UserCreateAdmin,
    UserWithRoadmaps,
)
from app.models.user_models import CareerRoadmap, User, UserRoadmap
from app.utils.admin_utils import get_admin_dashboard_stats, get_user_with_roadmaps
from app.utils.roadmap_utils import generate_node_ids

router = APIRouter(tags=["Admin"])

# ---------------- Admin Login ----------------
@router.post("/login")
async def admin_login(login_data: AdminLogin):
    admin = authenticate_admin(login_data.username, login_data.password)
    if not admin:
        raise HTTPException(status_code=401, detail="Invalid admin credentials")

    token = create_admin_token()
    return {"access_token": token, "token_type": "bearer", "role": "admin"}

# ---------------- Roadmaps ----------------
@router.post("/roadmaps", response_model=CareerRoadmapResponse)
async def create_roadmap(
    roadmap_data: CareerRoadmapCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_admin),
):
    existing = db.query(CareerRoadmap).filter(
        CareerRoadmap.career_name == roadmap_data.career_name
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Roadmap for this career already exists")

    roadmap_with_ids = generate_node_ids(roadmap_data.roadmap_data)
    roadmap = CareerRoadmap(
        career_name=roadmap_data.career_name,
        roadmap_data=roadmap_with_ids,
        version=roadmap_data.version,
        is_active=roadmap_data.is_active,
    )

    db.add(roadmap)
    db.commit()
    db.refresh(roadmap)
    return roadmap

@router.put("/roadmaps/{roadmap_id}", response_model=CareerRoadmapResponse)
async def update_roadmap(
    roadmap_id: int,
    roadmap_data: CareerRoadmapCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_admin),
):
    roadmap = db.query(CareerRoadmap).filter(CareerRoadmap.id == roadmap_id).first()
    if not roadmap:
        raise HTTPException(status_code=404, detail="Roadmap not found")

    roadmap_with_ids = generate_node_ids(roadmap_data.roadmap_data)
    roadmap.roadmap_data = roadmap_with_ids
    roadmap.version = roadmap_data.version
    roadmap.is_active = roadmap_data.is_active

    db.commit()
    db.refresh(roadmap)
    return roadmap

@router.get("/roadmaps", response_model=List[CareerRoadmapResponse])
async def get_all_roadmaps(
    db: Session = Depends(get_db), current_user=Depends(get_current_admin)
):
    return db.query(CareerRoadmap).all()

@router.delete("/roadmaps/{roadmap_id}")
async def delete_roadmap(
    roadmap_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_admin),
):
    roadmap = db.query(CareerRoadmap).filter(CareerRoadmap.id == roadmap_id).first()
    if not roadmap:
        raise HTTPException(status_code=404, detail="Roadmap not found")

    db.delete(roadmap)
    db.commit()
    return {"message": "Roadmap deleted successfully"}

# ---------------- Dashboard & Analytics ----------------
@router.get("/dashboard/stats", response_model=AdminDashboardStats)
async def get_dashboard_stats(
    db: Session = Depends(get_db), current_user=Depends(get_current_admin)
):
    return get_admin_dashboard_stats(db)

@router.get("/analytics/popular-careers")
async def get_popular_careers(
    db: Session = Depends(get_db), current_user=Depends(get_current_admin)
):
    popular_careers = (
        db.query(
            CareerRoadmap.career_name,
            func.count(UserRoadmap.id).label("user_count"),
        )
        .join(UserRoadmap, UserRoadmap.roadmap_id == CareerRoadmap.id)
        .group_by(CareerRoadmap.career_name)
        .order_by(func.count(UserRoadmap.id).desc())
        .all()
    )
    return [{"career_name": career, "user_count": count} for career, count in popular_careers]

# ---------------- Users ----------------
@router.get("/users", response_model=List[UserAdminResponse])
async def get_all_users(
    db: Session = Depends(get_db), current_user=Depends(get_current_admin)
):
    users = db.query(User).all()
    result = []
    for user in users:
        roadmap_count = db.query(UserRoadmap).filter(UserRoadmap.user_id == user.id).count()
        result.append(
            UserAdminResponse(
                id=user.id,
                email=user.email,
                full_name=user.full_name,
                is_active=user.is_active,
                created_at=user.created_at,
                updated_at=user.updated_at,
                roadmap_count=roadmap_count,
            )
        )
    return result

@router.get("/users/{user_id}", response_model=UserWithRoadmaps)
async def get_user_details(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    user_data = get_user_with_roadmaps(db, user_id)
    if not user_data:
        raise HTTPException(status_code=404, detail="User not found")
    return user_data
        
@router.post("/users", response_model=UserAdminResponse)
async def create_user(
    user_data: UserCreateAdmin,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_admin),
):
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="User already exists")

    user = User(
        email=user_data.email,
        hashed_password=get_password_hash(user_data.password),
        full_name=user_data.full_name,
        is_active=user_data.is_active,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return UserAdminResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        is_active=user.is_active,
        created_at=user.created_at,
        updated_at=user.updated_at,
        roadmap_count=0,
    )

@router.put("/users/{user_id}", response_model=UserAdminResponse)
async def update_user(
    user_id: int,
    user_data: UserUpdateAdmin,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user_data.email is not None:
        user.email = user_data.email
    if user_data.full_name is not None:
        user.full_name = user_data.full_name
    if user_data.is_active is not None:
        user.is_active = user_data.is_active

    db.commit()
    db.refresh(user)

    roadmap_count = db.query(UserRoadmap).filter(UserRoadmap.user_id == user.id).count()

    return UserAdminResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        is_active=user.is_active,
        created_at=user.created_at,
        updated_at=user.updated_at,
        roadmap_count=roadmap_count,
    )

@router.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.query(UserRoadmap).filter(UserRoadmap.user_id == user_id).delete()
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}

@router.get("/all-roadmaps", response_model=List[UserRoadmapDetail])
async def get_all_user_roadmaps(
    db: Session = Depends(get_db), current_user=Depends(get_current_admin)
):
    user_roadmaps = (
        db.query(UserRoadmap, User.email, CareerRoadmap.career_name)
        .join(User, UserRoadmap.user_id == User.id)
        .join(CareerRoadmap, UserRoadmap.roadmap_id == CareerRoadmap.id)
        .all()
    )
    return [
        UserRoadmapDetail(
            user_id=user_roadmap.user_id,
            user_email=user_email,
            roadmap_id=user_roadmap.roadmap_id,
            career_name=career_name,
            completed_percentage=user_roadmap.completed_percentage,
            started_at=user_roadmap.started_at,
            last_updated=user_roadmap.last_updated,
        )
        for user_roadmap, user_email, career_name in user_roadmaps
    ]
