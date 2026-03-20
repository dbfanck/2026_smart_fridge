from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from db.connection import supabase
from datetime import datetime, timezone, timedelta

router = APIRouter()

class ItemCreate(BaseModel):
    temperature: float
    humidity: float

# 현재 냉장고 상태 조회
@router.get("/status")
def get_recent_status():
    response = supabase.table("FRIDGE_STATUS").select("temperature, humidity").execute()
    return response.data

# 냉장고 상태 업데이트
@router.post("/status")
def update_status(item: ItemCreate):
    data = {
        "temperatue": item.temperature,
        "humidity": item.humidity,
        "updated_at": datetime.now(timezone.utc).isoformat()
    }
    response = supabase.table("FRIDGE_STATUS").insert(data).execute()

    if not response.data:
        raise HTTPException(status_code=500, detail="업데이트 실패")

    return {"message": "업데이트 성공", "data": response.data[0]}