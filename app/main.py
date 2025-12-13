import os
from fastapi import FastAPI
from sqlalchemy import create_engine, text

app = FastAPI()

# Leemos la URL de la DB desde las variables de entorno (Inyectadas por Azure)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@localhost/db")


@app.get("/")
def read_root():
    return {"estado": "Aplicación corriendo en Azure Container Apps 🚀"}


@app.get("/db-test")
def test_db():
    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as connection:
            result = connection.execute(text("SELECT version();"))
            version = result.fetchone()[0]
        return {"estado_db": "Conectado exitosamente", "version": version}
    except Exception as e:
        return {"estado_db": "Error de conexión", "detalle": str(e)}
