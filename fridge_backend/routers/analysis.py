from fastapi import APIRouter
from db.connection import supabase
from collections import defaultdict

router = APIRouter()


# 1. 전체 식재료 조회 (LLM 레시피 추천용)
@router.get("/analysis/items")
def get_all_items():
    response = (
        supabase.table("FRIDGE_ITEM")
        .select("item_id, product_name, category, is_spoiled")
        .execute()
    )
    return response.data


# 2. 카테고리별 구매/폐기 통계
@router.get("/analysis/stats/category")
def get_category_stats():
    response = (
        supabase.table("FRIDGE_ITEM")
        .select("category, is_spoiled")
        .execute()
    )

    stats: dict[str, dict] = defaultdict(lambda: {"purchased": 0, "disposed": 0})
    for item in response.data:
        category = item.get("category") or "기타"
        stats[category]["purchased"] += 1
        if item.get("is_spoiled"):
            stats[category]["disposed"] += 1

    return [
        {"category": cat, "purchased": v["purchased"], "disposed": v["disposed"]}
        for cat, v in stats.items()
    ]


# 3. 전체 구매/폐기 통계 + 폐기율
@router.get("/analysis/stats/overall")
def get_overall_stats():
    response = (
        supabase.table("FRIDGE_ITEM")
        .select("is_spoiled")
        .execute()
    )

    total = len(response.data)
    disposed = sum(1 for item in response.data if item.get("is_spoiled"))
    dispose_rate = round(disposed / total * 100, 1) if total > 0 else 0.0

    return {
        "total_purchased": total,
        "total_disposed": disposed,
        "dispose_rate": dispose_rate,
    }
