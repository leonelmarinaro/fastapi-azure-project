import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy import create_engine, text

app = FastAPI()

# Leemos la URL de la DB desde las variables de entorno
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@localhost/db")


# --- API ENDPOINTS ---
@app.get("/api/")
def read_root():
    return {"estado": "Aplicación (Back+Front) corriendo en una sola Container App 🚀"}


@app.get("/api/db-test")
def test_db():
    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as connection:
            result = connection.execute(text("SELECT version();"))
            version = result.fetchone()[0]
        return {"estado_db": "Conectado exitosamente", "version": version}
    except Exception as e:
        return {"estado_db": "Error de conexión", "detalle": str(e)}


# --- FRONTEND (REACT) ---
# 1. Montar los assets estáticos (JS, CSS) generados por Vite
# La carpeta "static/assets" se creará en el Dockerfile al copiar el build
if os.path.exists("static/assets"):
    app.mount("/assets", StaticFiles(directory="static/assets"), name="assets")


# 2. Servir index.html para cualquier otra ruta (SPA Routing)
# IMPORTANTE: Colocar esto AL FINAL para no bloquear /api/
@app.get("/{full_path:path}")
async def serve_react_app(full_path: str):
    # Si intentan acceder a una API que no existe, devolvemos 404
    if full_path.startswith("api"):
        return {"error": "API endpoint not found"}, 404

    # Para todo lo demás, devolvemos el index.html de React
    if os.path.exists("static/index.html"):
        return FileResponse("static/index.html")

    return {"message": "Frontend no encontrado. Asegúrate de haber ejecutado el build."}
