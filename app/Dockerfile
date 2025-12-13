FROM python:3.9-slim

# 1. Traemos uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# 2. Copiamos PRIMERO los archivos de definición (para caché)
COPY pyproject.toml uv.lock ./

# 3. Instalamos las dependencias
# --system: Instala en el python global del contenedor
# --no-dev: No instala dependencias de desarrollo (como pytest)
RUN uv pip install --system --no-cache .

# 4. Copiamos el resto del código
COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]