locals {
  chart_version = "1.9.1"

  chart_values = {
    installCRDs = false

    global = {
      priorityClassName = "system-cluster-critical"
    }

    podLabels = merge(var.labels, {
      aadpodidbinding = module.identity.name
    })

    serviceLabels = var.labels

    securityContext = {
      fsGroup = 65534
    }

    prometheus = {
      enabled = true
      servicemonitor = {
        enabled            = true
        prometheusInstance = "Prometheus"
        targetPort         = 9402
        path               = "/metrics"
        interval           = "60s"
        scrapeTimeout      = "30s"
        labels = {
          "lnrs.io/monitoring-platform" = "true"
        }
      }
    }

    nodeSelector = {
      "kubernetes.io/os" = "linux"
      "lnrs.io/tier"     = "system"
    }

    tolerations = [
      {
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      },
      {
        key      = "system"
        operator = "Exists"
      }
    ]

    resources = {
      requests = {
        cpu    = "100m"
        memory = "512Mi"
      }

      limits = {
        cpu    = "1000m"
        memory = "512Mi"
      }
    }

    extraArgs = [
      "--dns01-recursive-nameservers-only",
      "--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53"
    ]

    cainjector = {
      nodeSelector = {
        "kubernetes.io/os" = "linux"
        "lnrs.io/tier"     = "system"
      }

      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        },
        {
          key      = "system"
          operator = "Exists"
        }
      ]

      podLabels = var.labels

      resources = {
        requests = {
          cpu    = "100m"
          memory = "512Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    startupapicheck = {
      timeout = "2m"

      nodeSelector = {
        "kubernetes.io/os" = "linux"
        "lnrs.io/tier"     = "system"
      }

      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        },
        {
          key      = "system"
          operator = "Exists"
        }
      ]

      podLabels = var.labels

      resources = {
        requests = {
          cpu    = "50m"
          memory = "128Mi"
        }

        requests = {
          cpu    = "1000m"
          memory = "128Mi"
        }
      }
    }

    webhook = {
      securePort  = 10251
      hostNetwork = true

      serviceLabels = var.labels

      replicaCount = 2

      nodeSelector = {
        "kubernetes.io/os" = "linux"
        "lnrs.io/tier"     = "system"
      }

      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        },
        {
          key      = "system"
          operator = "Exists"
        }
      ]

      podLabels = var.labels

      resources = {
        requests = {
          cpu    = "100m"
          memory = "64Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "64Mi"
        }
      }
    }

    ingressShim = {
      defaultIssuerKind = var.default_issuer_kind
      defaultIssuerName = var.default_issuer_name
    }
  }

  issuers = merge(var.additional_issuers, {
    letsencrypt = {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name   = "letsencrypt"
        labels = var.labels
      }
      spec = {
        acme = {
          email  = "systems.engineering@reedbusiness.com"
          server = "https://acme-v02.api.letsencrypt.org/directory"
          privateKeySecretRef = {
            name = "issuer-letsencrypt-privatekey"
          }
          solvers = [for zone in var.acme_dns_zones : {
            selector = {
              dnsZones = [zone]
            }
            dns01 = {
              azureDNS = {
                environment       = var.azure_environment
                subscriptionID    = var.subscription_id
                resourceGroupName = var.dns_resource_group_lookup[zone]
                hostedZoneName    = zone
              }
            }
          }]
        }
      }
    },
    letsencrypt_staging = {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name   = "letsencrypt-staging"
        labels = var.labels
      }
      spec = {
        acme = {
          email  = "systems.engineering@reedbusiness.com"
          server = "https://acme-staging-v02.api.letsencrypt.org/directory"
          privateKeySecretRef = {
            name = "issuer-letsencrypt-staging-privatekey"
          }
          solvers = [for zone in var.acme_dns_zones : {
            selector = {
              dnsZones = [zone]
            }
            dns01 = {
              azureDNS = {
                environment       = var.azure_environment
                subscriptionID    = var.subscription_id
                resourceGroupName = var.dns_resource_group_lookup[zone]
                hostedZoneName    = zone
              }
            }
          }]
        }
      }
    },
    zerossl = {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name   = "zerossl"
        labels = var.labels
      }
      spec = {
        acme = {
          email  = "systems.engineering@reedbusiness.com"
          server = "https://acme.zerossl.com/v2/DV90"
          privateKeySecretRef = {
            name = "zerossl"
          }
          externalAccountBinding = {
            keyID = "5HWD3Esqen2kNewF0URgjg"
            keySecretRef = {
              key  = local.zerossl_eab_secret_key
              name = kubernetes_secret.zerossl_eabsecret.metadata[0].name
            }
            keyAlgorithm = "HS256"
          }
          solvers = [for zone in var.acme_dns_zones : {
            selector = {
              dnsZones = [zone]
            }
            dns01 = {
              azureDNS = {
                environment       = var.azure_environment
                subscriptionID    = var.subscription_id
                resourceGroupName = var.dns_resource_group_lookup[zone]
                hostedZoneName    = zone
              }
            }
          }]
        }
      }
    }
  })

  zerossl_eab_secret_key = "secret"
  zerossl_eabsecret      = "X3Nkc3MwNExIbUdlVXdsQmxBU1Brd0xESWFEZnIxUThxSXlubnppWFFaeFpRYWJGaDkyODZKbVZBQ1NjdHJUU2NFUm1IaC1pUjZXUkZ1cnQxcmRlanc="

  crd_files      = { for x in fileset(path.module, "crds/*.yaml") : basename(x) => "${path.module}/${x}" }
  resource_files = { for x in fileset(path.module, "resources/*.yaml") : basename(x) => "${path.module}/${x}" }
}
