locals {
  chart_version = "45.1.1"

  thanos_chart_version = "1.10.1"

  # Thanos image version should match version in Thanos chart
  thanos_image_version = "0.30.1"

  use_aad_workload_identity = false

  chart_values = {
    global = {
      rbac = {
        create     = true
        pspEnabled = false
      }
    }

    commonLabels = merge(var.labels, {
      "lnrs.io/monitoring-platform" = "true"
    })

    prometheusOperator = {
      enabled = true

      tls = {
        internalPort = 10250
      }

      priorityClassName = ""

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
          cpu    = "200m"
          memory = "512Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      createCustomResource = false
      manageCrds           = false

      prometheusConfigReloader = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "16Mi"
          }

          limits = {
            cpu    = "500m"
            memory = "16Mi"
          }
        }
      }

      admissionWebhooks = {
        enabled = true

        patch = {
          priorityClassName = "system-cluster-critical"

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
        }

        certManager = {
          enabled = true
        }
      }
    }

    prometheus = {
      prometheusSpec = {
        retention      = "6h"
        scrapeInterval = local.scrapeInterval

        remoteWrite = var.prometheus_remote_write

        podMonitorSelector = {
          matchLabels = {
            "lnrs.io/monitoring-platform" = "true"
          }
        }

        serviceMonitorSelector = {
          matchLabels = {
            "lnrs.io/monitoring-platform" = "true"
          }
        }

        ruleSelector = {
          matchLabels = {
            "lnrs.io/monitoring-platform" = "true"
            "lnrs.io/prometheus-rule"     = "true"
          }
        }

        podMetadata = {
          labels = merge(var.labels, var.workload_identity && local.use_aad_workload_identity ? {} : {
            aadpodidbinding = module.identity_thanos.name
          })
          annotations = {
            "checksum/thanos-objstore-config" = local.thanos_objstore_secret_checksum
          }
        }

        logLevel  = "info"
        logFormat = "json"

        replicas = var.zones

        replicaExternalLabelName = "prometheus_replica"

        priorityClassName = "system-cluster-critical"

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

        podAntiAffinity            = "hard"
        podAntiAffinityTopologyKey = "topology.kubernetes.io/zone"

        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = "azure-disk-premium-ssd-delete"

              accessModes : [
                "ReadWriteOnce"
              ]

              resources = {
                requests = {
                  storage = "64Gi"
                }
              }
            }
          }
        }

        resources = {
          requests = {
            cpu    = "500m"
            memory = coalesce(var.experimental_prometheus_memory_override, "4096Mi")
          }

          limits = {
            cpu    = "2000m"
            memory = coalesce(var.experimental_prometheus_memory_override, "4096Mi")
          }
        }

        thanos = {
          image = "quay.io/thanos/thanos:v${local.thanos_image_version}"

          resources = {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              cpu    = "1000m"
              memory = "64Mi"
            }
          }

          objectStorageConfig = {
            name = local.thanos_objstore_secret_name
            key  = local.thanos_objstore_secret_key
          }
        }
      }

      serviceAccount = {
        create = true
        name   = local.prometheus_service_account_name

        labels = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/use" = "true"
        } : {}

        annotations = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/client-id" = module.identity_thanos.id
        } : {}
      }

      thanosService = {
        enabled = true
      }

      thanosServiceMonitor = {
        enabled = true
      }

      podDisruptionBudget = {
        enabled        = true
        minAvailable   = ""
        maxUnavailable = 1
      }

      ingress = {
        enabled          = true
        annotations      = var.ingress_annotations
        ingressClassName = var.ingress_class_name
        pathType         = "Prefix"
        hosts            = ["prometheus-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
        tls = [{
          hosts = ["prometheus-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
        }]
      }
    }

    alertmanager = {
      alertmanagerSpec = {
        priorityClassName = ""

        retention = "120h"

        podMetadata = {
          labels = var.labels
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

        storage = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = "azure-disk-premium-ssd-delete"

              accessModes : [
                "ReadWriteOnce"
              ]

              resources = {
                requests = {
                  storage = "16Gi"
                }
              }
            }
          }
        }

        resources = {
          requests = {
            cpu    = "10m"
            memory = "64Mi"
          }

          limits = {
            cpu    = "1000m"
            memory = "64Mi"
          }
        }
      }

      config = {
        global = {
          smtp_require_tls = false
          smtp_smarthost   = var.alertmanager_smtp_host
          smtp_from        = var.alertmanager_smtp_from
        }

        receivers = concat(local.alertmanager_base_receivers, local.alertmanager_default_receivers, var.alertmanager_receivers)

        route = {
          group_by = [
            "namespace",
            "severity"
          ]
          group_wait      = "30s"
          group_interval  = "5m"
          repeat_interval = "12h"
          receiver        = "null"

          routes = concat(local.alertmanager_base_routes, local.alertmanager_default_routes, var.alertmanager_routes)
        }
      }

      ingress = {
        enabled          = true
        annotations      = var.ingress_annotations
        ingressClassName = var.ingress_class_name
        pathType         = "Prefix"
        hosts            = ["alertmanager-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
        tls = [{
          hosts = ["alertmanager-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
        }]
      }
    }

    grafana = {
      enabled = true

      rbac = {
        create     = true
        pspEnabled = false
      }

      serviceAccount = {
        create = true
        name   = local.grafana_service_account_name

        labels = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/use" = "true"
        } : {}

        annotations = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/client-id" = module.identity_grafana.id
        } : {}
      }

      podLabels = merge(var.labels, var.workload_identity && local.use_aad_workload_identity ? {} : {
        aadpodidbinding = module.identity_grafana.name
      })

      extraLabels = var.labels

      admin = {
        existingSecret = kubernetes_secret.grafana_auth.metadata[0].name
        userKey        = "admin-user"
        passwordKey    = "admin-password"
      }

      "grafana.ini" = {
        "auth.anonymous" = {
          enabled  = true
          org_role = "Viewer"
        }

        users = {
          viewers_can_edit = true
        }

        azure = {
          managed_identity_enabled = true
        }
      }

      plugins = distinct(concat([
        "grafana-piechart-panel"
      ], var.grafana_additional_plugins))

      additionalDataSources = concat(local.grafana_data_sources, [for datasource in var.grafana_additional_data_sources : {
        name            = datasource.name
        type            = datasource.type
        access          = datasource.access
        orgId           = lookup(datasource, "orgId", null)
        uid             = lookup(datasource, "uid", null)
        url             = lookup(datasource, "url", null)
        basicAuth       = lookup(datasource, "basicAuth", null)
        basicAuthUser   = lookup(datasource, "basicAuthUser", null)
        withCredentials = lookup(datasource, "withCredentials", null)
        isDefault       = lookup(datasource, "isDefault", null)
        jsonData        = lookup(datasource, "jsonData", null)
        secureJsonData  = lookup(datasource, "secureJsonData", null)
        version         = lookup(datasource, "version", null)
        editable        = lookup(datasource, "editable", null)
      }])

      priorityClassName = ""

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

      ingress = {
        enabled          = true
        annotations      = var.ingress_annotations
        ingressClassName = var.ingress_class_name
        pathType         = "Prefix"
        path             = "/"
        hosts            = ["grafana-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
        tls = [{
          hosts = ["grafana-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
        }]
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
      }

      serviceMonitor = {
        enabled = true
        labels = {
          "lnrs.io/monitoring-platform" = "true"
        }
      }

      sidecar = {
        datasources = {
          defaultDatasourceEnabled = false
        }

        dashboards = {
          enabled          = true
          folderAnnotation = "grafana_folder"
          label            = "grafana_dashboard"
          provider = {
            allowUiUpdates            = true
            foldersFromFilesStructure = true
          }
          searchNamespace = "ALL"
        }

        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }

          limits = {
            cpu    = "1000m"
            memory = "128Mi"
          }
        }
      }
    }

    kubeScheduler = {
      enabled = false
    }

    kubeControllerManager = {
      enabled = false
    }

    kubeEtcd = {
      enabled = false
    }

    kubeProxy = {
      enabled = true

      service = {
        selector = {
          component = "kube-proxy"
        }
      }
    }

    defaultRules = {
      create = false
    }

    kubeStateMetrics = {
      enabled = true
    }

    kube-state-metrics = {
      podSecurityPolicy = {
        enabled = false
      }

      prometheus = {
        monitor = {
          enabled = true
          additionalLabels = {
            "lnrs.io/monitoring-platform" = "true"
          }
        }
      }

      priorityClassName = "system-cluster-critical"

      customLabels = var.labels

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
          cpu    = "50m"
          memory = "256Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
      }
    }

    nodeExporter = {
      enabled = true
    }

    prometheus-node-exporter = {
      rbac = {
        create     = true
        pspEnabled = false
      }

      prometheus = {
        monitor = {
          enabled = true
          additionalLabels = {
            "lnrs.io/monitoring-platform" = "true"
          }
        }
      }

      priorityClassName = "system-node-critical"

      podLabels = var.labels

      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }

      tolerations = [{
        operator = "Exists"
      }]

      updateStrategy = {
        type = "RollingUpdate"

        rollingUpdate = {
          maxUnavailable = "25%"
        }
      }

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
  }

  thanos_chart_values = {
    serviceMonitor = {
      enabled = true
      additionalLabels = {
        "lnrs.io/monitoring-platform" = "true"
      }
    }

    commonLabels = var.labels

    objstoreConfig = {
      create = false
      name   = local.thanos_objstore_secret_name
      key    = local.thanos_objstore_secret_key
    }

    logLevel  = "info"
    logFormat = "json"

    compact = {
      enabled = true

      serviceAccount = {
        create = true
        name   = local.thanos_compact_service_account_name

        labels = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/use" = "true"
        } : {}

        annotations = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/client-id" = module.identity_thanos.id
        } : {}
      }

      podLabels = var.workload_identity && local.use_aad_workload_identity ? {} : {
        aadpodidbinding = module.identity_thanos.name
      }

      podAnnotations = {
        "checksum/thanos-objstore-config" = local.thanos_objstore_secret_checksum
      }

      priorityClassName = ""

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

      persistence = {
        enabled      = true
        storageClass = "azure-disk-premium-ssd-delete"
        accessMode   = "ReadWriteOnce"
        size         = "64Gi"
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

      extraArgs = [
        "--retention.resolution-raw=28d",
        "--retention.resolution-1h=28d",
        "--retention.resolution-5m=28d",
        "--delete-delay=72h"
      ]
    }

    query = {
      serviceAccount = {
        create = true
      }

      autoscaling = {
        enabled                        = true
        minReplicas                    = 1
        maxReplicas                    = 3
        targetCPUUtilizationPercentage = 80
      }

      podDisruptionBudget = {
        enabled        = true
        maxUnavailable = "33%"
      }

      updateStrategy = {
        type = "RollingUpdate"

        rollingUpdate = {
          maxUnavailable = "33%"
          maxSurge       = 0
        }
      }

      priorityClassName = ""

      replicaLabels = ["prometheus_replica"]
      additionalStores = [
        "dnssrv+_grpc._tcp.kube-prometheus-stack-thanos-discovery.${var.namespace}.svc.cluster.local"
      ]

      resources = {
        requests = {
          cpu    = "500m"
          memory = "1024Mi"
        }

        limits = {
          cpu    = "2000m"
          memory = "1024Mi"
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

      affinity = {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              podAffinityTerm = {
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name"      = "thanos"
                    "app.kubernetes.io/instance"  = "thanos"
                    "app.kubernetes.io/component" = "query"
                  }
                }

                topologyKey = "topology.kubernetes.io/zone"
              }

              weight = 100
            }
          ]
        }
      }

      extraArgs = [
        "--query.timeout=5m",
        "--query.lookback-delta=15m"
      ]
    }

    queryFrontend = {
      enabled = true

      serviceAccount = {
        create = true
      }

      autoscaling = {
        enabled                        = true
        minReplicas                    = 1
        maxReplicas                    = 3
        targetCPUUtilizationPercentage = 80
      }

      podDisruptionBudget = {
        enabled        = true
        maxUnavailable = "33%"
      }

      updateStrategy = {
        type = "RollingUpdate"

        rollingUpdate = {
          maxUnavailable = "33%"
          maxSurge       = 0
        }
      }

      priorityClassName = ""

      ingress = {
        enabled          = true
        annotations      = var.ingress_annotations
        ingressClassName = var.ingress_class_name
        pathType         = "Prefix"
        hosts            = ["thanos-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
      }

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

      affinity = {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              podAffinityTerm = {
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name"      = "thanos"
                    "app.kubernetes.io/instance"  = "thanos"
                    "app.kubernetes.io/component" = "query-frontend"
                  }
                }

                topologyKey = "topology.kubernetes.io/zone"
              }

              weight = 100
            }
          ]
        }
      }

      extraArgs = [
        "--labels.split-interval=12h",
        "--labels.max-retries-per-request=10",
        "--query-range.split-interval=12h",
        "--query-range.align-range-with-step",
        "--query-range.max-retries-per-request=10",
        "--query-frontend.compress-responses",
        "--query-frontend.log-queries-longer-than=10s",
        "--query-frontend.downstream-tripper-config=${local.thanos_query_frontend_downstream_tripper_config}"
      ]
    }

    rule = {
      enabled = true

      serviceAccount = {
        create = true
        name   = local.thanos_rule_service_account_name

        labels = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/use" = "true"
        } : {}

        annotations = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/client-id" = module.identity_thanos.id
        } : {}
      }

      podLabels = var.workload_identity && local.use_aad_workload_identity ? {} : {
        aadpodidbinding = module.identity_thanos.name
      }

      podAnnotations = {
        "checksum/thanos-objstore-config" = local.thanos_objstore_secret_checksum
      }

      priorityClassName = ""

      ingress = {
        enabled          = true
        annotations      = var.ingress_annotations
        ingressClassName = var.ingress_class_name
        pathType         = "Prefix"
        hosts            = ["thanos-rule-${var.ingress_subdomain_suffix}.${var.ingress_domain}"]
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "128Mi"
        }
      }

      persistence = {
        enabled      = true
        storageClass = "azure-disk-premium-ssd-delete"
        accessMode   = "ReadWriteOnce"
        size         = "16Gi"
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

      configReloader = {
        enabled = true

        resources = {
          requests = {
            cpu    = "10m"
            memory = "16Mi"
          }

          limits = {
            cpu    = "500m"
            memory = "16Mi"
          }
        }
      }

      alertmanagersConfig = {
        create = true

        value = <<-EOT
          alertmanagers:
            - static_configs:
                - kube-prometheus-stack-alertmanager.${var.namespace}.svc.cluster.local:9093
              scheme: http
        EOT
      }

      rules = {
        create = false
        name   = "thanos-ruler-thanos-ruler-rulefiles-0"
      }

      evalInterval = "5m"
    }

    storeGateway = {
      serviceAccount = {
        create = true
        name   = local.thanos_store_gateway_service_account_name

        labels = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/use" = "true"
        } : {}

        annotations = var.workload_identity && local.use_aad_workload_identity ? {
          "azure.workload.identity/client-id" = module.identity_thanos.id
        } : {}
      }

      podLabels = var.workload_identity && local.use_aad_workload_identity ? {} : {
        aadpodidbinding = module.identity_thanos.name
      }

      podAnnotations = {
        "checksum/thanos-objstore-config" = local.thanos_objstore_secret_checksum
      }

      replicas = var.zones

      podDisruptionBudget = {
        enabled        = true
        maxUnavailable = 1
      }

      priorityClassName = ""

      resources = {
        requests = {
          cpu    = "500m"
          memory = "2048Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "2048Mi"
        }
      }

      persistence = {
        enabled      = true
        storageClass = "azure-disk-premium-ssd-delete"
        accessMode   = "ReadWriteOnce"
        size         = "16Gi"
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

      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [{
            labelSelector = {
              matchLabels = {
                "app.kubernetes.io/name"      = "thanos"
                "app.kubernetes.io/instance"  = "thanos"
                "app.kubernetes.io/component" = "store-gateway"
              }
            }
            topologyKey = "topology.kubernetes.io/zone"
          }]
        }
      }
    }
  }

  thanos_ruler = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ThanosRuler"

    metadata = {
      name      = "thanos-ruler"
      namespace = var.namespace
      labels    = var.labels
    }

    spec = {
      replicas = 0

      priorityClassName = "system-cluster-critical"

      nodeSelector = {
        "kubernetes.io/os" = "linux"
        "lnrs.io/tier"     = "system"
      }

      tolerations = [
        {
          key      = "system"
          operator = "Exists"
        }
      ]

      storage = {
        volumeClaimTemplate = {
          spec = {
            storageClassName = "ebs-gp3-retain"

            accessModes : [
              "ReadWriteOnce"
            ]

            resources = {
              requests = {
                storage = "10Gi"
              }
            }
          }
        }
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }

        limits = {
          cpu    = "1000m"
          memory = "128Mi"
        }
      }

      logLevel  = "info"
      logFormat = "json"

      objectStorageConfig = {
        name = local.thanos_objstore_secret_name
        key  = local.thanos_objstore_secret_key
      }

      queryEndpoints = ["dnssrv+_http._tcp.thanos-query-frontend.${var.namespace}.svc.cluster.local"]

      alertmanagersUrl = ["http://kube-prometheus-stack-alertmanager.${var.namespace}.svc.cluster.local:9093"]

      ruleNamespaceSelector = {}

      ruleSelector = {
        matchLabels = {
          "lnrs.io/monitoring-platform" = "true"
          "lnrs.io/thanos-rule"         = "true"
        }
      }
    }
  }

  alertmanager_base_receivers = [{
    name              = "null"
    email_configs     = []
    opsgenie_configs  = []
    pagerduty_configs = []
    pushover_configs  = []
    slack_configs     = []
    sns_configs       = []
    victorops_configs = []
    webhook_configs   = []
    wechat_configs    = []
    telegram_configs  = []
  }]

  alertmanager_default_receivers = length(var.alertmanager_receivers) > 0 ? [] : [{
    name              = "alerts"
    email_configs     = []
    opsgenie_configs  = []
    pagerduty_configs = []
    pushover_configs  = []
    slack_configs     = []
    sns_configs       = []
    victorops_configs = []
    webhook_configs   = []
    wechat_configs    = []
    telegram_configs  = []
  }]

  alertmanager_base_routes = [{
    receiver            = "null"
    group_by            = []
    continue            = false
    matchers            = ["alertname=Watchdog"]
    group_wait          = "30s"
    group_interval      = "5m"
    repeat_interval     = "12h"
    mute_time_intervals = []
    # active_time_intervals = []
  }]

  alertmanager_default_routes = length(var.alertmanager_routes) > 0 ? [] : [{
    receiver            = "alerts"
    group_by            = []
    continue            = false
    matchers            = ["severity=~warning|critical"]
    group_wait          = "30s"
    group_interval      = "5m"
    repeat_interval     = "12h"
    mute_time_intervals = []
    # active_time_intervals = []
  }]

  scrapeInterval = "30s"

  grafana_data_sources = [
    {
      name            = "Alertmanager"
      type            = "alertmanager"
      access          = "proxy"
      orgId           = "1"
      uid             = "alertmanager"
      url             = "http://kube-prometheus-stack-alertmanager.monitoring.svc.cluster.local:9093"
      basicAuth       = null
      basicAuthUser   = null
      withCredentials = null
      isDefault       = false
      jsonData = {
        implementation = "prometheus"
      }
      secureJsonData = null
      version        = null
      editable       = false
    },
    {
      name            = "Prometheus"
      type            = "prometheus"
      access          = "proxy"
      orgId           = "1"
      uid             = "prometheus"
      url             = "http://thanos-query-frontend.${var.namespace}.svc.cluster.local:10902"
      basicAuth       = null
      basicAuthUser   = null
      withCredentials = null
      isDefault       = true
      jsonData = {
        manageAlerts    = true
        alertmanagerUid = "alertmanager"
        timeInterval    = local.scrapeInterval
      }
      secureJsonData = null
      version        = null
      editable       = false
    },
    {
      name            = "Azure Monitor"
      type            = "grafana-azure-monitor-datasource"
      access          = "proxy"
      orgId           = "1"
      uid             = "azuremonitor"
      url             = null
      basicAuth       = null
      basicAuthUser   = null
      withCredentials = null
      isDefault       = false
      jsonData = {
        subscriptionId = var.subscription_id
      }
      secureJsonData = null
      version        = null
      editable       = false
    }
  ]

  resource_group_id                                                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  control_plane_log_analytics_workspace_external_resource_group_id = var.control_plane_log_analytics_workspace_different_resource_group ? regex("([[:ascii:]]*)(/providers/)", var.control_plane_log_analytics_workspace_id)[0] : ""
  oms_agent_log_analytics_workspace_resource_group_id              = var.oms_agent && var.oms_agent_log_analytics_workspace_id != null ? regex("([[:ascii:]]*)(/providers/)", var.oms_agent_log_analytics_workspace_id)[0] : ""

  thanos_objstore_secret_name     = "thanos-object-storage"
  thanos_objstore_secret_key      = "config"
  thanos_objstore_secret_checksum = sha256(local.thanos_objstore_config)

  thanos_objstore_end_point = substr(replace(azurerm_storage_account.data.primary_blob_host, azurerm_storage_account.data.name, ""), 1, -1)

  thanos_objstore_config = <<-EOT
    type: AZURE
    config:
      storage_account: ${azurerm_storage_account.data.name}
      container: thanos
      endpoint: ${local.thanos_objstore_end_point}
      user_assigned_id: ${module.identity_thanos.client_id}
  EOT

  thanos_query_frontend_downstream_tripper_config = <<-EOT
    max_idle_conns_per_host: 100
  EOT

  prometheus_service_account_name           = "kube-prometheus-stack-prometheus"
  thanos_compact_service_account_name       = "thanos-compact"
  thanos_rule_service_account_name          = "thanos-rule"
  thanos_store_gateway_service_account_name = "thanos-store-gateway"
  grafana_service_account_name              = "kube-prometheus-stack-grafana"

  crd_files           = { for x in fileset(path.module, "crds/*.yaml") : basename(x) => "${path.module}/${x}" }
  resource_files      = { for x in fileset(path.module, "resources/*.yaml") : basename(x) => "${path.module}/${x}" }
  resource_objects    = { thanos_ruler = local.thanos_ruler }
  dashboard_templates = { for x in fileset(path.module, "resources/configmap-dashboard-*.yaml.tpl") : basename(x) => { path = "${path.module}/${x}", vars = { resource_id = var.control_plane_log_analytics_workspace_id, subscription_id = var.subscription_id } } }
}
