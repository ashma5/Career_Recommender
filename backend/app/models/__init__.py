# app/models/__init__.py
from .academic_model.model import predict_academic_career
from .non_academic_model.model import predict_non_academic_career

__all__ = ["predict_academic_career", "predict_non_academic_career"]