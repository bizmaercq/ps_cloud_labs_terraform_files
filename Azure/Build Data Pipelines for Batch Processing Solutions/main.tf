provider "azurerm" {
  skip_provider_registration = true
  features {
    
  }
}

data "azurerm_client_config" "current" {

}

# Azure resource group
resource "azurerm_resource_group" "lab_resource_group" {
  name     = "globomantics_rg"
  location = "eastus"
}

# Azure SQL server
resource "azurerm_sql_server" "lab_server" {
  name                         = "globomantics-prod-server-${formatdate("YYYYMMDDhhmmss",timestamp())}" # concatenate current datetime to form unique resource name
  resource_group_name          = azurerm_resource_group.lab_resource_group.name
  location                     = azurerm_resource_group.lab_resource_group.location
  version                      = "12.0"
  administrator_login          = "globomantics_admin"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "production"
  }
}

resource "azurerm_sql_firewall_rule" "lab_server_firewall_rule" {
  name                = "globomantics_firewall_rule"
  resource_group_name = azurerm_resource_group.lab_resource_group.name
  server_name         = azurerm_sql_server.lab_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}


# Azure SQL database
resource "azurerm_sql_database" "lab_sql_database" {
  name                = "globomanticsDB"
  resource_group_name = azurerm_resource_group.lab_resource_group.name
  location            = azurerm_resource_group.lab_resource_group.location
  server_name         = azurerm_sql_server.lab_server.name
  edition             = "Basic"

  tags = {
    environment = "production"
  }
}

data "azurerm_sql_database" "lab_sql_database" {
  name                = azurerm_sql_database.lab_sql_database.name
  server_name         = azurerm_sql_server.lab_server.name
  resource_group_name = azurerm_resource_group.lab_resource_group.name
}

output "lab_sql_database_id" {
  value = data.azurerm_sql_database.lab_sql_database.id
}


# Azure data lake gen 2
resource "azurerm_storage_account" "lab_data_lake_gen2" {
  name                     = "adl4gb${formatdate("YYYYMMDDhhmmss",timestamp())}" # concatenate current datetime to form unique resource name
  resource_group_name      = azurerm_resource_group.lab_resource_group.name
  location                 = azurerm_resource_group.lab_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "lab_data_lake_gen2_filesystem" {
  name               = "logs"
  storage_account_id = azurerm_storage_account.lab_data_lake_gen2.id
}


# Azure data factory
resource "azurerm_data_factory" "lab_data_factory" {
  name                = "adf4globomantics"
  location            = azurerm_resource_group.lab_resource_group.location
  resource_group_name = azurerm_resource_group.lab_resource_group.name
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "lab_data_factory_linked_service_azure_sql_database" {
  name                = "AZ_SQL_DATABASE_LS"
  resource_group_name = azurerm_resource_group.lab_resource_group.name
  data_factory_name   = azurerm_data_factory.lab_data_factory.name
  connection_string   = "data source=${azurerm_sql_server.lab_server.fully_qualified_domain_name};initial catalog=${azurerm_sql_database.lab_sql_database.name};user id=${azurerm_sql_server.lab_server.administrator_login};Password=${azurerm_sql_server.lab_server.administrator_login_password};integrated security=False;encrypt=True;connection timeout=30"
}