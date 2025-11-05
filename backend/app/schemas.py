from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any, List
from datetime import datetime

# ---------------- Student Marks ----------------
class StudentMarksData(BaseModel):
    gender: int  # 0 for male, 1 for female
    extracurricular_activities: int  # 1 for yes, 0 for no
    math_score: int
    history_score: int
    physics_score: int
    chemistry_score: int
    biology_score: int
    english_score: int
    geography_score: int

class IntelligenceScores(BaseModel):
    Linguistic: int
    Musical: int
    Bodily: int
    Logical_Mathematical: int
    Spacial_Visualization: int
    Interpersonal: int
    Intrapersonal: int
    Naturalist: int

# ---------------- Auth ----------------
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    full_name: Optional[str] = None
    is_active: bool

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

# ---------------- Roadmap ----------------
class RoadmapNode(BaseModel):
    name: str
    details: Optional[str] = None
    completed: Optional[bool] = False
    node_id: Optional[str] = None
    children: Optional[List['RoadmapNode']] = None

class CareerRoadmapBase(BaseModel):
    career_name: str
    roadmap_data: Dict[str, Any]
    version: str = "1.0"
    is_active: bool = True

class CareerRoadmapCreate(CareerRoadmapBase):
    pass

class CareerRoadmapResponse(CareerRoadmapBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True   # ✅ Important

class UserRoadmapBase(BaseModel):
    roadmap_id: int
    progress_data: Dict[str, bool] = {}

class UserRoadmapCreate(UserRoadmapBase):
    pass

class UserRoadmapResponse(UserRoadmapBase):
    id: int
    user_id: int
    completed_percentage: float
    current_stage: Optional[str] = None
    started_at: datetime
    last_updated: datetime
    roadmap: CareerRoadmapResponse

    class Config:
        from_attributes = True   # ✅ Important

class ProgressUpdate(BaseModel):
    node_id: str
    completed: bool

# ---------------- Admin ----------------
class AdminLogin(BaseModel):
    username: str
    password: str

class UserAdminResponse(BaseModel):
    id: int
    email: EmailStr
    full_name: Optional[str] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    roadmap_count: int = 0

    class Config:
        from_attributes = True   # ✅ Important

class UserCreateAdmin(BaseModel):
    email: EmailStr
    password: str
    full_name: Optional[str] = None
    is_active: bool = True

class UserUpdateAdmin(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    is_active: Optional[bool] = None

class AdminDashboardStats(BaseModel):
    total_users: int
    active_users: int
    new_users_this_month: int
    total_roadmaps: int
    most_popular_career: Optional[str] = None

class UserRoadmapDetail(BaseModel):
    user_id: int
    user_email: str
    roadmap_id: int
    career_name: str
    completed_percentage: float
    started_at: datetime
    last_updated: datetime

    class Config:
        from_attributes = True
class UserRoadmapDetailResponse(BaseModel):
    id: int
    user_id: int
    roadmap_id: int
    progress_data: Dict[str, bool]
    completed_percentage: float
    current_stage: Optional[str] = None
    started_at: datetime
    last_updated: datetime
    roadmap: CareerRoadmapResponse 

    class Config:
        from_attributes = True

class UserWithRoadmaps(BaseModel):
    user: UserAdminResponse  # Nested user object
    roadmaps: List[UserRoadmapDetailResponse]  # List of detailed roadmaps
    roadmap_count: int  # Total count

    class Config:
        from_attributes = True