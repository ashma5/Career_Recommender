from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, extract
from datetime import datetime, timedelta
from app.models.user_models import User, CareerRoadmap, UserRoadmap
from app.schemas import AdminDashboardStats

def get_admin_dashboard_stats(db: Session) -> AdminDashboardStats:
    total_users = db.query(User).count()
    active_users = db.query(User).filter(User.is_active == True).count()
    new_users_this_month = db.query(User).filter(
        func.strftime("%Y-%m", User.created_at) == datetime.now().strftime("%Y-%m")
    ).count()
    total_roadmaps = db.query(CareerRoadmap).count()

    # popular career
    popular_career = (
        db.query(CareerRoadmap.career_name, func.count(UserRoadmap.id).label("user_count"))
        .join(UserRoadmap, UserRoadmap.roadmap_id == CareerRoadmap.id)
        .group_by(CareerRoadmap.career_name)
        .order_by(func.count(UserRoadmap.id).desc())
        .first()
    )
    most_popular_career = popular_career.career_name if popular_career else None

    # monthly growth
    monthly_data = (
        db.query(
            func.strftime("%Y-%m", User.created_at).label("month"),
            func.count(User.id).label("count")
        )
        .group_by("month")
        .all()
    )

    return AdminDashboardStats(
        total_users=total_users,
        active_users=active_users,
        new_users_this_month=new_users_this_month,
        total_roadmaps=total_roadmaps,
        most_popular_career=most_popular_career,
    )

def get_user_with_roadmaps(db: Session, user_id: int):
    """Get user details with full roadmap information"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None

    # Get user's roadmaps with full roadmap data
    user_roadmaps = (
        db.query(UserRoadmap)
        .filter(UserRoadmap.user_id == user_id)
        .options(joinedload(UserRoadmap.roadmap))
        .all()
    )

    # Prepare roadmap list with all required fields
    roadmap_list = []
    for user_roadmap in user_roadmaps:
        roadmap_list.append({
            "id": user_roadmap.id,  # Required
            "user_id": user_roadmap.user_id,  # Required
            "roadmap_id": user_roadmap.roadmap_id,  # Required
            "progress_data": user_roadmap.progress_data or {},  # Required
            "completed_percentage": user_roadmap.completed_percentage,  # Required
            "current_stage": user_roadmap.current_stage,  # Required
            "started_at": user_roadmap.started_at,  # Required
            "last_updated": user_roadmap.last_updated,  # Required
            "roadmap": {  # Required - full roadmap data
                "id": user_roadmap.roadmap.id,
                "career_name": user_roadmap.roadmap.career_name,
                "roadmap_data": user_roadmap.roadmap.roadmap_data,
                "version": user_roadmap.roadmap.version,
                "is_active": user_roadmap.roadmap.is_active,
                "created_at": user_roadmap.roadmap.created_at,
                "updated_at": user_roadmap.roadmap.updated_at
            }
        })

    return {
        "user": {  # Required - nested user object
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "is_active": user.is_active,
            "created_at": user.created_at,
            "updated_at": user.updated_at
        },
        "roadmaps": roadmap_list,  # Required
        "roadmap_count": len(user_roadmaps)  # Required
    }