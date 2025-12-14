# Arquitectura de la Aplicación en Azure

Esta aplicación es una aplicación full-stack compuesta por un backend en FastAPI (Python) y un frontend en React (JavaScript). La infraestructura se despliega en Azure utilizando Terraform para la gestión de recursos. A continuación, se detallan los servicios de Azure necesarios para que la aplicación funcione correctamente.

## Servicios de Azure Utilizados

### 1. **Azure Resource Group**
   - **Descripción**: Un contenedor lógico que agrupa todos los recursos relacionados con la aplicación. Facilita la gestión, el monitoreo y la facturación de los recursos.
   - **Recurso**: `azurerm_resource_group.rg`
   - **Ubicación**: East US
   - **Nombre**: `rg-fastapi-{project_suffix}`

### 2. **Azure Database for PostgreSQL Flexible Server**
   - **Descripción**: Base de datos PostgreSQL administrada por Azure, utilizada para almacenar los datos de la aplicación. Está configurada con SKU B_Standard_B1ms para un rendimiento burstable.
   - **Recursos**:
     - Servidor: `azurerm_postgresql_flexible_server.db`
     - Reglas de firewall: `azurerm_postgresql_flexible_server_firewall_rule.allow_azure` y `azurerm_postgresql_flexible_server_firewall_rule.allow_all`
   - **Configuración**:
     - Versión: 13
     - Almacenamiento: 32 GB
     - Acceso público habilitado (para desarrollo; en producción, considera acceso privado)
   - **Credenciales**: Administrador definido por variables (`db_user` y `db_pass`)

### 3. **Azure Container Apps Environment**
   - **Descripción**: Entorno que proporciona la infraestructura subyacente para ejecutar aplicaciones contenerizadas. Permite el escalado automático, balanceo de carga y networking interno.
   - **Recurso**: `azurerm_container_app_environment.env`
   - **Nombre**: `aca-env-{project_suffix}`

### 4. **Azure Container Apps (Backend)**
   - **Descripción**: Ejecuta el contenedor del backend FastAPI. Está configurado con ingreso interno (no accesible externamente), permitiendo comunicación solo desde el entorno de Container Apps.
   - **Recurso**: `azurerm_container_app.backend`
   - **Configuración**:
     - Imagen: `var.backend_image` (ej. Docker Hub)
     - Recursos: 0.25 CPU, 0.5 GiB RAM
     - Escalado: Mínimo 0 (scale to zero), máximo 1 réplica
     - Variables de entorno: `DATABASE_URL` para conectar a PostgreSQL
     - Puerto: 80
   - **Acceso**: Interno al entorno

### 5. **Azure Container Apps (Frontend)**
   - **Descripción**: Ejecuta el contenedor del frontend React. Tiene ingreso externo habilitado para que los usuarios puedan acceder a la aplicación web.
   - **Recurso**: `azurerm_container_app.frontend`
   - **Configuración**:
     - Imagen: `var.frontend_image` (ej. Docker Hub)
     - Recursos: 0.25 CPU, 0.5 GiB RAM
     - Escalado: Mínimo 0 (scale to zero), máximo 1 réplica
     - Variables de entorno: `BACKEND_URL` apuntando al backend interno
     - Puerto: 80
   - **Acceso**: Público

## Arquitectura General

- **Frontend**: Accesible públicamente a través de Azure Container Apps. Se comunica con el backend utilizando la URL interna (`http://app-backend-{project_suffix}`).
- **Backend**: Ejecuta la lógica de negocio y API RESTful. Conecta a la base de datos PostgreSQL.
- **Base de Datos**: PostgreSQL Flexible Server, accesible desde el backend.
- **Networking**: El backend es interno; el frontend es externo. El entorno de Container Apps maneja el tráfico interno.
- **Escalado**: Ambos servicios pueden escalar a cero para optimizar costos.

## Servicios Adicionales Considerados

- **Azure Container Registry (ACR)**: Aunque no se define en el Terraform actual, se recomienda para almacenar imágenes de contenedores de forma privada en lugar de Docker Hub.
- **Azure Storage Account**: Utilizado para el estado remoto de Terraform (backend configurado en el pipeline de CI/CD).
- **Azure Pipelines**: Para CI/CD, definido en `azure-pipelines.yml`, que construye y despliega las imágenes.

## Consideraciones de Seguridad y Producción

- **Acceso a la Base de Datos**: Actualmente permite acceso público con reglas de firewall abiertas. En producción, configura acceso privado usando VNet y Private Endpoints.
- **Autenticación**: Implementa Azure Active Directory (AAD) para usuarios si es necesario.
- **Monitoreo**: Usa Azure Monitor y Application Insights para logs y métricas.
- **Backup**: Configura backups automáticos para PostgreSQL.

Esta arquitectura permite una implementación serverless y escalable, aprovechando las capacidades de Azure Container Apps para reducir costos operativos.