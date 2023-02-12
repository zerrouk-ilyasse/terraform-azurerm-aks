locals {
  admin_rules = []

  edit_rules = []

  view_rules = [
    {
      api_groups = [""]
      resources  = ["nodes"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["metrics.k8s.io"]
      resources  = ["nodes", "pods"]
      verbs      = ["get", "list", "watch"]
    }
  ]

  ad_member_domains = {
    public       = "onmicrosoft.com"
    usgovernment = "onmicrosoft.us"
  }

  upn_regex = "(?i)@[a-z0-9-]+\\.${local.ad_member_domains[var.azure_env]}"

  user_object_ids  = distinct([for username, object_id in merge(var.rbac_bindings.cluster_admin_users, var.rbac_bindings.cluster_view_users) : object_id])
  group_object_ids = distinct(concat(var.rbac_bindings.cluster_admin_groups, var.rbac_bindings.cluster_view_groups))

  cluster_admin_users = distinct([for username, object_id in var.rbac_bindings.cluster_admin_users : length(regexall(local.upn_regex, username)) > 0 ? username : object_id])
  cluster_view_users  = distinct([for username, object_id in var.rbac_bindings.cluster_view_users : length(regexall(local.upn_regex, username)) > 0 ? username : object_id])
}
