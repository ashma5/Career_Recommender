# app/api/__init__.py
from .academic import router as academic_router
from .non_academic import router as non_academic_router

__all__ = ["academic_router", "non_academic_router"]