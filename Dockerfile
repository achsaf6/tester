# Multi-stage build for frontend and backend

# Stage 1: Build frontend with Vite
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# Copy package files
COPY frontend/package*.json ./
RUN npm ci

# Copy frontend source
COPY frontend/ ./
RUN npm run build

# Stage 2: Provide uv binary
FROM ghcr.io/astral-sh/uv:latest AS uvbin

# Stage 3: Python runtime with backend and built frontend
FROM python:3.11-slim AS runtime

WORKDIR /app

# Minimal packages and cleanup
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv for Python dependency management
COPY --from=uvbin /uv /uvx /bin/

# Copy Python dependency files and install (creates .venv)
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Copy backend code
COPY backend/ backend/

# Copy built frontend from first stage to the expected frontend directory (Vite outputs to dist/)
RUN mkdir -p frontend
COPY --from=frontend-builder /app/dist frontend/dist
COPY --from=frontend-builder /app/package.json frontend/package.json

# Cloud Run expects the container to listen on 8080
EXPOSE 8080

# Start the application without shell indirection
CMD ["/app/.venv/bin/uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8080"]