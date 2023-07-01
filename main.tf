###########################################################
# RESOURCE GROUP
###########################################################

resource "azurerm_resource_group" "tfaz-rg-aad" {
  name     = var.tfaz-rg-name
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
  depends_on            = [azurerm_storage_account.tfaz-stg-infra]
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

resource "azurerm_key_vault_access_policy" "tfaz-spn-apkv" {
  key_vault_id = azurerm_key_vault.tfaz-kv-infra.id
  object_id    = azuread_application.tfazsp.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  depends_on   = [azuread_application.tfazsp, azurerm_key_vault.tfaz-kv-infra]

  key_permissions     = ["Get", "List", "Backup"]
  secret_permissions  = ["Get", "List", "Set"]
  storage_permissions = ["Get", "List", "Set"]
}

###########################################################
# KEY VAULT SECRET
###########################################################
resource "random_id" "tfaz-vm-pass-name" {
  byte_length = 3
  prefix      = var.tfaz-vm-sc-name
}
resource "azurerm_key_vault_secret" "vm-admin-pass" {
  name         = random_id.tfaz-vm-pass-name.hex
  value        = random_password.tfaz-vm-pass.result
  key_vault_id = azurerm_key_vault.tfaz-kv-infra.id
  depends_on   = [azurerm_key_vault.tfaz-kv-infra]
}

###########################################################
# SPN
###########################################################

resource "azuread_application" "tfazsp" {
  display_name = var.tfaz-spn
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "tfaz-spn" {
  application_id = azuread_application.tfazsp.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "tfazsp" {
  application_object_id = azuread_application.tfazsp.object_id
}

resource "azurerm_role_assignment" "main" {
  principal_id         = azuread_service_principal.tfaz-spn.object_id
  scope                = azurerm_key_vault.tfaz-kv-infra.id
  role_definition_name = "Contributor"
}

###########################################################
# VNET 1
###########################################################

resource "azurerm_virtual_network" "tfaz-vnet1" {
  name                = var.tfaz-vnet1-name
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  location            = var.tfaz-rg-loc
  address_space       = [var.tfaz-vnet1-addr-space]
  dns_servers         = var.tfaz-dns-servers-subn1
}

resource "azurerm_virtual_network" "tfaz-vnet2" {
  name                = var.tfaz-vnet1-subn2-name
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  location            = var.tfaz-rg-loc
  address_space       = [var.tfaz-vnet1-subn2-addr-space]
  dns_servers         = var.tfaz-dns-servers-subn2
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
  resource_group_name  = azurerm_resource_group.tfaz-rg-aad.name
  virtual_network_name = azurerm_virtual_network.tfaz-vnet2.name
  address_prefixes     = [var.tfaz-vnet1-subn2-addr-space]
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
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "${chomp(data.http.clientip.response_body)}/32"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.tfaz-nsg-infra.name
  resource_group_name         = azurerm_resource_group.tfaz-rg-aad.name
}

###########################################################
# NSG Association
###########################################################

resource "azurerm_subnet_network_security_group_association" "tfaz-vnet1-subn1-assoc-dc-vm" {
  subnet_id                 = azurerm_subnet.tfaz-vnet1-subn1.id
  network_security_group_id = azurerm_network_security_group.tfaz-nsg-infra.id
}

###########################################################
# Public IP
###########################################################

resource "azurerm_public_ip" "tfaz-pip-dc01" {
  name                = var.tfaz-pip-dc01
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name
  location            = var.tfaz-rg-loc
  sku                 = "Standard"
}

###########################################################
# Network Interface 
###########################################################

resource "azurerm_network_interface" "tfaz-dc01-intf" {
  name                = var.tfaz-pip-dc01
  location            = var.tfaz-rg-loc
  resource_group_name = azurerm_resource_group.tfaz-rg-aad.name

  ip_configuration {
    name                          = "dc01-nic"
    subnet_id                     = azurerm_subnet.tfaz-vnet1-subn1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.tfaz-prvip-dc01-subnet1
    public_ip_address_id          = azurerm_public_ip.tfaz-pip-dc01.id
  }

  tags = {
    environment = var.env-tag-infra
  }
}

###########################################################
# VM User | Pass | Group 
###########################################################

resource "random_password" "tfaz-vm-pass" {
  length           = 12
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_%@!#$"
}

resource "azuread_group" "tfaz-dc01-group" {
  display_name     = "tfaz-dc01-admins"
  members          = [azuread_user.VMAdminDC01.object_id]
  security_enabled = true
}

resource "azuread_user" "VMAdminDC01" {
  user_principal_name = "VMAdminDC01@hemensarzalihotmail.onmicrosoft.com"
  display_name        = var.tfaz-VMAdmin
  password            = random_password.tfaz-vm-pass.result
}

resource "azuread_directory_role" "GLBLAdmin" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_assignment" "sp_directory_role_assignment" {
  role_id             = azuread_directory_role.GLBLAdmin.template_id
  principal_object_id = azuread_user.VMAdminDC01.object_id
}

###########################################################
# Domain Controller VM        
###########################################################

resource "azurerm_windows_virtual_machine" "tfaz-dc01-vm" {
  name                  = var.tfaz-dc01
  location              = var.tfaz-rg-loc
  resource_group_name   = azurerm_resource_group.tfaz-rg-aad.name
  network_interface_ids = [azurerm_network_interface.tfaz-dc01-intf.id]
  size                  = var.vm_size
  admin_username        = azuread_user.VMAdminDC01.display_name
  admin_password        = azurerm_key_vault_secret.vm-admin-pass.value

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage-acc-type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = var.env-tag-infra
  }
}

###########################################################
# DOmain Controller Data Disk
###########################################################

resource "azurerm_managed_disk" "dc01-ntds" {
  name                 = var.tfaz-dc01
  location             = var.tfaz-rg-loc
  resource_group_name  = azurerm_resource_group.tfaz-rg-aad.name
  storage_account_type = var.storage-acc-type
  create_option        = "Empty"
  disk_size_gb         = "20"

  tags = {
    environment = var.env-tag-infra
  }
}


resource "azurerm_virtual_machine_data_disk_attachment" "dc01-ntds-attach" {
  managed_disk_id    = azurerm_managed_disk.dc01-ntds.id
  depends_on         = [azurerm_windows_virtual_machine.tfaz-dc01-vm, azurerm_managed_disk.dc01-ntds]
  virtual_machine_id = azurerm_windows_virtual_machine.tfaz-dc01-vm.id
  lun                = "10"
  caching            = "None"
}

###########################################################
# Format Managed Disk
###########################################################

resource "azurerm_virtual_machine_extension" "dc01-ad-exten" {
  name                       = var.vm-exten-dc01-ntds
  virtual_machine_id         = azurerm_windows_virtual_machine.tfaz-dc01-vm.id
  depends_on                 = [azurerm_virtual_machine_data_disk_attachment.dc01-ntds-attach, azurerm_storage_container.tfaz-cont-infra]
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.powershell}\""
  }
  SETTINGS
}

locals {
  generated_password = random_password.tfaz-vm-pass.result
  cmd01              = "Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter H | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'data' -Confirm:$false"
  cmd02              = "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools"
  cmd03              = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  cmd04              = "Import-Module ADDSDeployment, DnsServer"
  cmd05              = "Install-ADDSForest -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -DomainMode ${var.domain_mode} -ForestMode ${var.domain_mode} -DatabasePath ${var.database_path} -SysvolPath ${var.sysvol_path} -LogPath ${var.log_path} -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString ${local.generated_password} -AsPlainText -Force)"
  powershell         = "${local.cmd01}; ${local.cmd02}; ${local.cmd03}; ${local.cmd04}; ${local.cmd05}"
}

###########################################################
# Use existing resources as BACKEND
###########################################################

resource "null_resource" "backend_setup" {
  provisioner "local-exec" {
    command = <<-EOT
      $backendConfig = @'
      terraform {
        backend "azurerm" {
          storage_account_name = "${azurerm_storage_account.tfaz-stg-infra.name}"
          container_name       = "${azurerm_storage_container.tfaz-cont-infra.name}"
          key                  = "terraform.tfstate"
          access_key           = "${azurerm_storage_account.tfaz-stg-infra.primary_access_key}"
        }
      }
      '@

      Set-Content -Path "${path.module}/backend.tf" -Value $backendConfig
    EOT

    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    azurerm_storage_account.tfaz-stg-infra,
    azurerm_resource_group.tfaz-rg-aad,
    azurerm_storage_container.tfaz-cont-infra,
    azurerm_virtual_machine_extension.dc01-ad-exten,
  ]
}

output "backend_access_key" {
  value     = azurerm_storage_account.tfaz-stg-infra.primary_access_key
  sensitive = true
}