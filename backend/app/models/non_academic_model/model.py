import joblib
import pandas as pd
from pathlib import Path
from app.schemas import IntelligenceScores

# Load model and encoder
model_path = Path(__file__).parent / "career_model_intelligence_only.pkl"
encoder_path = Path(__file__).parent / "label_encoder_intelligence.pkl"

model = joblib.load(model_path)
encoder = joblib.load(encoder_path)

async def predict_non_academic_career(scores: IntelligenceScores):
    input_dict = scores.dict()
    
    # Calculate derived scores
    analytical_score = (input_dict['Logical_Mathematical'] + input_dict['Spacial_Visualization']) / 2
    creative_score = (input_dict['Musical'] + input_dict['Bodily']) / 2
    social_score = (input_dict['Interpersonal'] + input_dict['Intrapersonal']) / 2
    
    input_data = pd.DataFrame({
        'Linguistic': [input_dict['Linguistic']],
        'Musical': [input_dict['Musical']],
        'Bodily': [input_dict['Bodily']],
        'Logical - Mathematical': [input_dict['Logical_Mathematical']],
        'Spatial-Visualization': [input_dict['Spacial_Visualization']],
        'Interpersonal': [input_dict['Interpersonal']],
        'Intrapersonal': [input_dict['Intrapersonal']],
        'Naturalist': [input_dict['Naturalist']],
        'Analytical_Score': [analytical_score],
        'Creative_Score': [creative_score],
        'Social_Score': [social_score]
    })
    
    prediction_encoded = model.predict(input_data)
    prediction = encoder.inverse_transform(prediction_encoded)[0]
    
    return {"predicted_career": prediction}