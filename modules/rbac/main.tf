resource "kubernetes_cluster_role" "aggregate_to_admin" {
  count = length(local.admin_rules) > 0 ? 1 : 0

  metadata {
    name   = "lnrs:aggregate-to-admin"
    labels = merge(var.labels, { "rbac.authorization.k8s.io/aggregate-to-admin" = "true" })
  }

  dynamic "rule" {
    for_each = toset(local.admin_rules)

    content {
      api_groups        = try(rule.value.api_groups, null)
      non_resource_urls = try(rule.value.non_resource_urls, null)
      verbs             = rule.value.verbs
      resources         = try(rule.value.resources, null)
      resource_names    = try(rule.value.resource_names, null)
    }
  }
}

resource "kubernetes_cluster_role" "aggregate_to_edit" {
  count = length(local.edit_rules) > 0 ? 1 : 0

  metadata {
    name   = "lnrs:aggregate-to-edit"
    labels = merge(var.labels, { "rbac.authorization.k8s.io/aggregate-to-edit" = "true" })
  }

  dynamic "rule" {
    for_each = toset(local.edit_rules)

    content {
      api_groups        = try(rule.value.api_groups, null)
      non_resource_urls = try(rule.value.non_resource_urls, null)
      verbs             = rule.value.verbs
      resources         = try(rule.value.resources, null)
      resource_names    = try(rule.value.resource_names, null)
    }
  }
}

resource "kubernetes_cluster_role" "aggregate_to_view" {
  count = length(local.view_rules) > 0 ? 1 : 0

  metadata {
    name   = "lnrs:aggregate-to-view"
    labels = merge(var.labels, { "rbac.authorization.k8s.io/aggregate-to-view" = "true" })
  }

  dynamic "rule" {
    for_each = toset(local.view_rules)

    content {
      api_groups        = try(rule.value.api_groups, null)
      non_resource_urls = try(rule.value.non_resource_urls, null)
      verbs             = rule.value.verbs
      resources         = try(rule.value.resources, null)
      resource_names    = try(rule.value.resource_names, null)
    }
  }
}

resource "azurerm_role_assignment" "cluster_user" {
  for_each = toset(local.user_object_ids)

  principal_id = each.value

  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope                = var.cluster_id
}

resource "azurerm_role_assignment" "cluster_group" {
  for_each = toset(local.group_object_ids)

  principal_id = each.value

  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope                = var.cluster_id
}

resource "kubernetes_cluster_role_binding" "cluster_admin" {
  count = length(local.cluster_admin_users) + length(var.rbac_bindings.cluster_admin_groups) > 0 ? 1 : 0

  metadata {
    name   = "lnrs:cluster-admin"
    labels = var.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  dynamic "subject" {
    for_each = toset(local.cluster_admin_users)

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = "User"
      name      = subject.value
      namespace = ""
    }
  }

  dynamic "subject" {
    for_each = toset(var.rbac_bindings.cluster_admin_groups)
    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = "Group"
      name      = subject.value
      namespace = ""
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster_view" {
  count = length(local.cluster_view_users) + length(var.rbac_bindings.cluster_view_groups) > 0 ? 1 : 0

  metadata {
    name   = "lnrs:cluster-view"
    labels = var.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  dynamic "subject" {
    for_each = toset(local.cluster_view_users)

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = "User"
      name      = subject.value
      namespace = ""
    }
  }

  dynamic "subject" {
    for_each = toset(var.rbac_bindings.cluster_view_groups)
    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = "Group"
      name      = subject.value
      namespace = ""
    }
  }
}
