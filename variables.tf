variable "tfaz-rg-loc" {
  type    = string
  default = "norwayeast"
}

variable "tfaz-rg-name" {
  type    = string
  default = "tfaz-rg-aad"
}

variable "env-tag-infra" {
  type    = string
  default = "tfaz-rg-infra"
}

variable "tfaz-stg-infra" {
  type    = string
  default = "tfazstginfra"
}

variable "tfaz-stg-cont" {
  type    = string
  default = "tfaz-rg-cont"
}

################## Network VB

variable "tfaz-vnet1-name" {
  type    = string
  default = "tfaz-rg01-vnet1"
}

########### DNS

variable "tfaz-dns-servers-subn1" {
  type    = list(string)
  default = ["10.10.1.2", "168.63.129.16", "8.8.8.8"]
}


variable "tfaz-dns-servers-subn2" {
  type    = list(string)
  default = ["10.11.1.2", "168.63.129.16", "8.8.8.8"]
}

########### SUBNET 1

variable "tfaz-vnet1-subnet1" {
  type    = string
  default = "tfaz-vnet1-subnet1"
}

variable "tfaz-vnet1-addr-space" {
  type    = string
  default = "10.10.0.0/16"
}

variable "tfaz-vnet1-subn1-range" {
  type    = string
  default = "10.10.1.0/24"
}

########### SUBNET 2

variable "tfaz-vnet1-subn2-name" {
  type    = string
  default = "tfaz-vnet1-subnet2"
}

variable "tfaz-vnet1-subn2-addr-space" {
  type    = string
  default = "10.11.0.0/16"
}

variable "tfaz-vnet1-subn2-range" {
  type    = string
  default = "10.11.1.0/24"
}

variable "tfaz-intface" {
  type    = string
  default = "tfaz-dc01-intface"
}


variable "tfaz-pip-dc01" {
  type    = string
  default = "tfaz-pip-dc01"
}

variable "tfaz-prvip-dc01-subnet1" {
  type    = string
  default = "10.10.1.10"
}
################## NSG

variable "tfaz-nsg-infra" {
  type    = string
  default = "tfaz-nsg-client-ip"
}

################## KeyVault

variable "tfaz-kv-name" {
  type    = string
  default = "tfaz-kv-infra"
}

################## ADMIN ACCOUNT

variable "tfaz-VMAdmin" {
  type    = string
  default = "VMAdminDC01"
}

variable "tfaz-vm-pass" {
  type    = string
  default = "tfazdc01"
}

variable "tfaz-vm-sc-name" {
  type    = string
  default = "tfaz-vm-pass-name"
}

######### AD

variable "domain_name" {
  type    = string
  default = "tfaz.local"
}

variable "domain_netbios_name" {
  type    = string
  default = "tfaz"
}

variable "domain_mode" {
  type    = string
  default = "WinThreshold"
}

variable "database_path" {
  type    = string
  default = "H:/Windows/NTDS"
}

variable "sysvol_path" {
  type    = string
  default = "H:/Windows/SYSVOL"
}

variable "log_path" {
  type    = string
  default = "H:/Windows/NTDS"
}


##### VM | Data Disk

variable "tfaz-dc01" {
  type    = string
  default = "tfaz-dc01"
}

variable "vm_size" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "storage-acc-type" {
  type    = string
  default = "Standard_LRS"
}

variable "dc01-ntds" {
  type    = string
  default = "dc01-data-disk"
}

variable "vm-exten-dc01-ntds" {
  type    = string
  default = "dc01-data-disk"
}

######## SPN

variable "tfaz-spn" {
  type    = string
  default = "tfaz-spn-infra"
}