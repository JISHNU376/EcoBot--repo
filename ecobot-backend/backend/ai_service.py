from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from datetime import datetime
import numpy as np
import openai
import os
from dotenv import load_dotenv
import uvicorn

# ------------------------------
# Load environment variables
# ------------------------------
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
api_url = os.getenv("API_URL")  # Optional, if needed

if api_key:
    print(f"✅ OpenAI API Key loaded: {api_key[:5]}... (hidden)")
else:
    print("❌ ERROR: OpenAI API Key not found!")

# For openai >=1.0.0, set api_key directly
openai.api_key = api_key

# ------------------------------
# FastAPI setup
# ------------------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change for production!
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------------------
# Models
# ------------------------------
class Activity(BaseModel):
    category: str
    co2: float
    date: str

class AnalysisRequest(BaseModel):
    activities: List[Activity]
    location: str

# ------------------------------
# Carbon footprint analysis
# ------------------------------
@app.post("/analyze")
async def analyze_footprint(data: AnalysisRequest):
    try:
        dates = [datetime.strptime(a.date, "%Y-%m-%d") for a in data.activities]
        co2_values = [a.co2 for a in data.activities]

        if len(co2_values) < 2:
            return {
                "trend": "insufficient_data",
                "recommendations": ["Need at least 2 data points for analysis"]
            }

        x = np.array([(d - min(dates)).days for d in dates])
        y = np.array(co2_values)

        if len(set(x)) < 2 or len(set(y)) < 2:
            return {
                "trend": "insufficient_variation",
                "recommendations": ["Not enough variation in data to calculate trend"]
            }

        try:
            slope = np.polyfit(x, y, 1)[0]
        except np.linalg.LinAlgError as e:
            return {
                "trend": "fit_failed",
                "error": f"SVD convergence failed: {str(e)}",
                "recommendations": ["Check data for repeated or extreme values"]
            }

        location_tips = {
            "urban": [
                "Try public transportation 2+ days/week",
                "Consider a bike for short distances"
            ],
            "rural": [
                "Combine errands to reduce trips",
                "Check home insulation efficiency"
            ]
        }

        return {
            "trend": "decreasing" if slope < 0 else "increasing",
            "rate": abs(slope),
            "recommendations": location_tips.get(data.location, [
                "Reduce energy consumption",
                "Consider plant-based meals"
            ]),
            "analysis_date": datetime.now().isoformat()
        }

    except Exception as e:
        return {"error": str(e)}

# ------------------------------
# Chatbot endpoint
# ------------------------------
@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    user_message = data.get("message", "")

    if not user_message:
        return {"reply": "Please send a message."}

    try:
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are EcoBot, an eco-friendly assistant helping with sustainability questions."},
                {"role": "user", "content": user_message}
            ]
        )

        reply = response.choices[0].message.content.strip()
        return {"reply": reply}

    except openai.APIError as e:
        error_message = f"OpenAI API error: {str(e)}"
    except openai.OpenAIError as e:
        error_message = f"OpenAI general error: {str(e)}"
    except Exception as e:
        error_message = f"Unknown error: {str(e)}"

    print(error_message)
    return {"reply": "Hello! Buddy"}

# ------------------------------
# Run the server
# ------------------------------
if __name__ == "__main__":
    uvicorn.run("ai_service:app", host="0.0.0.0", port=8000, reload=True)
