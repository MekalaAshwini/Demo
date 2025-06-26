resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  purge_protection_enabled    = true
  sku_name                    = "standard"
	soft_delete_retention_days  = 7
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "keyvault_private_endpoint" {
  name                = "${var.keyvault_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "keyvault-private-connection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_vnet_link" {
  name                  = "${var.keyvault_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_zone.name
  virtual_network_id    = var.vnet_id
}

# Add DNS A Record for Key Vault
resource "azurerm_private_dns_a_record" "keyvault_a_record" {
  name                = format("%s.vaultcore.azure.net", azurerm_private_endpoint.keyvault_private_endpoint.name)
  zone_name           = azurerm_private_dns_zone.keyvault_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.keyvault_private_endpoint.private_service_connection[0].private_ip_address]
}