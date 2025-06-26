resource "azurerm_mssql_server" "sql_server" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"
  administrator_login = var.admin_username
  administrator_login_password = var.admin_password

  tags = var.tags
}

resource "azurerm_mssql_database" "sql_db" {
  name      = var.database_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name = "Basic"
}

# SQL Private Endpoint
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "${var.sql_server_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "sql-private-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

# Private DNS Zone for SQL
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_vnet_link" {
  name                  = "${var.sql_server_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = var.vnet_id
}

# Add DNS A Record for SQL
resource "azurerm_private_dns_a_record" "sql_a_record" {
  name                = format("%s.database.windows.net", azurerm_private_endpoint.sql_private_endpoint.name)
  zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]
}