data "azurerm_client_config" "current" {
}

data "azurerm_public_ip" "outbound" {
  count = var.nat_gateway_id == null ? var.managed_outbound_ip_count : 0

  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.default.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[count.index]))[0]
  resource_group_name = azurerm_kubernetes_cluster.default.node_resource_group
}

locals {
  log_categories = {
    all = ["kube-apiserver", "kube-audit", "kube-controller-manager", "kube-scheduler", "cluster-autoscaler", "cloud-controller-manager", "guard", "csi-azuredisk-controller", "csi-azurefile-controller", "csi-snapshot-controller"]

    recommended = ["kube-apiserver", "kube-audit-admin", "kube-controller-manager", "kube-scheduler", "cluster-autoscaler", "cloud-controller-manager", "guard", "csi-azuredisk-controller", "csi-azurefile-controller", "csi-snapshot-controller"]

    limited = ["kube-apiserver", "kube-controller-manager", "cloud-controller-manager", "guard"]
  }

  logging_config = merge({
    workspace = {
      name                       = "control-plane-workspace"
      log_analytics_workspace_id = var.control_plane_logging_external_workspace ? var.control_plane_logging_external_workspace_id : azurerm_log_analytics_workspace.default[0].id
      storage_account_id         = null
      logs                       = local.log_categories[var.control_plane_logging_workspace_categories]
      metrics                    = []
      retention_enabled          = var.control_plane_logging_workspace_retention_enabled
      retention_days             = var.control_plane_logging_workspace_retention_days
    }
    }, var.control_plane_logging_storage_account_enabled ? {
    storage_account = {
      name                       = "control-plane-storage-account"
      log_analytics_workspace_id = null
      storage_account_id         = var.control_plane_logging_storage_account_id
      logs                       = local.log_categories[var.control_plane_logging_storage_account_categories]
      metrics                    = []
      retention_enabled          = var.control_plane_logging_storage_account_retention_enabled
      retention_days             = var.control_plane_logging_storage_account_retention_days
    }
  } : {})

  maintenance_window_location_offsets = {
    westeurope = 0
    uksouth    = 0
    eastus     = 5
    eastus2    = 5
    centralus  = 6
    westus     = 8

  }

  maintenance_window_offset = var.maintenance_window_offset != null ? var.maintenance_window_offset : lookup(local.maintenance_window_location_offsets, var.location, 0)

  maintenance_window_allowed_days = length(var.maintenance_window_allowed_days) == 0 ? ["Tuesday", "Wednesday", "Thursday"] : var.maintenance_window_allowed_days

  maintenance_window_allowed_hours = length(var.maintenance_window_allowed_hours) == 0 ? [10, 11, 12, 13, 14, 15] : var.maintenance_window_allowed_hours

  maintenance_window_not_allowed = length(var.maintenance_window_not_allowed) == 0 ? [] : var.maintenance_window_not_allowed

  maintenance_window = {
    allowed = [for d in local.maintenance_window_allowed_days : {
      day   = d
      hours = [for h in local.maintenance_window_allowed_hours : h + local.maintenance_window_offset]
    }]
    not_allowed = [for x in local.maintenance_window_not_allowed : {
      start = timeadd(x.start, format("%vh", local.maintenance_window_offset))
      end   = timeadd(x.end, format("%vh", local.maintenance_window_offset))
    }]
  }

  workspace_log_categories = lookup(var.experimental, "workspace_log_categories", "recommended")
  storage_log_categories   = lookup(var.experimental, "storage_log_categories", "recommended")
}
