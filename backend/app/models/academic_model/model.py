import joblib
import pandas as pd
from pathlib import Path
from app.schemas import StudentMarksData

# Load model and encoder
model_path = Path(__file__).parent / "best_academic_model.pkl"
encoder_path = Path(__file__).parent / "academic_label_encoder.pkl"

model = joblib.load(model_path)
encoder = joblib.load(encoder_path)

async def predict_academic_career(student_data: StudentMarksData):
    input_data = pd.DataFrame([student_data.dict()])
    predicted_label = model.predict(input_data)
    predicted_career = encoder.inverse_transform(predicted_label)[0]
    return {"predicted_career": predicted_career}