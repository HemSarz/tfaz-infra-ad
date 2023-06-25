variable "tfaz-rg-loc" {
  type    = string
  default = "norwayeast"
}

variable "env-tag-infra" {
  type    = string
  default = "tfaz-rg-infra"
}

variable "tfaz-rg-infra-prefix" {
  type    = string
  default = "tfaz-rg-aad"
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

variable "tfaz-dns-servers" {
  type    = string
  default = "[10.10.1.5, 168.63.129.16,8.8.8.8]"
}

########### SUBNET 1

variable "tfaz-vnet1-subnet1" {
  type    = string
  default = "tfaz-vnet1-subnet1"
}

variable "tfaz-vnet1-addr-space" {
  type    = string
  default = "10.10.1.0/16"
}

variable "tfaz-vnet1-subn1-range" {
  type    = string
  default = "10.10.1.0/24"
}

########### SUBNET 2
variable "tfaz-vnet1-subn2-name" {
  type    = string
  default = "10.10.2.0/24"
}

variable "tfaz-vnet1-subn2-addr-space" {
  type    = string
  default = "10.10.2.0/16"
}

variable "tfaz-bnet11-subn2-range" {
  type    = string
  default = "10.10.2.0/24"
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

variable "tfaz-VMadminPass" {
  type    = string
  default = ""
}

