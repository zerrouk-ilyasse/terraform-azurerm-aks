resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_storage_account" "data" {
  name                = "${replace(regex("aks-\\d+", var.cluster_name), "-", "")}data${random_string.storage_account_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "ZRS"

  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = true
  allow_nested_items_to_be_public = false

  tags = var.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.subnet_id]
    bypass                     = ["AzureServices"]
  }
}
