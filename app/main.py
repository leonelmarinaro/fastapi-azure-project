import os

from fastapi import Body, FastAPI
from typing import Any
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from sqlalchemy import create_engine, text

app = FastAPI()

# Leemos la URL de la DB desde las variables de entorno
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@localhost/db")


# --- API ENDPOINTS ---
@app.get("/api/")
def read_root():
    return {"estado": "Aplicación (Back+Front) corriendo en una sola Container App 🚀"}


@app.get("/api/db-test")
def test_db() -> dict[str, Any]:
    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as connection:
            result = connection.execute(text("SELECT version();"))
            row = result.fetchone()
            version = row[0] if row else "No version found"
        return {"estado_db": "Conectado exitosamente", "version": version}
    except Exception as e:
        return {"estado_db": "Error de conexión", "detalle": str(e)}


class Customer(BaseModel):
    name: str
    description: str | None
    email: str
    age: int


@app.post("/api/customers/", response_model=dict[str, Customer | str])
async def create_customer(
    customer_data: Customer = Body(...),
) -> dict[str, Customer | str]:
    """
    Endpoint to create a new customer.

    This endpoint receives customer data in the request body and returns a response
    indicating the successful creation of the customer along with the provided customer data.

    Path:
        POST /api/customers/

    Request Body:
        customer_data (Customer): The data of the customer to be created.

    Response:
        200 OK: A dictionary containing:
            - "message" (str): A success message.
            - "cliente" (Customer): The data of the created customer.

    Raises:
        ValidationError: If the provided customer data does not match the expected schema.
    """
    return {"message": "Cliente creado exitosamente", "cliente": customer_data}


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
