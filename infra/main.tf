terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- GRUPO DE RECURSOS ---
resource "azurerm_resource_group" "rg" {
  name     = "rg-fastapi-demo"
  location = "East US" # Región económica
}

# --- BASE DE DATOS POSTGRES (Capa B1ms - Burstable) ---
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "psql-fastapi-${var.project_suffix}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.db_user
  administrator_password = var.db_pass
  sku_name               = "B_Standard_B1ms" # <--- LA CLAVE DEL AHORRO
  storage_mb             = 32768
  
  # Importante para conectar desde Container Apps sin VNET compleja
  public_network_access_enabled = true 
}

# Regla de Firewall: Permitir acceso a servicios de Azure
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Regla de Firewall: Permitir TODAS las IPs (SOLO PARA PRUEBAS RÁPIDAS)
# En producción, pon aquí solo la IP de tu casa o usa VNET.
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# --- CONTAINER APPS ENVIRONMENT ---
resource "azurerm_container_app_environment" "env" {
  name                = "aca-env-${var.project_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# --- CONTAINER APP (FastAPI) ---
resource "azurerm_container_app" "app" {
  name                         = "app-fastapi-${var.project_suffix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 0 # <--- Escala a CERO si no se usa (Ahorro total)
    max_replicas = 1
    
    container {
      name   = "fastapi-container"
      image  = "${var.docker_image}" # La imagen que subiremos a Docker Hub
      cpu    = 0.25
      memory = "0.5Gi"
      
      env {
        name  = "DATABASE_URL"
        # Construimos la URL de conexión dinámicamente
        value = "postgresql://${var.db_user}:${var.db_pass}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/postgres"
      }
    }
  }
  
  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}