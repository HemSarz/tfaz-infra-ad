data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}


data "azurerm_storage_account" "stg" {
  name                = azurerm_storage_account.tfaz-stg-infra.name
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  depends_on          = [azurerm_storage_account.tfaz-stg-infra]
}

output "STGPass" {
  value     = data.azurerm_storage_account.stg.primary_access_key
  sensitive = true
}


data "azurerm_storage_container" "cont-name-bcknd" {
  name                 = azurerm_storage_container.tfaz-cont-infra.name
  storage_account_name = azurerm_storage_account.tfaz-stg-infra.name
}

data "azuread_application" "tfazsp" {
  display_name = azuread_application.tfazsp.display_name

  depends_on = [azuread_application.tfazsp]
}