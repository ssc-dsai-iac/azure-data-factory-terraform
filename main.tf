
# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure Data Factory workspace
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_data_factory" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  public_network_enabled = false
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Access policy to Key Vault
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "this" {
  depends_on = [
    azurerm_data_factory.this
  ]
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_data_factory.this.identity.0.tenant_id
  object_id    = azurerm_data_factory.this.identity.0.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# Creating Link Services
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_data_factory_linked_service_key_vault" "this" {
  name                = "KeyVaultServiceLink"
  resource_group_name = var.resource_group_name
  data_factory_name   = azurerm_data_factory.this.name
  key_vault_id        = var.key_vault_id
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "this" {
  name                = "StorageAccountServiceLink"
  resource_group_name = var.resource_group_name
  data_factory_name   = azurerm_data_factory.this.name
  connection_string   = var.csa_connection_string
}