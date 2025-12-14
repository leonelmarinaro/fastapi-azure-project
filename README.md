# FastAPI Azure Project: Full Stack Edition

Este proyecto implementa una arquitectura **Full Stack** en Azure utilizando servicios "Low Cost" (Capa Gratuita o Burstable) para pruebas y desarrollo.

## Arquitectura

- **Frontend:** React (Vite) + Nginx (Reverse Proxy). Desplegado en Azure Container Apps (Ingress Externo).
- **Backend:** FastAPI (Python). Desplegado en Azure Container Apps (Ingress Interno).
- **Base de Datos:** Azure Database for PostgreSQL - Flexible Server (B1ms - Burstable).
- **Infraestructura:** Gestionada con **Terraform**.
- **CI/CD:** Azure DevOps Pipelines.

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
│   ├── main.tf            # Recursos Azure (Apps + DB + Red)
│   └── variables.tf       # Variables parametrizables
├── scripts/               # Scripts de utilidad
│   └── setup_tf_state.sh  # Script para crear Storage Account de Terraform
└── azure-pipelines.yml    # Pipeline CI/CD completo
```

## Guía de Configuración Inicial

Para desplegar este proyecto, necesitas configurar Azure DevOps y Azure.

### 1. Prerrequisitos
- Cuenta de Azure activa.
- Cuenta de Azure DevOps y un proyecto creado.
- Cuenta de Docker Hub.
- Azure CLI instalado localmente (para scripts iniciales).

### 2. Configurar Azure Service Connections
En tu proyecto de Azure DevOps (Project Settings -> Service connections):
1.  **Docker Registry:** Crea una conexión llamada `DockerHubConn` apuntando a tu Docker Hub.
2.  **Azure Resource Manager:** Crea una conexión llamada `AzureRMConn` (Service Principal) con permisos sobre tu suscripción.

### 3. Configurar el Estado Remoto de Terraform
Para que Terraform recuerde la infraestructura entre ejecuciones del pipeline, necesitamos un Storage Account.
1. Abre una terminal con Azure CLI logueado (`az login`).
2. Ejecuta el script de ayuda (o crea los recursos manualmente):
   ```bash
   chmod +x scripts/setup_tf_state.sh
   ./scripts/setup_tf_state.sh
   ```
3. Toma nota de los valores que imprime el script (`TF_STATE_RG`, `TF_STATE_STORAGE_ACCOUNT`, etc.).

### 4. Configurar el Pipeline
1. Ve a **Pipelines** en Azure DevOps y crea uno nuevo seleccionando este repositorio y el archivo `azure-pipelines.yml`.
2. Antes de correrlo, edita las **Variables** del pipeline (botón "Variables" o "Library" -> "Variable Groups"):
   - **DB_PASSWORD**: Contraseña para la base de datos (márcala como secreto/candado).
   - Edita directamente el archivo `azure-pipelines.yml` (o usa variables) para actualizar:
     - `dockerId`: Tu usuario de Docker Hub.
     - `tfStateStorageAccount`: El nombre generado en el paso 3.
     - `projectSuffix`: Un sufijo único para tus recursos (ej. "demo-juan").

### 5. Ejecutar
Haz commit y push. El pipeline se disparará automáticamente:
1.  Construirá las imágenes Docker.
2.  Desplegará la infraestructura con Terraform.
3.  Actualizará las Container Apps con las nuevas imágenes.

## Desarrollo Local

### Frontend
```bash
cd frontend
npm install
npm run dev
```
*Nota: Para que funcione localmente con el backend, configura el proxy en vite.config.js o corre el backend en el puerto esperado.*

### Backend
```bash
cd app
# Usando uv
uv sync
uv run uvicorn main:app --reload
```

## Costos (Estimación Low Cost)
- **Container Apps:** Configurado para escalar a 0 (`min_replicas = 0`). Solo pagas por segundos de ejecución activa.
- **Postgres Flexible Server:** Tier B1ms. Es la opción más económica de instancia flexible (~$15/mes aprox si está encendida 24/7, pero es burstable). *Recomendación: Detener la base de datos cuando no se use.*


Para pruebas locales:
```bash
docker build -f docker-compose.yaml -t mi-app-local .
```