# Arquitectura de la Aplicación en Azure

Esta aplicación es una aplicación full-stack compuesta por un backend en FastAPI (Python) y un frontend en React (JavaScript), empaquetados en un contenedor unificado. La infraestructura se despliega en Azure utilizando Terraform para la gestión de recursos. A continuación, se detallan los servicios de Azure necesarios para que la aplicación funcione correctamente.

## Servicios de Azure Utilizados

### 1. **Azure Resource Group**
   - **Descripción**: Un contenedor lógico que agrupa todos los recursos relacionados con la aplicación. Facilita la gestión, el monitoreo y la facturación de los recursos.
   - **Recurso**: `azurerm_resource_group.rg`
   - **Ubicación**: West US 2
   - **Nombre**: `rg-fastapi-{project_suffix}-{environment}`

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
   - **Nombre**: `aca-env-{project_suffix}-{environment}`

### 4. **Azure Container Apps (Aplicación Unificada)**
   - **Descripción**: Ejecuta el contenedor unificado que incluye tanto el backend FastAPI como el frontend React (servido por Nginx como reverse proxy). Tiene ingreso externo habilitado para que los usuarios puedan acceder a la aplicación web.
   - **Recurso**: `azurerm_container_app.app`
   - **Configuración**:
     - Imagen: `var.backend_image` (imagen Docker unificada alojada en Docker Hub)
     - Recursos: 0.25 CPU, 0.5 GiB RAM
     - Escalado: Mínimo 0 (scale to zero), máximo 1 réplica
     - Variables de entorno: `DATABASE_URL` para conectar a PostgreSQL
     - Puerto: 80 (expuesto externamente)
   - **Acceso**: Público

## Arquitectura General

- **Aplicación Unificada**: Backend y frontend corren en el mismo contenedor. El frontend se sirve desde Nginx, que actúa como reverse proxy para el backend FastAPI.
- **Base de Datos**: PostgreSQL Flexible Server, accesible desde la aplicación unificada.
- **Networking**: La Container App es externa; maneja tanto el frontend (público) como el backend (interno al contenedor).
- **Escalado**: La app puede escalar a cero para optimizar costos.

## Servicios Adicionales Considerados

- **Azure Container Registry (ACR)**: Aunque no se define en el Terraform actual, se recomienda para almacenar imágenes de contenedores de forma privada en lugar de Docker Hub.
- **Azure Storage Account**: Utilizado para el estado remoto de Terraform (backend configurado en el workflow de GitHub Actions).
- **GitHub Actions**: Para CI/CD, definido en `.github/workflows/deploy.yml`, que construye y despliega la imagen unificada.

## Consideraciones de Seguridad y Producción

- **Acceso a la Base de Datos**: Actualmente permite acceso público con reglas de firewall abiertas. En producción, configura acceso privado usando VNet y Private Endpoints.
- **Autenticación**: Implementa Azure Active Directory (AAD) para usuarios si es necesario.
- **Monitoreo**: Usa Azure Monitor y Application Insights para logs y métricas.
- **Backup**: Configura backups automáticos para PostgreSQL.

Esta arquitectura permite una implementación serverless y escalable, aprovechando las capacidades de Azure Container Apps para reducir costos operativos.