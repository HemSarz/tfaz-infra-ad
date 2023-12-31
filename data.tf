data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}


data "azurerm_storage_account" "tfaz-stg-infra" {
  name                = azurerm_storage_account.tfaz-stg-infra.name
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  depends_on          = [azurerm_storage_account.tfaz-stg-infra]
}

output "STGPass" {
  value     = data.azurerm_storage_account.tfaz-stg-infra.primary_access_key
  sensitive = true
}


data "azurerm_storage_container" "cont-name-bcknd" {
  name                 = azurerm_storage_container.tfaz-cont-infra.name
  storage_account_name = azurerm_storage_account.tfaz-stg-infra.name
}

data "azuread_application" "tfazsp" {
  display_name = var.tfaz-spn

  depends_on = [azuread_application.tfazsp]
}