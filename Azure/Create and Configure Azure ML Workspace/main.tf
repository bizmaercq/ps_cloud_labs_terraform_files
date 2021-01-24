provider "azurerm" {
  skip_provider_registration = true
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "lab_resource_group" {
  name     = "ps-resource-group"
  location = "eastus"
}

resource "azurerm_application_insights" "lab_app_insights" {
  name                = "ps0aml0appinsights"
  location            = azurerm_resource_group.lab_resource_group.location
  resource_group_name = azurerm_resource_group.lab_resource_group.name
  application_type    = "web"
}

resource "azurerm_key_vault" "lab_key_vault" {
  name                = "mlkeyvault${formatdate("YYYYMMDDhhmmss",timestamp())}" # concatenate current datetime to form unique resource name
  location            = azurerm_resource_group.lab_resource_group.location
  resource_group_name = azurerm_resource_group.lab_resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
}

resource "azurerm_storage_account" "lab_storage_account" {
  name                     = "mlstorage${formatdate("YYYYMMDDhhmmss",timestamp())}" # concatenate current datetime to form unique resource name
  location                 = azurerm_resource_group.lab_resource_group.location
  resource_group_name      = azurerm_resource_group.lab_resource_group.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_machine_learning_workspace" "lab_machine_learning_workspace" {
  name                    = "ps-aml-workspace"
  location                = azurerm_resource_group.lab_resource_group.location
  resource_group_name     = azurerm_resource_group.lab_resource_group.name
  application_insights_id = azurerm_application_insights.lab_app_insights.id
  key_vault_id            = azurerm_key_vault.lab_key_vault.id
  storage_account_id      = azurerm_storage_account.lab_storage_account.id

  identity {
    type = "SystemAssigned"
  }
}