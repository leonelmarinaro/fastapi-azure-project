#!/bin/bash
# Scripts to bootstrap Azure Infrastructure for Terraform State

# Variables - Puedes cambiarlas
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)" # Nombre único
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Crear Resource Group
echo "Creando Resource Group: $RESOURCE_GROUP_NAME..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Crear Storage Account
echo "Creando Storage Account: $STORAGE_ACCOUNT_NAME..."
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Crear Container para el estado
echo "Creando Container: $CONTAINER_NAME..."
KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $KEY

echo "=========================================="
echo "Configuración completa."
echo "Variables para configurar en Azure DevOps (Variable Group o Pipeline Vars):"
echo "TF_STATE_RG: $RESOURCE_GROUP_NAME"
echo "TF_STATE_STORAGE_ACCOUNT: $STORAGE_ACCOUNT_NAME"
echo "TF_STATE_CONTAINER: $CONTAINER_NAME"
echo "TF_STATE_KEY: terraform.tfstate"
echo "=========================================="
