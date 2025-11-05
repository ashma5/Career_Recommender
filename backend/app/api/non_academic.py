from fastapi import APIRouter, Depends
from app.models.non_academic_model.model import predict_non_academic_career
from app.schemas import IntelligenceScores
from app.models.user_models import User
from app.auth import get_current_user

router = APIRouter()

@router.post("/predict-career", response_model=dict)
async def predict_career(scores: IntelligenceScores, current_user: User = Depends(get_current_user)
):
    return await predict_non_academic_career(scores)