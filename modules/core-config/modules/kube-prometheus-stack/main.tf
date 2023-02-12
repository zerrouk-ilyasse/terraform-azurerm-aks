## The CRDs are required by a number of other services so are installed separately (core-config/main.tf)
## Provided for future compatibility - not used within this submodule
resource "kubectl_manifest" "crds" {
  for_each = var.skip_crds ? {} : local.crd_files

  yaml_body = file(each.value)

  server_side_apply = true
  wait              = true
}

# resource "kubernetes_secret" "thanos_objstore_config" {
#   metadata {
#     name      = local.thanos_objstore_secret_name
#     namespace = var.namespace
#   }

#   type = "Opaque"

#   data = {
#     "${local.thanos_objstore_secret_key}" = local.thanos_objstore_config
#   }
# }

resource "kubernetes_secret" "grafana_auth" {
  metadata {
    name      = "grafana-auth"
    namespace = var.namespace
    labels    = var.labels
  }

  type = "Opaque"

  data = {
    "admin-user"     = "admin"
    "admin-password" = var.grafana_admin_password
  }
}

resource "kubectl_manifest" "resource_files" {
  for_each = local.resource_files

  yaml_body = file(each.value)

  server_side_apply = true
  wait              = true

  depends_on = [
    kubectl_manifest.crds
  ]
}

# resource "kubectl_manifest" "resource_objects" {
#   for_each = local.resource_objects

#   yaml_body = yamlencode(each.value)

#   server_side_apply = true
#   wait              = true

#   depends_on = [
#     kubectl_manifest.crds
#   ]
# }

resource "kubectl_manifest" "resource_template_objects" {
  for_each = local.dashboard_templates

  yaml_body = templatefile(each.value.path, each.value.vars)

  server_side_apply = true
  wait              = true

  depends_on = [
    kubectl_manifest.crds
  ]
}

resource "helm_release" "default" {
  name      = "kube-prometheus-stack"
  namespace = var.namespace

  repository = "https://prometheus-community.github.io/helm-charts/"
  chart      = "kube-prometheus-stack"
  version    = local.chart_version
  skip_crds  = true

  max_history = 10
  timeout     = 600

  values = [
    yamlencode(local.chart_values)
  ]

  depends_on = [
    kubectl_manifest.crds,
    # azurerm_storage_container.thanos,
    # module.identity_thanos,
    # kubernetes_secret.thanos_objstore_config,
    # kubernetes_secret.grafana_auth
  ]
}

# resource "helm_release" "thanos" {
#   name      = "thanos"
#   namespace = var.namespace

#   repository = "https://stevehipwell.github.io/helm-charts/"
#   chart      = "thanos"
#   version    = local.thanos_chart_version
#   skip_crds  = true

#   max_history = 10
#   timeout     = 600

#   values = [
#     yamlencode(local.thanos_chart_values)
#   ]

#   depends_on = [
#     kubectl_manifest.crds,
#     helm_release.default,
#     azurerm_storage_container.thanos,
#     module.identity_thanos,
#     kubernetes_secret.thanos_objstore_config
#   ]
# }
