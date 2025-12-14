FROM python:3.12-slim

# 1. Traemos uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# 2. Copiamos PRIMERO los archivos de definición (para caché)
# IMPORTANTE: Copiamos README.md porque pyproject.toml lo referencia
COPY pyproject.toml uv.lock README.md ./

# 3. Instalamos las dependencias
# --system: Instala en el python global del contenedor
# --no-dev: No instala dependencias de desarrollo (como pytest)
# Usamos `uv sync` si queremos gestionar entornos o `uv pip install` directamente.
# Dado que `pyproject.toml` es estándar, `uv pip install -r pyproject.toml` funciona si generamos requirements,
# pero `uv pip install .` instala el proyecto actual y sus dependencias.
# Para asegurar que se instalan solo las dependencias sin instalar el paquete en sí (si no es librería),
# a veces es mejor usar `uv pip install --system -r pyproject.toml` si tuviéramos requirements.
# Con uv moderno:
RUN uv pip install --system --no-cache .

# 4. Copiamos el resto del código
COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]