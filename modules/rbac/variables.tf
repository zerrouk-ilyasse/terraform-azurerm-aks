variable "azure_env" {
  description = "Azure cloud environment type."
  type        = string
}

variable "cluster_id" {
  description = "ID of the Azure Kubernetes managed cluster."
  type        = string
}

variable "labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
}

variable "rbac_bindings" {
  description = "Azure AD user and group IDs to configure in Kubernetes ClusterRoleBindings."
  type = object({
    cluster_admin_users  = map(string)
    cluster_admin_groups = list(string)
    cluster_view_users   = map(string)
    cluster_view_groups  = list(string)
  })
}
