import pytest

def test_create_roadmap_as_admin(client, admin_token):
    """Test admin can create a roadmap"""
    headers = {"Authorization": f"Bearer {admin_token}"}
    
    roadmap_data = {
        "career_name": "Software-Developer-Test",
        "roadmap_data": {
            "name": "Software Developer Test",
            "children": [
                {
                    "name": "Foundation",
                    "details": "Basic skills",
                    "children": [
                        {
                            "name": "Programming",
                            "details": "Learn to code",
                            "node_id": "programming_node"  # Added node_id
                        }
                    ]
                }
            ]
        }
    }
    
    response = client.post("/admin/roadmaps", json=roadmap_data, headers=headers)
    assert response.status_code == 200
    assert response.json()["career_name"] == "Software-Developer-Test"

def test_get_roadmap_for_user(client, auth_token, test_user_roadmap):
    """Test user can get their roadmap AFTER accessing it first"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    response = client.get("/user/my-roadmaps", headers=headers)
    
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) > 0, "User should have roadmaps after accessing one"

# def test_update_progress(client, auth_token, test_user_roadmap):
#     """Test user can update progress on roadmap nodes"""
#     headers = {"Authorization": f"Bearer {auth_token}"}
    
#     # Use the actual roadmap ID from the fixture, not hardcoded "1"
#     roadmap_id = test_user_roadmap["roadmap_id"]
    
#     response = client.post(f"/user/roadmaps/{roadmap_id}/progress", json={
#         "node_id": "test_node",  # This should match the node_id in test_roadmap
#         "completed": True
#     }, headers=headers)
    
#     assert response.status_code == 200
#     assert response.json()["completed_percentage"] > 0


# @pytest.fixture
def test_roadmap(client, admin_token):
    """Create a test roadmap and return the created roadmap"""
    headers = {"Authorization": f"Bearer {admin_token}"}
    
    response = client.post("/admin/roadmaps", json={
        "career_name": "Test-Career-Fixture",
        "roadmap_data": {
            "name": "Test Career Fixture",
            "children": [
                {
                    "name": "Test Step",
                    "details": "Test details",
                    "node_id": "test_node"  # This is the node we'll test with
                }
            ]
        }
    }, headers=headers)
    
    assert response.status_code == 200, f"Roadmap creation failed: {response.text}"
    return response.json()  # Return the created roadmap

@pytest.fixture
def test_user_roadmap(client, auth_token, test_roadmap):
    """Ensure user has a roadmap by accessing it, return the user roadmap"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # User accesses the roadmap to create the association
    access_response = client.get(f"/user/roadmaps/{test_roadmap['career_name']}", headers=headers)
    
    assert access_response.status_code == 200, f"Roadmap access failed: {access_response.text}"
    return access_response.json()  # Return the user roadmap