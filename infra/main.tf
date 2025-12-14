terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Backend configuration for remote state
  # For local testing, use local backend.
  # In pipeline, use -backend-config to initialize remote backend.
  # backend "azurerm" {
  #   # resource_group_name  = "rg-terraform-state"
  #   # storage_account_name = "sttfstate${unique_id}"
  #   # container_name       = "tfstate"
  #   # key                  = "terraform.tfstate"
  # }
  backend "local" {}
}

provider "azurerm" {
  features {}
}

# --- GRUPO DE RECURSOS ---
resource "azurerm_resource_group" "rg" {
  name     = "rg-fastapi-${var.project_suffix}"
  # location = "East US"
  location = "West Europe"  # Cambiado para evitar restricciones en East US
}

# --- BASE DE DATOS POSTGRES (Capa B1ms - Burstable) ---
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "psql-fastapi-${var.project_suffix}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.db_user
  administrator_password = var.db_pass
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  zone                   = "1"
  
  public_network_access_enabled = true 
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

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

# --- CONTAINER APP: BACKEND (Internal Ingress) ---
resource "azurerm_container_app" "backend" {
  name                         = "app-backend-${var.project_suffix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 1 # Temporalmente 1 para debugging, force new revision
    max_replicas = 1
    revision_suffix = "v2"
    
    container {
      name   = "fastapi-container"
      image  = var.backend_image
      cpu    = 0.25
      memory = "0.5Gi"
      
      env {
        name  = "DATABASE_URL"
        value = "postgresql://${var.db_user}:${var.db_pass}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/postgres"
      }
    }
  }
  
  ingress {
    external_enabled = false
    target_port      = 80
    transport        = "auto" # Explicitly set auto (or http) to avoid defaulting issues
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
    allow_insecure_connections = true
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}

# --- CONTAINER APP: FRONTEND (External Ingress) ---
resource "azurerm_container_app" "frontend" {
  name                         = "app-frontend-${var.project_suffix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 0 # Scale to Zero
    max_replicas = 1
    revision_suffix = "v2"

    container {
      name   = "frontend-container"
      image  = var.frontend_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "BACKEND_URL"
        # URL interna completa del backend
        value = "http://app-backend-prueba1.internal.nicesky-61ea5a0e.westeurope.azurecontainerapps.io"
      }
    }
  }

  ingress {
    external_enabled = true # Public Access
    target_port      = 80
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}
