variable "sql_server_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "admin_username" {}
variable "admin_password" {}
variable "database_name" {}
variable "tags" { default = {} }
variable "vnet_id" {
  description = "ID of the virtual network"
}
variable "subnet_id" {
  description = "ID of the subnet"
}