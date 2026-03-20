from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from db.connection import supabase
from datetime import datetime, timezone, timedelta

router = APIRouter()


# 냉장고 레이아웃 조회 (FRIDGE_ITEM + FRIDGE_ITEM_LOCATION 조인)
@router.get("/layouts")
def get_layouts():
    items_res = supabase.table("FRIDGE_ITEM").select("item_id, product_name").execute()
    locations_res = supabase.table("FRIDGE_ITEM_LOCATION").select("item_id, slot_number").execute()

    if items_res.data is None or locations_res.data is None:
        raise HTTPException(status_code=500, detail="Failed to fetch data")

    location_map = {loc["item_id"]: loc["slot_number"] for loc in locations_res.data}

    result = [
        {
            "item_id": item["item_id"],
            "product_name": item["product_name"],
            "slot_number": location_map.get(item["item_id"]),
        }
        for item in items_res.data
        if item["item_id"] in location_map
    ]

    return result

# 특정 아이템 상세 조회 (item_id 기준)
@router.get("/layouts/{item_id}")
def get_item_detail(item_id: int):
    response = (
        supabase.table("FRIDGE_ITEM")
        .select("product_name, created_at, expires_at")
        .eq("item_id", item_id)
        .single()
        .execute()
    )

    if not response.data:
        raise HTTPException(status_code=404, detail="Item not found")

    return response.data
