from fastapi import APIRouter, Depends
from app.models.academic_model.model import predict_academic_career
from app.schemas import StudentMarksData
from app.models.user_models import User
from app.auth import get_current_user

router = APIRouter()

@router.post("/predict-career", response_model=dict)
async def predict_career(student_data: StudentMarksData, current_user: User = Depends(get_current_user)):
    return await predict_academic_career(student_data)