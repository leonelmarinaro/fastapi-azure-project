# FastAPI Azure Project

Este proyecto implementa una aplicación web utilizando FastAPI, desplegada en Azure con infraestructura gestionada por Terraform. Incluye pipelines de CI/CD configurados con Azure DevOps.

## Estructura del Proyecto

```
fastapi-azure-project/
├── azure-pipelines.yml    # Configuración de CI/CD para Azure Pipelines
├── app/                   # Código de la aplicación FastAPI
│   ├── Dockerfile         # Imagen Docker para la aplicación
│   ├── main.py            # Punto de entrada de la aplicación
│   ├── pyproject.toml     # Dependencias y configuración de Python
│   └── README.md          # Documentación específica de la app (vacío)
├── infra/                 # Infraestructura como código con Terraform
│   ├── main.tf            # Recursos principales de Azure
│   ├── outputs.tf         # Salidas de Terraform
│   ├── terraform.tfvars   # Variables de configuración (ignoradas en Git)
│   └── variables.tf       # Definiciones de variables
└── .gitignore             # Archivos ignorados por Git
```

## Requisitos

- Python 3.8+
- Docker
- Terraform 1.0+
- Cuenta de Azure con permisos para crear recursos
- Azure DevOps para CI/CD (opcional)

## Instalación y Configuración

### 1. Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd fastapi-azure-project
```

### 2. Configurar el entorno virtual
```bash
python -m venv .venv
source .venv/bin/activate  # En Windows: .venv\Scripts\activate
pip install -r app/requirements.txt  # O usar pyproject.toml
```

### 3. Configurar Terraform
- Edita `infra/terraform.tfvars` con tus valores de Azure (asegúrate de no commitear este archivo).
- Inicializa Terraform:
  ```bash
  cd infra
  terraform init
  terraform plan
  terraform apply
  ```

## Ejecución Local

### Ejecutar la aplicación
```bash
cd app
uvicorn main:app --reload
```
Accede a http://localhost:8000/docs para ver la documentación interactiva de la API.

### Ejecutar con Docker
```bash
cd app
docker build -t fastapi-app .
docker run -p 8000:8000 fastapi-app
```

## Despliegue

### Usando Azure Pipelines
- Configura un pipeline en Azure DevOps usando `azure-pipelines.yml`.
- Asegúrate de tener los service connections configurados para Azure y Docker.

### Despliegue manual
1. Construye la imagen Docker.
2. Despliega en Azure Container Instances o App Service usando los recursos de Terraform.

## Contribución

1. Crea una rama para tu feature.
2. Realiza tus cambios.
3. Ejecuta tests si existen.
4. Envía un pull request.

## Licencia

Este proyecto está bajo la licencia MIT.</content>
<parameter name="filePath">c:\Users\marin\Documents\Platzi\fastapi-azure-project\README.md