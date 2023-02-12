resource "random_string" "workspace_suffix" {
  count = var.control_plane_logging_external_workspace ? 0 : 1

  length  = 5
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_log_analytics_workspace" "default" {
  count = var.control_plane_logging_external_workspace ? 0 : 1

  location            = var.location
  resource_group_name = var.resource_group_name

  name              = "${regex("aks-\\d+", var.cluster_name)}-control-plane-logs-${random_string.workspace_suffix[0].result}"
  retention_in_days = 30
  tags              = merge(var.tags, { description = "control-plane-logs" })
}

data "azurerm_monitor_diagnostic_categories" "default" {
  resource_id = azurerm_kubernetes_cluster.default.id
}

resource "azurerm_monitor_diagnostic_setting" "default" {
  for_each = local.logging_config

  name               = each.value.name
  target_resource_id = azurerm_kubernetes_cluster.default.id

  log_analytics_workspace_id = each.value.log_analytics_workspace_id
  storage_account_id         = each.value.storage_account_id

  lifecycle {
    ignore_changes = [log, metric]
  }

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.logs

    content {
      category = log.value
      enabled  = contains(each.value.logs, log.value)
      retention_policy {
        enabled = contains(each.value.logs, log.value) && each.value.retention_enabled
        days    = contains(each.value.logs, log.value) && each.value.retention_enabled ? each.value.retention_days : "0"
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.metrics

    content {
      category = metric.value
      enabled  = contains(each.value.metrics, metric.value)
      retention_policy {
        enabled = contains(each.value.metrics, metric.value) && each.value.retention_enabled
        days    = contains(each.value.metrics, metric.value) && each.value.retention_enabled ? each.value.retention_days : "0"
      }
    }
  }
}
