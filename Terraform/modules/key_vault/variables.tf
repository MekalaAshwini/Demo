variable "keyvault_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "tenant_id" {}
variable "vnet_id" {
  description = "ID of the virtual network"
}
variable "subnet_id" {
  description = "ID of the subnet"
}