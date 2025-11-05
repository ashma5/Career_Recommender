from fastapi import FastAPI
from app.api import academic, non_academic, auth, roadmaps, admin
from app.database import engine
from app.models.user_models import Base
from app.seed_data import seed_initial_roadmaps
import os

# Create database tables
Base.metadata.create_all(bind=engine)

# Seed initial data
def seed_data_on_startup():
    try:
        seed_initial_roadmaps()
        print("✓ Initial roadmaps seeded successfully")
    except Exception as e:
        print(f"⚠️  Failed to seed initial data: {e}")

# Call the seed function
seed_data_on_startup()

app = FastAPI(
    title="Career Prediction API",
    description="API for academic, non-academic career predictions and roadmaps",
    version="2.0.0"
)

app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(academic.router, prefix="/academic", tags=["Academic"])
app.include_router(non_academic.router, prefix="/nonacademic", tags=["Non-Academic"])
app.include_router(roadmaps.router, prefix="/user", tags=["Roadmaps"])
app.include_router(admin.router, prefix="/admin", tags=["Admin"])

@app.get("/")
async def root():
    return {"message": "Career Prediction API with Roadmaps is running"}

if os.getenv("ENVIRONMENT") != "production":
    seed_data_on_startup()