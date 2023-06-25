data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}