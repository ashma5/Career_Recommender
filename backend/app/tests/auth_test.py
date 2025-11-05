import pytest
from app.models.user_models import User
from app.auth import get_password_hash

def test_user_registration(client):
    """Test user can register successfully"""
    response = client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "testpassword123",
        "full_name": "Test User"
    })
    
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"
    assert "id" in response.json()

def test_user_login(client, test_user):
    """Test user can login and get token"""
    response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "testpassword123"
    })
    
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert response.json()["token_type"] == "bearer"

def test_admin_login(client):
    """Test admin can login with hardcoded credentials"""
    response = client.post("/admin/login", json={
        "username": "admin@gmail.com",
        "password": "admin123"
    })
    
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert response.json()["role"] == "admin"

def test_protected_endpoint_requires_auth(client):
    """Test protected endpoints require authentication"""
    response = client.get("/user/my-roadmaps")
    assert response.status_code == 401

@pytest.fixture
def test_user(client):
    """Create a test user"""
    client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "testpassword123",
        "full_name": "Test User"
    })