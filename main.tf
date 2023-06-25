###########################################################
# RESOURCE GROUP
###########################################################

resource "random_id" "tfaz-rg-aad-rndmn" {
  byte_length = 3
  prefix      = var.tfaz-rg-infra-prefix
}

resource "azurerm_resource_group" "tfaz-rg-aad" {
  name     = random_id.tfaz-rg-aad-rndmn.hex
  location = var.tfaz-rg-loc

  tags = {
    environment = var.env-tag-infra
  }
}

###########################################################
# STORAGE ACCOUNT
###########################################################

resource "azurerm_storage_account" "tfaz-stg-infra" {
  name                     = var.tfaz-stg-infra
  resource_group_name      = azurerm_resource_group.tfaz-rg-aad.name
  location                 = var.tfaz-rg-loc
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.env-tag-infra
  }
}

resource "azurerm_storage_container" "tfaz-cont-infra" {
  name                  = var.tfaz-stg-cont
  storage_account_name  = azurerm_storage_account.tfaz-stg-infra.name
  container_access_type = "private"
}

###########################################################
# KEY VAULT
###########################################################

resource "random_id" "tfaz-kv-infra-rndn" {
  byte_length = 4
  prefix      = var.tfaz-kv-name
}

resource "azurerm_key_vault" "tfaz-kv-infra" {
  name                        = random_id.tfaz-kv-infra-rndn.hex
  resource_group_name         = azurerm_resource_group.tfaz-rg-aad.name
  location                    = var.tfaz-rg-loc
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions     = ["Get", "List", "Backup"]
    secret_permissions  = ["Get", "List", "Set"]
    storage_permissions = ["Get", "List", "Set"]
  }
}

###########################################################
# KEY VAULT SECRET
###########################################################

###########################################################
# SERVICE PRINCIPAL | APPLICATION (Default)
###########################################################
resource "azuread_service_principal" "tfaz-spn-infra" {
  application_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36"
}

###########################################################
# VNET 1
###########################################################

resource "azurerm_virtual_network" "tfaz-vnet1" {
  name                = var.tfaz-vnet1-name
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  location            = var.tfaz-rg-loc
  address_space       = [var.tfaz-vnet1-addr-space]
  dns_servers         = [var.tfaz-dns-servers]
}
###########################################################
# SUBNET 1
###########################################################

resource "azurerm_subnet" "tfaz-vnet1-subn1" {
  name                 = var.tfaz-vnet1-name
  resource_group_name  = azurerm_resource_group.tfaz-rg-aad.name
  virtual_network_name = azurerm_virtual_network.tfaz-vnet1.name
  address_prefixes     = [var.tfaz-vnet1-subn1-range]
}

resource "azurerm_subnet" "tfaz-vnet1-subn2" {
  name                 = var.tfaz-vnet1-subn2-name
  resource_group_name  = azurerm_resource_group.tfaz-rg-aad.id
  virtual_network_name = azurerm_virtual_network.tfaz-vnet1.name
  address_prefixes     = [var.tfaz-bnet11-subn2-range]
}

###########################################################
# Network Security Group
###########################################################

resource "azurerm_network_security_group" "tfaz-nsg-infra" {
  name                = var.tfaz-nsg-infra
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  location            = var.tfaz-rg-loc
}

resource "azurerm_network_security_rule" "AllowRDPClient" {
  name                        = var.tfaz-nsg-infra
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "$(chomp(data.http.icanhazip.body))"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfaz-rg-aad.name
  network_security_group_name = azurerm_network_security_group.tfaz-nsg-infra.name
}


###########################################################
# NSG Association
###########################################################

resource "azurerm_subnet_network_security_group_association" "tfaz-vnet1-subn1-assoc-dc-vm" {
  subnet_id                 = azurerm_subnet.tfaz-vnet1-subn1.id
  network_security_group_id = azurerm_network_security_group.tfaz-nsg-infra.id
}

###########################################################
# 
###########################################################

###########################################################
# VM User | Pass | Group
###########################################################

resource "random_password" "tfaz-vm-pass" {
  length  = 15
  special = true
  upper   = true
  lower   = true
}

resource "azuread_group" "tfaz-dc01-group" {
  display_name     = "tfaz-dc01-admins"
  members          = [azuread_user.VMAdminDC01.object_id]
  security_enabled = true
}

resource "azuread_user" "VMAdminDC01" {
  user_principal_name = "VMAdminDC01@hemensarzalihotmail.onmicrosoft.com"
  display_name        = "VMAdminDC01"
  password            = random_password.tfaz-vm-pass.result
}

###########################################################
# Domain Controller VM        
###########################################################

###########################################################
# DOmain Controller Data Disk
###########################################################