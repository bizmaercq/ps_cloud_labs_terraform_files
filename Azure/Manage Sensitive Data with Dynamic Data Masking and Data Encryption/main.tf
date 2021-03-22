provider "azurerm" {
  skip_provider_registration = true
  features {
    
  }
}

data "azurerm_client_config" "current" {

}

resource "azurerm_resource_group" "lab_resource_group" {
  name     = "globomantics_rg"
  location = "eastus"
}

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
