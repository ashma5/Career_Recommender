from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.database import get_db
from app.auth import get_current_user
from app.schemas import UserRoadmapResponse, ProgressUpdate
from app.models.user_models import User, CareerRoadmap, UserRoadmap
from app.utils.roadmap_utils import calculate_completion_percentage
from typing import Optional, Dict, Any, List


router = APIRouter(tags=["Roadmaps"])

@router.get("/roadmaps/{career_name}", response_model=UserRoadmapResponse)
async def get_career_roadmap(career_name: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Get the career roadmap
    roadmap = db.query(CareerRoadmap).filter(
        CareerRoadmap.career_name == career_name,
        CareerRoadmap.is_active == True
    ).first()
    
    if not roadmap:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Roadmap for this career not found"
        )
    
    # Check if user already has this roadmap
    user_roadmap = db.query(UserRoadmap).filter(
        UserRoadmap.user_id == current_user.id,
        UserRoadmap.roadmap_id == roadmap.id
    ).first()
    
    if not user_roadmap:
        # Create new user roadmap
        user_roadmap = UserRoadmap(
            user_id=current_user.id,
            roadmap_id=roadmap.id,
            progress_data={},
            completed_percentage=0.0
        )
        db.add(user_roadmap)
        db.commit()
        db.refresh(user_roadmap)
    
    return user_roadmap
    
@router.post("/roadmaps/{roadmap_id}/progress")
async def update_progress(roadmap_id: int, progress_update: ProgressUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Get user roadmap
    user_roadmap = db.query(UserRoadmap).filter(
        UserRoadmap.user_id == current_user.id,
        UserRoadmap.roadmap_id == roadmap_id
    ).first()
    
    if not user_roadmap:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User roadmap not found"
        )
    
    # IMPORTANT: Ensure we're working with a dictionary, not None
    if user_roadmap.progress_data is None:
        user_roadmap.progress_data = {}
    
    # Create a copy of the progress data and update it
    progress_data = dict(user_roadmap.progress_data)  # Convert to dict to ensure mutability
    progress_data[progress_update.node_id] = progress_update.completed
    
    # Assign the updated dictionary back
    user_roadmap.progress_data = progress_data
    
    # Calculate new completion percentage
    roadmap = user_roadmap.roadmap
    user_roadmap.completed_percentage = calculate_completion_percentage(
        roadmap.roadmap_data, user_roadmap.progress_data
    )
    
    db.commit()
    db.refresh(user_roadmap)  # This ensures we get the latest data
    
    return user_roadmap

@router.get("/my-roadmaps", response_model=List[Dict[str, Any]])
async def get_my_roadmaps(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Get all roadmaps for current user with completion status for final steps
    """
    user_roadmaps = db.query(UserRoadmap).options(
        joinedload(UserRoadmap.roadmap)
    ).filter(UserRoadmap.user_id == current_user.id).all()
    
    return [
        {
            "id": ur.id,
            "user_id": ur.user_id,
            "roadmap_id": ur.roadmap_id,
            "completed_percentage": ur.completed_percentage,
            "current_stage": ur.current_stage,
            "started_at": ur.started_at,
            "last_updated": ur.last_updated,
            "progress_data": ur.progress_data or {},
            "roadmap": {
                "id": ur.roadmap.id,
                "career_name": ur.roadmap.career_name,
                "roadmap_data": mark_final_steps_completed(ur.roadmap.roadmap_data, ur.progress_data or {}),
                "version": ur.roadmap.version,
                "is_active": ur.roadmap.is_active,
                "created_at": ur.roadmap.created_at,
                "updated_at": ur.roadmap.updated_at
            }
        }
        for ur in user_roadmaps
    ]

def mark_final_steps_completed(step: Dict[str, Any], progress: Dict[str, bool]) -> Dict[str, Any]:
    """
    Add completed status to final steps that have details (no sub-steps)
    """
    if not isinstance(step, dict):
        return step
    
    # Copy the step
    result = step.copy()
    
    # Check if this step has sub-steps
    has_substeps = 'children' in result and result['children']
    
    # Add completed status only to final steps with details
    if result.get('details') and result.get('node_id') and not has_substeps:
        result['completed'] = progress.get(result['node_id'], False)
    
    # Process sub-steps if they exist
    if has_substeps:
        result['children'] = [
            mark_final_steps_completed(child, progress)
            for child in result['children']
        ]
    
    return result