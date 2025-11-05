def test_academic_career_prediction(client, auth_token):
    """Test academic career prediction"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    response = client.post("/academic/predict-career", json={
        "gender": 0,
        "extracurricular_activities": 1,
        "math_score": 90,
        "history_score": 85,
        "physics_score": 95,
        "chemistry_score": 92,
        "biology_score": 88,
        "english_score": 80,
        "geography_score": 75
    }, headers=headers)
    
    assert response.status_code == 200
    assert "predicted_career" in response.json()

def test_non_academic_career_prediction(client, auth_token):
    """Test non-academic career prediction"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    response = client.post("/nonacademic/predict-career", json={
        "Linguistic": 15,
        "Musical": 10,
        "Bodily": 8,
        "Logical_Mathematical": 18,
        "Spacial_Visualization": 17,
        "Interpersonal": 16,
        "Intrapersonal": 15,
        "Naturalist": 14
    }, headers=headers)
    
    assert response.status_code == 200
    assert "predicted_career" in response.json()