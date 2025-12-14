# --- ETAPA 1: Construir Frontend (React) ---
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend
# Copiamos archivos de dependencias
COPY frontend/package*.json ./
RUN npm install

# Copiamos el código fuente y construimos
COPY frontend/ .
RUN npm run build


# --- ETAPA 2: Construir Backend (FastAPI + uv) ---
FROM python:3.12-slim

# Instalamos uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# Copiamos dependencias de Python
COPY app/pyproject.toml app/uv.lock app/README.md ./
# Instalamos dependencias del sistema
RUN uv pip install --system --no-cache .

# Copiamos el código del backend
COPY app/ .

# --- FUSIÓN: Copiamos el build de React a la carpeta estática de FastAPI ---
# Vite genera el build en /frontend/dist. Lo movemos a /app/static
COPY --from=frontend-builder /frontend/dist ./static

# Exponemos el puerto 80
EXPOSE 80

# Ejecutamos FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]