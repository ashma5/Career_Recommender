
# Career Recommendation API

A FastAPI-based service that provides career predictions based on academic scores and multiple intelligence metrics.

##  Getting Started

### Prerequisites
- Python 3.9+
- pip package manager

### Installation

1. Create and activate a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## 🏃 Running the Application


```bash
fastapi run
```

The API will be available at `http://localhost:8000`

## 📂 Project Structure

```
career-recommendation-api/
├── app/                       # Main application package
│   ├── __init__.py            # Package initialization
│   ├── main.py                # FastAPI app setup and routing
│   ├── api/                   # API endpoint definitions
│   │   ├── __init__.py        # API package initialization
│   │   ├── academic.py        # Academic career prediction endpoints
│   │   └── non_academic.py    # Non-academic career prediction endpoints
│   ├── models/                # ML model implementations
│   │   ├── __init__.py
│   │   ├── academic_model/    # Academic prediction model
│   │   │   ├── __init__.py
│   │   │   ├── model.py
│   │   │   ├── best_academic_model.pkl
│   │   │   └── academic_label_encoder.pkl
│   │   └── non_academic_model/  # Non-academic prediction model
│   │       ├── __init__.py
│   │       ├── model.py
│   │       ├── career_model_intelligence_only.pkl
│   │       └── label_encoder_intelligence.pkl
│   ├── schemas.py             # Pydantic models for request
│   └── utils.py               # Utility functions
├── requirements.txt           # Python dependencies
└── README.md                  # This documentation
```

## 🌐 API Endpoints

### Academic Career Prediction
- `POST /academic/predict-career`
  ```json
  {
    "gender": 0,
    "extracurricular_activities": 1,
    "math_score": 90,
    "history_score": 85,
    "physics_score": 95,
    "chemistry_score": 92,
    "biology_score": 88,
    "english_score": 80,
    "geography_score": 75
  }
  ```

### Non-Academic Career Prediction
- `POST /nonacademic/predict-career`
  ```json
  {
    "Linguistic": 15,
    "Musical": 10,
    "Bodily": 8,
    "Logical_Mathematical": 18,
    "Spacial_Visualization": 17,
    "Interpersonal": 16,
    "Intrapersonal": 15,
    "Naturalist": 14
  }
  ```

## API Documentation
Interactive documentation is automatically available at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
