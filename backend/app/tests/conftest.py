import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import Base, get_db

SQLITE_TEST_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLITE_TEST_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def test_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(test_db):
    def override_get_db():
        try:
            db = TestingSessionLocal()
            yield db
        finally:
            db.close()
    
    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

@pytest.fixture
def auth_token(client):
    """Get authentication token for test user"""
    client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "testpassword123",
        "full_name": "Test User"
    })
    
    response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "testpassword123"
    })
    
    return response.json()["access_token"]

@pytest.fixture
def admin_token(client):
    """Get admin token"""
    response = client.post("/admin/login", json={
        "username": "admin@gmail.com",
        "password": "admin123"
    })
    
    if response.status_code != 200 or "access_token" not in response.json():
        pytest.fail(f"Admin login failed. Response: {response.json()}")
    
    return response.json()["access_token"]


@pytest.fixture
def test_roadmap(client, admin_token):
    """Create a test roadmap - with better error handling"""
    headers = {"Authorization": f"Bearer {admin_token}"}
    
    # Simple roadmap that should work
    roadmap_data = {
        "career_name": "Debug-Career",
        "roadmap_data": {
            "name": "Debug Career",
            "children": [
                {
                    "name": "Debug Step",
                    "details": "Debug details",
                    "node_id": "test_node"
                }
            ]
        }
    }
    
    response = client.post("/admin/roadmaps", json=roadmap_data, headers=headers)
    
    if response.status_code != 200:
        pytest.fail(f"Roadmap creation failed: {response.status_code} - {response.text}")
    
    return response.json()

@pytest.fixture
def test_user_roadmap(client, auth_token, test_roadmap):
    """Ensure user has a roadmap by accessing it, return the user roadmap"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # User accesses the roadmap to create the association
    access_response = client.get(f"/user/roadmaps/{test_roadmap['career_name']}", headers=headers)
    
    assert access_response.status_code == 200, f"Roadmap access failed: {access_response.text}"
    
    return access_response.json()

@pytest.fixture
def test_user(client):
    """Create a test user directly in database (for tests that need user object)"""
    db = TestingSessionLocal()
    
    # Create user directly to avoid API calls in some tests
    user = User(
        email="direct@test.com",
        hashed_password=get_password_hash("directpassword123"),
        full_name="Direct Test User"
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    db.close()
    
    return user

# Import here to avoid circular imports
from app.models.user_models import User