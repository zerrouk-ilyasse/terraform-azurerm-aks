# resource "azurerm_storage_account" "data" {
#   name                = "${replace(var.cluster_name, "-", "")}data"
#   resource_group_name = var.resource_group_name
#   location            = var.location

#   account_tier             = "Standard"
#   account_replication_type = "ZRS"

#   enable_https_traffic_only       = true
#   min_tls_version                 = "TLS1_2"
#   shared_access_key_enabled       = true
#   allow_nested_items_to_be_public = false

#   network_rules {
#     default_action             = "Deny"
#     bypass                     = ["AzureServices"]
#     virtual_network_subnet_ids = [var.subnet_id]
#   }

#   tags = var.tags
# }
