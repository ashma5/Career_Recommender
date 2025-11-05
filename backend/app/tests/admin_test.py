def test_get_all_roadmaps_as_admin(client, admin_token, test_roadmap):
    """Test admin can get all roadmaps"""
    headers = {"Authorization": f"Bearer {admin_token}"}
    
    response = client.get("/admin/roadmaps", headers=headers)
    
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) > 0

def test_update_roadmap_as_admin(client, admin_token, test_roadmap):
    """Test admin can update a roadmap"""
    headers = {"Authorization": f"Bearer {admin_token}"}
    
    updated_data = {
        "career_name": "Test-Career",
        "roadmap_data": {
            "name": "Updated Career",
            "children": [
                {
                    "name": "Updated Step",
                    "details": "Updated details",
                    "node_id": "updated_node"
                }
            ]
        }
    }
    
    response = client.put("/admin/roadmaps/1", json=updated_data, headers=headers)
    assert response.status_code == 200
    assert response.json()["roadmap_data"]["name"] == "Updated Career"

def test_delete_roadmap_as_admin(client, admin_token, test_roadmap):
    """Test admin can delete a roadmap"""
    headers = {"Authorization": f"Bearer {admin_token}"}
    
    response = client.delete("/admin/roadmaps/1", headers=headers)
    assert response.status_code == 200
    assert response.json()["message"] == "Roadmap deleted successfully"