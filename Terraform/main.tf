provider "azurerm" {
  features {}
  subscription_id = "583fbf3d-b0bb-44ab-b731-661612fc6f58"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-demo"
  location = "West US"
}

module "vnet" {
  source              = "./modules/network"
  vnet_name           = "demo-vnet"
  subnet_name         = "default-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  subnet_prefix       = ["10.0.1.0/24"]
}

module "keyvault" {
  source              = "./modules/key_vault"
  keyvault_name       = "demovault34"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = "aa4806a3-83c8-4910-b254-e70e245c6250"
  vnet_id             = module.vnet.vnet_id
  subnet_id           = module.vnet.subnet_id
}

module "sql_database" {
  source              = "./modules/sql_database"
  sql_server_name     = "demosqlserver231"
  database_name       = "demodbdev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  admin_username      = "sqladmin"
  admin_password      = "P@ssw0rd2025!"
  vnet_id             = module.vnet.vnet_id
  subnet_id           = module.vnet.subnet_id
}

module "virtual_machine" {
  source              = "./modules/virtual_machine"
  vm_name             = "demo-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  admin_username      = "azureuser"
  admin_password      = "VmP@ssw0rd2025!"
  subnet_id           = module.vnet.subnet_id
}

module "storage" {
  source              = "./modules/storage"
  storage_name        = "demostorageacct23"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = {
    environment = "demo"
  }
}
