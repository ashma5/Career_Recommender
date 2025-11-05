from app.database import SessionLocal
from app.models.user_models import CareerRoadmap
from app.utils.roadmap_utils import generate_node_ids


def seed_initial_roadmaps():
    db = SessionLocal()
    
    # Check if any roadmaps already exist
    existing_count = db.query(CareerRoadmap).count()
    if existing_count > 0:
        print("Roadmaps already exist, skipping seeding")
        db.close()
        return

    # Business Owner roadmap
    business_owner_roadmap = {
        "name": "Business-Owner",
        "children": [
            {
                "name": "Ideation & Validation",
                "details": "This stage focuses on generating and testing business ideas before committing resources.",
                "children": [
                    {
                        "name": "Idea Generation",
                        "children": [
                            {
                                "name": "Brainstorming Techniques",
                                "details": "Brainstorming is a creative method for producing many ideas quickly."
                            }
                        ]
                    }
                ]
            }
        ]
    }
    
    # Check if roadmap already exists
    existing = db.query(CareerRoadmap).filter(
        CareerRoadmap.career_name == "Business-Owner"
    ).first()
    
    if not existing:
        roadmap_with_ids = generate_node_ids(business_owner_roadmap)
        roadmap = CareerRoadmap(
            career_name="Business-Owner",
            roadmap_data=roadmap_with_ids
        )
        db.add(roadmap)
        db.commit()
        print("Seeded Business Owner roadmap")
    
    db.close()

if __name__ == "__main__":
    seed_initial_roadmaps()
