from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os

app = FastAPI(
    title="Backend", description="Backend API for an application", version="0.1.0"
)

# Determine if we're in development or production
ENVIRONMENT = os.getenv("ENVIRONMENT", "production")
IS_DEVELOPMENT = ENVIRONMENT == "development"

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],  # Frontend dev and prod URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRONTEND_DIST = os.path.join(BASE_DIR, "frontend", "dist")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "backend", "environment": ENVIRONMENT}


# Only mount static files in production
# In development, the Vite dev server will serve the frontend
if not IS_DEVELOPMENT:
    app.mount(
        "/", StaticFiles(directory=FRONTEND_DIST, html=True), name="static"
    )