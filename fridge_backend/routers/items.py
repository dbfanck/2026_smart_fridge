from fastapi import APIRouter
from db.connection import supabase
from datetime import datetime, timezone, timedelta

router = APIRouter()

# 유통기한 임박 조회 (3일 이내)
@router.get("/items/expiring")
def get_expiring_items():
    now = datetime.now(timezone.utc)
    soon = now + timedelta(days=3)

    response = (
        supabase.table("FRIDGE_ITEM").select("item_id, product_name, category, expires_at")
        .gte("expires_at", now.isoformat()).lte("expires_at", soon.isoformat()).execute()
    )
    return response.data

# 최근 활동 조회 (5개)
@router.get("/items/recent")
def get_recent_items():
    response = supabase.table("FRIDGE_ITEM").select("product_name, created_at").order("created_at", desc=True).limit(5).execute()
    return response.data