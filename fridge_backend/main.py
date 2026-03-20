from fastapi import FastAPI
from routers import items, status, layouts

app = FastAPI()

app.include_router(status.router)
app.include_router(items.router)
app.include_router(layouts.router)