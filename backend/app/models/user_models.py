from datetime import datetime
from sqlalchemy import Boolean, Column, Integer, String, DateTime, Float, JSON, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    roadmaps = relationship("UserRoadmap", back_populates="user")

class CareerRoadmap(Base):
    __tablename__ = "career_roadmaps"
    
    id = Column(Integer, primary_key=True, index=True)
    career_name = Column(String, unique=True, index=True, nullable=False)
    roadmap_data = Column(JSON, nullable=False)
    version = Column(String, default="1.0")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Add cascade delete
    user_roadmaps = relationship("UserRoadmap", back_populates="roadmap", cascade="all, delete-orphan")

class UserRoadmap(Base):
    __tablename__ = "user_roadmaps"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    roadmap_id = Column(Integer, ForeignKey("career_roadmaps.id", ondelete="CASCADE"), nullable=False)
    progress_data = Column(JSON, default=dict)
    completed_percentage = Column(Float, default=0.0)
    current_stage = Column(String)
    started_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    user = relationship("User", back_populates="roadmaps")
    roadmap = relationship("CareerRoadmap", back_populates="user_roadmaps")