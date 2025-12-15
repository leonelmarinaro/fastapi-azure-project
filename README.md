# FastAPI Azure Project: Full Stack Edition

Este proyecto implementa una arquitectura **Full Stack Unificada** en Azure utilizando servicios "Low Cost" (Capa Gratuita o Burstable) para pruebas y desarrollo.

## Arquitectura

- **Aplicación Unificada:** FastAPI (Python) + React (Vite) + Nginx (Reverse Proxy) en un solo contenedor. Desplegado en Azure Container Apps (Ingress Externo).
- **Base de Datos:** Azure Database for PostgreSQL - Flexible Server (B1ms - Burstable).
- **Infraestructura:** Gestionada con **Terraform**.
- **CI/CD:** GitHub Actions.

## Estructura del Proyecto

```
fastapi-azure-project/
├── app/                   # Backend FastAPI
│   ├── Dockerfile         # Usa `uv` para dependencias
│   ├── main.py            # API
│   ├── pyproject.toml     # Definición de dependencias
├── frontend/              # Frontend React
│   ├── Dockerfile         # Multi-stage build (Node -> Nginx)
│   ├── nginx.conf.template # Config proxy reverso
│   └── src/               # Código React
├── infra/                 # Terraform
│   ├── main.tf            # Recursos Azure (App Unificada + DB + Red)
│   └── variables.tf       # Variables parametrizables
├── scripts/               # Scripts de utilidad
│   └── setup_tf_state.sh  # Script para crear Storage Account de Terraform
├── .github/workflows/     # Workflows de GitHub Actions
│   ├── deploy.yml         # CI/CD completo
│   └── destroy-infrastructure.yml # Destruir recursos
└── Dockerfile             # Imagen unificada
```

## Guía de Configuración Inicial

Para desplegar este proyecto, necesitas configurar GitHub y Azure.

### 1. Prerrequisitos
- Cuenta de Azure activa.
- Repositorio en GitHub.
- Cuenta de Docker Hub.
- Azure CLI instalado localmente (para scripts iniciales).

### 2. Configurar Secrets en GitHub
En tu repositorio de GitHub (Settings > Secrets and variables > Actions):
- **AZURE_CREDENTIALS**: Credenciales del Service Principal (JSON).
- **DOCKER_USERNAME**: Tu usuario de Docker Hub.
- **DOCKER_PASSWORD**: Tu contraseña de Docker Hub.
- **DB_PASSWORD**: Contraseña para la base de datos PostgreSQL.
- **TF_STATE_RG**: Nombre del Resource Group del Storage Account para Terraform.
- **TF_STATE_STORAGE**: Nombre del Storage Account.
- **TF_STATE_CONTAINER**: Nombre del contenedor (ej. tfstate).

### 3. Configurar el Estado Remoto de Terraform
Para que Terraform recuerde la infraestructura entre ejecuciones, necesitamos un Storage Account.
1. Abre una terminal con Azure CLI logueado (`az login`).
2. Ejecuta el script de ayuda (o crea los recursos manualmente):
   ```bash
   chmod +x scripts/setup_tf_state.sh
   ./scripts/setup_tf_state.sh
   ```
3. Actualiza los secrets en GitHub con los valores generados.

### 4. Ejecutar el Workflow
Haz push a `main` o `dev`. El workflow en `.github/workflows/deploy.yml` se disparará automáticamente:
1. Construirá la imagen Docker unificada.
2. Desplegará la infraestructura con Terraform.
3. Actualizará la Container App con la nueva imagen.

Para ejecutar manualmente, ve a Actions > CI/CD Pipeline > Run workflow.

## Desarrollo Local

### Aplicación Unificada
```bash
# Construir imagen local
docker build -t mi-app-local .

# Ejecutar sin DB
docker run -p 8080:80 mi-app-local

# Ejecutar con DB de Azure (reemplaza <TU_PASSWORD> y <TU_DB>)
docker run -p 8080:80 \
  -e DATABASE_URL="postgresql://adminuser:<TU_PASSWORD>@psql-fastapi-demo1-prod.postgres.database.azure.com:5432/<TU_DB>?sslmode=require" \
  mi-app-local
```

### Desarrollo Separado (Opcional)
#### Frontend
```bash
cd frontend
npm install
npm run dev
```
*Nota: Configura proxy en vite.config.js para backend local.*

#### Backend
```bash
cd app
uv sync
uv run uvicorn main:app --reload
```
*Nota: Para conectar a DB de Azure, configura `DATABASE_URL` en variables de entorno.*