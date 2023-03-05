variable "azure_env" {
  description = "Azure cloud environment type."
  type        = string
  nullable    = false
}

variable "tenant_id" {
  description = "ID of the Azure Tenant."
  type        = string
  nullable    = false
}

variable "subscription_id" {
  description = "ID of the subscription."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure region in which the AKS cluster is located."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the resource group containing the AKS cluster."
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the Azure Kubernetes managed cluster."
  type        = string
  nullable    = false
}

variable "cluster_version" {
  description = "Kubernetes version of the AKS cluster."
  type        = string
  nullable    = false
}

variable "workload_identity" {
  description = "If the cluster has workload identity enabled."
  type        = bool
}

variable "cluster_oidc_issuer_url" {
  description = "The URL of the cluster OIDC issuer."
  type        = string
}

variable "network_plugin" {
  description = "Kubernetes Network Plugin."
  type        = string
  nullable    = false
}

variable "ingress_node_group" {
  description = "If an ingress node group is provisioned."
  type        = bool
  nullable    = false
}

variable "subnet_id" {
  description = "ID of the subnet."
  type        = string
  nullable    = false
}

variable "availability_zones" {
  description = "Availability zones to use for the node groups."
  type        = list(number)
  nullable    = false
}

variable "kubelet_identity_id" {
  description = "ID of the Kubelet identity."
  type        = string
  nullable    = false
}

variable "node_resource_group_name" {
  description = "Name of the node resource group."
  type        = string
  nullable    = false
}

variable "dns_resource_group_lookup" {
  description = "Lookup from DNS zone to resource group name."
  type        = map(string)
  nullable    = false
}

variable "core_services_config" {
  description = "Core service configuration."
  type = object({
    alertmanager = object({
      smtp_host = string
      smtp_from = string
      receivers = optional(list(object({
        name              = string
        email_configs     = optional(any, [])
        opsgenie_configs  = optional(any, [])
        pagerduty_configs = optional(any, [])
        pushover_configs  = optional(any, [])
        slack_configs     = optional(any, [])
        sns_configs       = optional(any, [])
        victorops_configs = optional(any, [])
        webhook_configs   = optional(any, [])
        wechat_configs    = optional(any, [])
        telegram_configs  = optional(any, [])
      })))
      routes = optional(list(object({
        receiver            = string
        group_by            = optional(list(string))
        continue            = optional(bool)
        matchers            = list(string)
        group_wait          = optional(string)
        group_interval      = optional(string)
        repeat_interval     = optional(string)
        mute_time_intervals = optional(list(string))
        # active_time_intervals = optional(list(string))
      })))
    })
    cert_manager = optional(object({
      acme_dns_zones      = optional(list(string))
      additional_issuers  = optional(map(any))
      default_issuer_kind = optional(string)
      default_issuer_name = optional(string)
    }), {})
    coredns = optional(object({
      forward_zones = optional(map(any))
    }), {})
    external_dns = optional(object({
      additional_sources     = optional(list(string))
      private_domain_filters = optional(list(string))
      public_domain_filters  = optional(list(string))
    }), {})
    fluentd = optional(object({
      image_repository = optional(string)
      image_tag        = optional(string)
      additional_env   = optional(map(string))
      debug            = optional(bool, true)
      filters          = optional(string)
      route_config = optional(list(object({
        match  = string
        label  = string
        copy   = optional(bool)
        config = string
      })))
      routes  = optional(string)
      outputs = optional(string)
    }), {})
    grafana = optional(object({
      admin_password          = optional(string)
      additional_plugins      = optional(list(string))
      additional_data_sources = optional(list(any))
    }), {})
    ingress_internal_core = object({
      domain           = string
      subdomain_suffix = optional(string)
      lb_source_cidrs  = optional(list(string), ["10.0.0.0/8", "100.65.0.0/16"])
      lb_subnet_name   = optional(string)
      public_dns       = optional(bool, false)
    })
    prometheus = optional(object({
      remote_write = optional(any)
    }), {})
  })
  nullable = false
}

variable "control_plane_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the AKS cluster control plane."
  type        = string
  nullable    = false
}

variable "control_plane_log_analytics_workspace_different_resource_group" {
  description = "If true, the log analytics workspace referenced in control_plane_logging_external_workspace_id is created in a different resource group to the cluster."
  type        = bool
  nullable    = false
}

variable "oms_agent" {
  description = "If the OMS agent addon should be installed."
  type        = bool
  nullable    = false
}

variable "oms_agent_log_analytics_workspace_id" {
  description = "ID of the log analytics workspace for the OMS agent."
  type        = string
  nullable    = false
}

variable "oms_agent_log_analytics_workspace_different_resource_group" {
  description = "If the OMS agent log analytics workspace is in a different resource group to the cluster."
  type        = bool
  nullable    = false
}

variable "oms_agent_create_configmap" {
  description = "If the OMS agent ConfigMap should be created with default settings."
  type        = bool
  nullable    = false
}

variable "labels" {
  description = "Labels to be applied to all Kubernetes resources."
  type        = map(string)
  nullable    = false
}

variable "tags" {
  description = "Tags to be applied to all resources."
  type        = map(string)
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "experimental" {
  description = "Provide experimental feature flag configuration."
  type = object({
    aad_pod_identity_finalizer_wait = string
    fluent_bit_use_memory_buffer    = bool
    fluentd_memory_override         = string
    prometheus_memory_override      = string
  })
}

variable "avoid_statefulset_ha_zones_replicas" {
  description = "Avoid to replicate statefulset across all available zones, this is not HA safe. Use with caution."
  default = false
}
