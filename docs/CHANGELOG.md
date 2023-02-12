# Azure AKS Terraform Module Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Upgrading From Pre v1.0.0-beta.10 Versions

All clusters created with a module version older than `v1.0.0-beta.10` need to be destroyed and re-created with the latest version of the module.

---

## Deprecations

- Module input variable `node_group_templates` is deprecated and will be removed in release `v1.0.0-rc.1`.
- Module input variable `azuread_clusterrole_map` is deprecated and will be removed in release `v1.0.0-rc.1`.

---

<!-- ## [vX.Y.Z] - UNRELEASED
### Highlights
### All Changes
- Added
- Updated
- Changed
- Fixed
- Deprecated
- Removed -->

## [v1.0.0-beta.23] - 2022-10-10

### Highlights

_Fluent Bit_ Helm Chart was updated to `v0.20.9` which was the only core service updated in this release.

#### User Defined NAT Gateway

A user defined NAT gateway can now be configured with the `nat_gateway_id` module input. The two modes of network outbound traffic from the pods can be through a [load balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) or a [managed NAT gateway](https://learn.microsoft.com/en-us/azure/aks/nat-gateway). The load balancer is configured by AKS within the module, while the NAT gateway needs to be configured externally.

#### Experimental Features

- Experimental support for [OS customization](https://learn.microsoft.com/en-us/azure/aks/custom-node-configuration#linux-os-custom-configuration) can be enabled by setting `experimental = { node_group_os_config = true }` and then an `os_config` block to applicable `node_groups`.

### All Changes

- Added support for user defined NAT gateway. ([#620](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/620), [#623](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/623))  [@prikesh-patel](https://github.com/prikesh-patel)
- Updated _Fluent Bit_ chart to [v0.20.9](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.9) (contains _Fluent Bit_ [v1.9.9](https://github.com/fluent/fluent-bit/releases/tag/v1.9.9)). ([#683](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/683)) [@peterabarr](https://github.com/peterabarr)
- Added experimental support for [OS customization](https://learn.microsoft.com/en-us/azure/aks/custom-node-configuration#linux-os-custom-configuration), enabled by setting `experimental = { node_group_os_config = true }` and then an `os_config` block to applicable `node_groups`. ([667](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/667), [#686](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/686)) [@jamurtag](https://github.com/jamurtag)

## [v1.0.0-beta.22] - 2022-09-26

> **Warning**
> Terraform [v1.3.1](https://github.com/hashicorp/terraform/releases/tag/v1.3.1) was released shortly after `v1.0.0-beta.22` was released. It is recommended to use this Terraform version as it fixes issues mentioned below. When using Terraform `v1.3.1`, no cycle error occurs when carrying out the AKS module upgrade and no additional manual steps are required.

> **Warning**
> There is a bug in Terraform [v1.3.0](https://github.com/hashicorp/terraform/releases/tag/v1.3.0) which is likely to cause an [error](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/672) when applying the latest release, after running the manual deletions below. Pinning Terraform [v1.2.9](https://github.com/hashicorp/terraform/releases/tag/v1.2.9) should allow the upgrade to complete without any errors, or you can run TF apply a second time to get around the error.

> **Warning**
> The following cluster roles and cluster role bindings will need to be deleted before applying this release. You will need cluster admin access to do this.
>
> ```shell
> kubectl delete clusterrole 'lnrs:cluster-view' 'lnrs:node-view' 'lnrs:view'
> kubectl delete clusterrolebinding 'lnrs:cluster-view' 'lnrs:standard-view'
> ```

### Highlights

Fluent Bit and AAD Pod Identity helm charts were updated in this release.

#### RBAC

The RBAC binding logic has been updated to use the built in `view` `ClusterRole` and adds support to aggregate on top of the built in `ClusterRoles`. User access can be granted by passing the users and groups into the `rbac_bindings` module input variable.

#### Deprecations

- The `azuread_clusterrole_map` input variable has been deprecated in favour of the new `rbac_bindings` input variable.

### All Changes

- Updated the RBAC bindings to use the new `rbac_bindings` input variable. [@stevehipwell](https://github.com/stevehipwell)
- Changed all viewers specified via `azuread_clusterrole_map` to be bound to the `view` `ClusterRole` instead of our own custom `ClusterRoles`, this fixes a potential privilege escalation with the previous implementation. [@stevehipwell](https://github.com/stevehipwell)
- Deprecated the `azuread_clusterrole_map` input variable in favour of the new `rbac_bindings` input variable. [@stevehipwell](https://github.com/stevehipwell)
- Updated _AAD Pod Identity_ chart to `4.1.13` (contains _AAD Pod Identity_ [v1.8.12](https://github.com/Azure/aad-pod-identity/releases/tag/v1.8.12)). ([#654](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/654)) [@peterabarr](https://github.com/peterabarr)
- Updated _Fluent Bit_ chart to [v0.20.8](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.8) (contains _Fluent Bit_ [v1.9.8](https://github.com/fluent/fluent-bit/releases/tag/v1.9.8)). ([#663](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/663)) [@peterabarr](https://github.com/peterabarr)

## [v1.0.0-beta.21] - 2022-09-12

> **Warning**
> If you're using the `lnrs.io_terraform-module-version` AKS cluster tag please be aware that the `v` prefix has been removed.

> **Warning**
> Updated the minimum version of the [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) Terraform provider to `v3.21.1`.

### Highlights

The Kube Prometheus Stack and Ingress Nginx helm charts were updated in this release.

#### Experimental Features

- AKS `v1.24` (see [Kubernetes v1.24 release announcement](https://kubernetes.io/blog/2022/05/03/kubernetes-1-24-release-announcement/) for more details) is supported as an experimental feature and can be enabled by setting `experimental = { v1_24 = true }` and then setting `cluster_version` to `1.24`.

### All Changes

- Updated the `azurerm` Terraform provider to [v3.21.1](https://github.com/hashicorp/terraform-provider-azurerm/releases/tag/v3.21.1) to support AKS v1.24. [@stevehipwell](https://github.com/stevehipwell)
- Added experimental support for AKS v1.24; this can be enabled by setting `experimental = { v1_24 = true }` and then setting `cluster_version` to `"1.24"`. ([#599](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/599)) [@stevehipwell](https://github.com/stevehipwell)
- Updated _Kube Prometheus Stack_ chart to [v39.11.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-39.11.0). ([#641](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/641)) [@peterabarr](https://github.com/peterabarr)
- Updated the _Ingress Nginx_ chart to [v4.2.5](https://github.com/kubernetes/ingress-nginx/releases/tag/helm-chart-4.2.5) (contains _Ingress Nginx Image_ [v1.3.1](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.3.1)). ([#650](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/650)) [@peterabarr](https://github.com/peterabarr)
- Added creation metadata to help with cluster maintenance. [@stevehipwell](https://github.com/stevehipwell)
- Fixed module version syntax to remove erroneous `v` prefix. [@stevehipwell](https://github.com/stevehipwell)
- Added `terraform-modules` `ConfigMap` to the `default` namespace to register the installed module versions. [@stevehipwell](https://github.com/stevehipwell)

## [v1.0.0-beta.20] - 2022-08-31

### Highlights

#### Updated AKS Versions

The full AKS versions have been updated which include patch versions for `v1.23` to `v1.23.8` & `v1.22` to `v1.22.11`. This will trigger an automatic rollout of all nodes in the cluster.

#### CoreDNS Custom Config Map

Users have additional control over the CoreDNS custom confimap. The additional module outputs `coredns_custom_config_map_name` & `coredns_custom_config_map_namespace` can be exported and used to add data to the configmap outside the module by using one or more `kubernetes_config_map_v1_data` resources.

#### Internal Ingress Pod Scheduling

If you are provisioning any ingress nodes through the `node_groups` or `node_group_templates` variables, the core internal ingress pods will schedule onto these nodes automatically.

Any core internal ingress pods will now run on ingress nodes, if any have been provisioned in the cluster. This is done by detecting any ingress nodes being passed in through the `node_groups` input variable. If no ingress nodes are provisioned, the core internal ingress pods will continue to run on system nodes.

#### Experimental Features

- Using a user-assigned NAT Gateway for cluster egress is supported as an experimental feature. This can be enabled by setting `experimental = { nat_gateway_id = "<nat_gateway_id>" }`.
experimental support for using a user-assigned NAT Gateway for cluster egress traffic by setting `experimental = { nat_gateway_id = "<nat_gateway_id>" }`

### All Changes

- Added `lnrs.io/k8s-platform = true` common label to most k8s resources that allow custom labels via the Helm chart. ([#302](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/302)) [@prikesh-patel](https://github.com/prikesh-patel)
- Updated _Fluent Bit_ chart to [v0.20.6](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.6) (contains _Fluent Bit_ [v1.9.7](https://github.com/fluent/fluent-bit/releases/tag/v1.9.7)). ([#607](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/607), [#625](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/625)) [@peterabarr](https://github.com/peterabarr) [@prikesh-patel](https://github.com/prikesh-patel)
- Updated _External DNS_ chart to [v1.11.0](https://github.com/kubernetes-sigs/external-dns/releases/tag/external-dns-helm-chart-1.11.0) (contains _External DNS_ [v0.12.2](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.12.2)). ([#608](https://github.com/LexisNexis-RBA/rsg-terraform-aws-eks/issues/608)) [@prikesh-patel](https://github.com/prikesh-patel)
- Updated the _Ingress Nginx_ chart to [v4.2.3](https://github.com/kubernetes/ingress-nginx/releases/tag/helm-chart-4.2.3). ([#626](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/626)) [@prikesh-patel](https://github.com/prikesh-patel)
- Updated _Kube Prometheus Stack_ chart to [v39.9.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-39.9.0). ([#606](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/606)) [@prikesh-patel](https://github.com/prikesh-patel)
- Updated full AKS versions for `v1.23` to `v1.23.8` & `v1.22` to `v1.22.11`. ([#600](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/600)) [@stevehipwell](https://github.com/stevehipwell)
- Added `managed_outbound_ports_allocated` & `managed_outbound_idle_timeout` variables to enable further configuration of the cluster load balancer for egress. ([#618](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/618)) [@stevehipwell](https://github.com/stevehipwell)
- Changed default for cluster load balancer `outbound_idle_timeout` from `1800` to `240`. ([#618](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/618)) [@stevehipwell](https://github.com/stevehipwell)
- Added experimental support for using a user-assigned NAT Gateway for cluster egress traffic by setting `experimental = { nat_gateway_id = "<nat_gateway_id>" }`. ([#623](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/623)) [@stevehipwell](https://github.com/stevehipwell)
- Added support for running internal core ingress pods on ingress nodes. ([#567](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/567)) [@prikesh-patel](https://github.com/prikesh-patel)
- Added module outputs `coredns_custom_config_map_name` & `coredns_custom_config_map_namespace` to allow adding additional data to the CoreDNS custom `ConfigMap`. ([#581](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/581)) [@stevehipwell](https://github.com/stevehipwell)
- Fixed labels and taints for node group type `amd64-cpu`. ([#634](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/634)) [@prikesh-patel](https://github.com/prikesh-patel)

## [v1.0.0-beta.19] - 2022-08-15

### Highlights

The `v1.0.0-beta.19` release is a minor release of the Azure AKS Terraform Module. FIPS experimental support and Azure ultra disk support has been added. Several core service charts and images have been updated.

To discuss any topics regarding this release, please refer to the [AKS Release v1.0.0-beta.19 Discussion](https://github.com/LexisNexis-RBA/rsg-kubernetes/discussions/22).

#### FIPS

Experimental support for FIPS 140-2 has been added. This can be enabled by setting the `experimental = { fips = true }` module input.

#### Azure Ultra Disks

Azure ultra disks can be enabled on a node group by setting `ultra_ssd` to `true`, within the `node_groups` variable.

#### Latest Chart versions

The `v1.0.0-beta.19` release brings chart and image updates to _AAD Pod Identity_, _Ingress Nginx_ & _Kube Prometheus Stack_.

Thank you to [@stevehipwell](https://github.com/stevehipwell) and [@peterabarr](https://github.com/peterabarr) for their contributions.

### All Changes

- Added experimental support for FIPS 140-2 via the `experimental = { fips = true }` module input. ([#593](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/593)) [@stevehipwell](https://github.com/stevehipwell)
- Added support for enabling [Azure ultra disks](https://docs.microsoft.com/en-gb/azure/aks/use-ultra-disks) on a node group by setting `ultra_ssd` to `true`. ([#382](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/382)) [@stevehipwell](https://github.com/stevehipwell)
- Updated _AAD Pod Identity_ chart to `4.1.12` (contains _AAD Pod Identity_ [v1.8.11](https://github.com/Azure/aad-pod-identity/releases/tag/v1.8.11)). ([#591](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/591)) [@peterabarr](https://github.com/peterabarr)
- Updated _Ingress Nginx_ chart to [v4.2.1](https://github.com/kubernetes/ingress-nginx/releases/tag/helm-chart-4.2.1)(contains _Ingress Nginx Image_ [v1.3.0](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.3.0)). ([#597](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/597)) [@peterabarr](https://github.com/peterabarr)
- Updated _Kube Prometheus Stack_ chart to [v39.5.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-39.5.0) (contains _Grafana_ [v9.0.5](https://github.com/grafana/grafana/releases/tag/v9.0.5) & _Prometheus Operator_ [v0.58.0](https://github.com/prometheus-operator/prometheus-operator/releases/tag/v0.58.0). ([#582](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/582)) [@peterabarr](https://github.com/peterabarr)

## [v1.0.0-beta.18] - 2022-08-01

### Highlights

The 'v1.0.0-beta.18' release is a minor release of the Azure AKS Terraform Module. Support for Kubernetes v1.21 has been removed. Deprecated `node_group_templates` in favour of `node_groups`. The core services were updated to their latest chart versions.

### Latest Chart versions

The v1.0.0-beta.18 release includes the following chart version updates: _Fluent Bit_, _Kube Prometheus Stack_ and _Cert Manager_.

Thank you to [@stevehipwell](https://github.com/stevehipwell), [@prikesh-patel](https://github.com/prikesh-patel), [@james1miller93](https://github.com/james1miller93) and [@peterabarr](https://github.com/peterabarr) for their contributions.

### All Changes

> **Important**
> Ingress internal core load balancer configuration was previously incorrect. This may require manually deleting the `core-internal` helm release before reinstating via the module. If it's not safe to do this immediately, we advise setting the load balancer subnet name manually using the `core_services_config.ingress_internal_core.lb_subnet_name` input until the loadbalancer can be recreated safely. See [issue 499](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/499) for more detail.

#### Added

- Added new `node_groups` input variable to replace `node_group_templates`; this variable is a map and supports default values for simplicity. (#511) [@stevehipwell](https://github.com/stevehipwell)
- Add support for the [Lsv3](https://docs.microsoft.com/en-us/azure/virtual-machines/lsv3-series) series for storage optimised VMs. (#465) [@prikesh-patel](https://github.com/prikesh-patel)

#### Changed

- Changed the README to show all default values for variables. [@stevehipwell](https://github.com/stevehipwell)
- Changed the README to show no value in the default column in the variable grids if a user defined value is required. [@stevehipwell](https://github.com/stevehipwell)
- Revert change from `beta.10` where subnet annotation was added to `ingress-internal-core` loadbalancer configuration, creating undesirable behaviour. [@james1miller93](https://github.com/james1miller93)

#### Updated

- Update _Fluent Bit_ chart to [v0.20.4](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.4) (contains _Fluent Bit_ [v1.9.6](https://github.com/fluent/fluent-bit/releases/tag/v1.9.6)). ([#559](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/559)) [@peterabarr](https://github.com/peterabarr)
- Update _Kube Prometheus Stack_ chart to [v38.0.2](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-38.0.2)(contains _Grafana_ [v6.32.7](https://github.com/grafana/helm-charts/releases/tag/grafana-6.32.7))). ([#564](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/564)) [@peterabarr](https://github.com/peterabarr)
- Update _Cert Manager_ chart to [1.9.1](https://github.com/cert-manager/cert-manager/releases/tag/v1.9.1). ([#571](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/571)) [@peterabarr](https://github.com/peterabarr)

#### Fixed

- Fixed OMS Agent config namespaces. ([#577](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/577)) [@stevehipwell](https://github.com/stevehipwell)

#### Deprecated

- Deprecated `node_group_templates` in favour of `node_groups`. Switching to the new variable is as simple as creating a map with the name of the old object as the key and the rest of the object as the body, many of the fields can be omitted if you're using the defaults. ([#511](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/511)) [@stevehipwell](https://github.com/stevehipwell)

#### Removed

- Dropped support for Kubernetes version v1.21 following recent [announcement](https://github.com/Azure/AKS/releases/tag/2022-06-26.1). (#519) [@sossickd](https://github.com/sossickd)

## [v1.0.0-beta.17] - 2022-07-18

### Added

- Add ability to create custom folders in Grafana. (#357) [@sossickd](https://github.com/sossickd)

### Updated

- Update _Kube Prometheus Stack_ chart to [v37.2.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-37.2.0)(contains _Kube State Metrics_ [v4.13.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-state-metrics-4.13.0), _Grafana_ [v6.32.2](https://github.com/grafana/helm-charts/releases/tag/grafana-6.32.2)). (#515) [@peterabarr](https://github.com/peterabarr)
- Update _Fluent Bit_ chart to [v0.20.3](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.3) (contains _Fluent Bit_ [v1.9.5](https://github.com/fluent/fluent-bit/releases/tag/v1.9.5)). (#506) [@peterabarr](https://github.com/peterabarr)
- Update _External DNS_ chart to [v1.10.1](https://github.com/kubernetes-sigs/external-dns/releases/tag/external-dns-helm-chart-1.10.1) (contains _External DNS_ [v0.12.0](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.12.0)). (#543) [@peterabarr](https://github.com/peterabarr)

### Fixed

- Fixed `ingress-nginx-core-internal` grafana dashboard (#541) [@james1miller93](https://github.com/james1miller93)

## [v1.0.0-beta.16] - 2022-07-07

### Added

- Added support for [AKS v1.22](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli). (#518) [@sossickd](https://github.com/sossickd)
- New variable `managed_outbound_ip_count`. [@prikesh-patel](https://github.com/prikesh-patel)

### Changed

- Increase _Cert Manager_ `startupapicheck` timeout. [@prikesh-patel](https://github.com/prikesh-patel)

### Updated

- The _AAD Pod Identity_ chart has been upgraded to `4.1.11` (contains [v1.8.10](https://github.com/Azure/aad-pod-identity/releases/tag/v1.8.10) of the aad-pod-identity image). [@peterabarr](https://github.com/peterabarr)

### Fixed

- Fixed `kube-audit-admin` and `AllMetrics` being incorrectly re-enabled in external storage account. [@prikesh-patel](https://github.com/prikesh-patel)
- Fixed a bug introduced in v1.0.0-beta.15 where operators could not create a cluster from scratch. (#525) [@prikesh-patel](https://github.com/prikesh-patel)

## [v1.0.0-beta.15] - 2022-07-05

> **IMPORTANT**
> Control plane logging has been made fully configurable in this release so if you're currently overriding the defaults you will need to use the new variables to continue to do this (the behaviour is consistent). The main changes have been to allow control plane logs to be sent to a custom log analytics workspace, and to enable custom retention to be specified alongside the log categories to collect.

### Added

- Added CIDR validation to `var.cluster_endpoint_access_cidrs`. [@james1miller93](https://github.com/james1miller93)
- Added [ZeroSSL](https://zerossl.com/features/acme/) cluster issuer. (#365) [@sossickd](https://github.com/sossickd)
- Added control plane logging customisation via the `control_plane_logging_external_workspace`, `control_plane_logging_external_workspace_id`, `control_plane_logging_external_workspace_different_resource_group`, `control_plane_logging_workspace_categories`, `control_plane_logging_workspace_retention_enabled`, `control_plane_logging_workspace_retention_days`, `control_plane_logging_storage_account_enabled`, `control_plane_logging_storage_account_id`, `control_plane_logging_storage_account_categories`, `control_plane_logging_storage_account_retention_enabled` & `control_plane_logging_storage_account_retention_days` input variables. (#474) [@stevehipwell](https://github.com/stevehipwell)

### Changed

- Changed default retention for control plane logs sent to a storage account from 7 days to 30 days. (#474) [@stevehipwell](https://github.com/stevehipwell)
- Increased the _Grafana_ memory request/limit to support more intensive dashboards. (#516) [@prikesh-patel](https://github.com/prikesh-patel)
- Improved the _AKS Control Plane Logs_ _Grafana_ dashboard. [@prikesh-patel](https://github.com/prikesh-patel)

### Updated

- Update _Cert Manager_ chart to [1.8.2](https://github.com/cert-manager/cert-manager/releases/tag/v1.8.2). (#504) [@sossickd](https://github.com/sossickd)
- Updated _Kube Prometheus Stack_ chart to [v36.2.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-36.2.0) (contains _Grafana_ [v9.0.1](https://github.com/grafana/grafana/releases/tag/v9.0.1)). (#498) [@peterabarr](https://github.com/peterabarr)

### Fixed

- Fixed output `effective_outbound_ips` to provide correct value. [@prikesh-patel](https://github.com/prikesh-patel)

## Deprecated

- Deprecated Kubernetes version v1.21 following recent [announcement](https://github.com/Azure/AKS/releases/tag/2022-06-26.1). (#519) [@sossickd](https://github.com/sossickd)

## Removed

- Removed `logging_storage_account_enabled` & `logging_storage_account_id` input variables in favour of the new `control_plane_logging_storage_account_enabled` & `control_plane_logging_storage_account_id` input variables. (#474) [@stevehipwell](https://github.com/stevehipwell)
- Removed experimental `workspace_log_categories` & `storage_log_categories` settings in favour of the new control plane logging input variables. (#474) [@stevehipwell](https://github.com/stevehipwell)

## [v1.0.0-beta.14] - 2022-06-20

### Added

- Added `azure-disk-standard-ssd-ephemeral` and `azure-disk-premium-ssd-ephemeral` storage classes to support generic ephemeral volumes. [@james1miller93](https://github.com/james1miller93)
- Set `kube_token_ttl` to 600 in `Fluent-bit` configuration. [@peterabarr](https://github.com/peterabarr)
- Added default OMS agent configuration to block it capturing logs from core namespaces, this can be overridden by setting the `oms_agent_create_configmap` experimental argument to `false`. [@stevehipwell](https://github.com/stevehipwell)

### Changed

- Changed the `systemd` configuration paramater from `db_sync` to `db.sync`. [@peterabarr](https://github.com/peterabarr)
- Increase resources for _Kube Prometheus Stack/Kube State Metrics_. [@aydosman](https://github.com/aydosman)

### Updated

- Updated _Kube Prometheus Stack_ chart to [v36.0.2](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-36.0.2)(contains _Kube State Metrics_ [v4.9.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-state-metrics-4.9.0), _Grafana_ [v6.29.6](https://github.com/grafana/helm-charts/releases/tag/grafana-6.29.6), _Prometheus Node Exporter_ [v3.3.0](https://github.com/prometheus-community/helm-charts/releases/tag/prometheus-node-exporter-3.3.0), _Prometheus Operator_ [v0.57.0](https://github.com/prometheus-operator/prometheus-operator/releases/tag/v0.57.0), _Prometheus_ [v2.36.1](https://github.com/prometheus/prometheus/releases/tag/v2.36.1)). (#458) [@peterabarr](https://github.com/peterabarr)
- Updated _Fluent Bit_ chart to [v0.20.2](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.2) (contains _Fluent Bit_ [v1.9.4](https://github.com/fluent/fluent-bit/releases/tag/v1.9.4)). (#461) [@peterabarr](https://github.com/peterabarr)
- The _Ingress Nginx_ chart has been upgraded to [v4.1.1](https://github.com/kubernetes/ingress-nginx/releases/tag/helm-chart-4.1.1)(contains _Ingress Nginx Image_ [v1.2.1](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.2.1)). (#459) [@peterabarr](https://github.com/peterabarr)

## [v1.0.0-beta.13] - 2022-06-09

> **IMPORTANT**
> `logging_storage_account_enabled` must be set to `true` when passing `logging_storage_account_id` as an input.

### Changed

- Fixed bug where count cannot be determined until apply when `logging_storage_account_id` is input and storage account is created alongside cluster. [@james1miller93](https://github.com/james1miller93)

## [v1.0.0-beta.12] - 2022-06-06

### Added

- Added experimental support to specify the set of control plane log categories via the `workspace_log_categories` & `storage_log_categories` experimental arguments. [@stevehipwell](https://github.com/stevehipwell)
- Added version tag to cluster resource. [@james1miller93](https://github.com/james1miller93)

### Changed

- Fixed indentation on `node-exporter` Prometheus rule. [@prikesh-patel](https://github.com/prikesh-patel)
- Changed the default control plane log categories to use `kube-audit-admin` instead of `kube-audit`. [@stevehipwell](https://github.com/stevehipwell)
- Fixed bug where count cannot be determined until apply when resource group is created and `experimental.oms_agent` is enabled in same workspace. [@james1miller93](https://github.com/james1miller93)

### Updated

- Updated _Kube Prometheus Stack_ chart to [v35.4.2](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-35.4.2). (#455) [@james1miller93](https://github.com/james1miller93)

### Removed

- Removed experimental `kube_audit_object_store_only` variable and replaced it with the new `workspace_log_categories` & `storage_log_categories` experiments. [@stevehipwell](https://github.com/stevehipwell)

## [v1.0.0-beta.11] - 2022-05-23

### Added

- Added support for [AKS v1.22](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli). [@stevehipwell](https://github.com/stevehipwell)
- Added experimental support for excluding `kube-audit` logs from Log Analytics via the `kube_audit_object_store_only` experimental flag; this should only be used for cost concerns and isn't recommended from a Kubernetes perspective. [@stevehipwell](https://github.com/stevehipwell)

### Updated

- The _AAD Pod Identity_ chart has been upgraded to `4.1.10` (contains [v1.8.9](https://github.com/Azure/aad-pod-identity/releases/tag/v1.8.9) of the aad-pod-identity image). [@james1miller93](https://github.com/james1miller93)
- The _Fluent Bit_ chart has been upgraded to [v0.20.1](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.20.1) (contains _Fluent Bit_ [v1.9.3](https://github.com/fluent/fluent-bit/releases/tag/v1.9.3)). [@prikesh-patel](https://github.com/prikesh-patel)
- The _Kube Prometheus Stack_ chart has been upgraded to [v35.2.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-35.2.0). [@prikesh-patel](https://github.com/prikesh-patel)
- The _Ingress Nginx_ chart has been upgraded to [v4.1.1](https://github.com/kubernetes/ingress-nginx/releases/tag/helm-chart-4.1.1). [@prikesh-patel](https://github.com/prikesh-patel)

## [v1.0.0-beta.10] - 2022-05-09

> **Important**
> This release is a significant breaking change and intended to be the last in the `beta` series with a stable `rc` being planned for the next release.

### Added

- Added experimental support for [AKS v1.22](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli). [@stevehipwell](https://github.com/stevehipwell)
- Support for `cpu` node types. [@stevehipwell](https://github.com/stevehipwell)
- Support for `gp`, `gpd`, `mem` & `memd` `v2` node types. [@stevehipwell](https://github.com/stevehipwell)
- Node type & size documentation has been added to the module README. [@stevehipwell](https://github.com/stevehipwell)

### Changed

- The system node pools can now be upgraded automatically by the module. [@stevehipwell](https://github.com/stevehipwell)
- The node image versions should be automatically upgraded. [@stevehipwell](https://github.com/stevehipwell)
- The AKS cluster now only uses a single subnet with isolation expected to be clontrolled by node taints and network restrictions provided by `NetworkPolicies`. [@stevehipwell](https://github.com/stevehipwell)
- Control plane logging has been turned on for all types. [@stevehipwell](https://github.com/stevehipwell)
- Cert manager now has multiple ACME issuers installed so you can use the right one for each certificate. [@stevehipwell](https://github.com/stevehipwell)
- The internal ingress certificate is now created in the ingress namespace. [@stevehipwell](https://github.com/stevehipwell)
- Module variables have been changed, check the README for more details. [@stevehipwell](https://github.com/stevehipwell)
- Kubernetes based providers must be configured to use the `exec` plugin pattern. [@stevehipwell](https://github.com/stevehipwell)
- The module architecture has been flattened and simplified. [@stevehipwell](https://github.com/stevehipwell)
- This module can be used in a new Terraform workspace first apply as no `data` lookups are used that aren't known at plan. [@stevehipwell](https://github.com/stevehipwell)
- Unsupported features, Windows nodes and OMS Agent, have been moved behind the `experimental` variable. [@stevehipwell](https://github.com/stevehipwell)
- Terraform dependency graph has been updated to make sure that create and destroy steps happen in the correct order. [@stevehipwell](https://github.com/stevehipwell)

### Updated

- The `azurerm` Terraform provider has been updated to `v3`, this means all modules and resources in your workspace will need updating to support this. [@stevehipwell](https://github.com/stevehipwell)
- All core services have been aligned to the versions used in the EKS module. [@stevehipwell](https://github.com/stevehipwell)

### Removed

- The community module dependency has been removed. [@stevehipwell](https://github.com/stevehipwell)
- The module no longer exposes Kubernetes credentials, you need to use `az` and `kubelogin` to connect to the cluster. [@stevehipwell](https://github.com/stevehipwell)

## [v1.0.0-beta.9] - 2022-03-14

### Updated

- `fluent-bit` upgrade chart to [0.19.20](https://github.com/fluent/helm-charts/releases/tag/fluent-bit-0.19.20) ([#353](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/353)) [@james1miller93](https://github.com/james1miller93)
- `ingress-nginx` upgrade chart to [4.0.18](https://github.com/kubernetes/ingress-nginx/releases/tag/helm-chart-4.0.18) ([#358](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/358)) [@james1miller93](https://github.com/james1miller93)
- `kube-prometheus-stack` upgrade chart to [33.2.0](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-33.2.0) ([#354](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/354)) [@james1miller93](https://github.com/james1miller93)

## [v1.0.0-beta.8] - 2022-02-28

### Added

- `module` - added **sku_tier** variable to set [control plane SLA](https://docs.microsoft.com/en-us/azure/aks/uptime-sla) level [@dutsmiller](url) [@jamurtag](url)
- **BREAKING** - Added support for setting node pool [proximity placement group](https://docs.microsoft.com/en-us/azure/aks/reduce-latency-ppg#:~:text=A%20proximity%20placement%20group%20is,and%20tasks%20that%20complete%20quickly.) via the `placement_group_key` variable. [@stevehipwell](https://github.com/stevehipwell)

### Changed

- `aad-pod-identity` - updated chart to 4.1.8 ([#329](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/329)) [@james1miller93](https://github.com/james1miller93)
- `cert-manager` - replaced custom roles with builtin roles ([#236](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/236)) [@james1miller93](https://github.com/james1miller93)
- `cert-manager` - updated chart to 1.7.1 ([#330](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/330)) [@james1miller93](https://github.com/james1miller93)
- `external-dns` - replaced custom roles with builtin roles ([#236](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/236)) [@james1miller93](https://github.com/james1miller93)
- `fluent-bit` - updated chart to 0.19.19 ([#331](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/331)) [@james1miller93](https://github.com/james1miller93)
- `fluentd` - updated chart to 2.6.9 ([#332](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/332)) [@james1miller93](https://github.com/james1miller93)
- `ingress-nginx` - updated chart to 4.0.17 ([#334](https://github.com/LexisNexis-RBA/terraform-azurerm-aks/issues/3349)) [@james1miller93](https://github.com/james1miller93)
- `kube-prometheus-stack` - updated chart to [32.2.1](https://github.com/prometheus-community/helm-charts/releases/tag/kube-prometheus-stack-32.2.1) and CRDs to 0.54.0 (includes Grafana [v8.3.5](https://github.com/grafana/grafana/releases/tag/v8.3.5)) [@james1miller93](https://github.com/james1miller93)
- `provider-azurerm` - restrict azurerm terraform provider to v2 [prikesh-patel](https://github.com/prikesh-patel)
- Updated documentation. [@stevehipwell](https://github.com/stevehipwell)
- Update version of upstream AKS module. [@dutsmiller](url)

> **IMPORTANT** - As part of the `cert-manager` upgrade, all of the cert manager crds need to be patched manually `prior` to upgrading to the `v1.0.0-beta.8` tag. An [issue](https://github.com/cert-manager/cert-manager/issues/4831) has been raised against the upstream repository to track this. Please see [UPGRADE.md](/UPGRADE.md#from-v100-beta7-to-v100-beta8) for details.
> **IMPORTANT** - The _Cert Manager_ API versions `v1alpha2`, `v1alpha3`, and `v1beta1` have been removed. All _Cert Manager_ custom resources must only use `v1` before upgrading to this release. All certificates are already stored as `v1`, after this release you can only access deprecated API resources through the _Cert Manager_ API.

## [v1.0.0-beta.7] - 2022-02-08

### Added

- `documentation` - added [documentation](/UPGRADE.md) for module & AKS version upgrades [@sossickd](url)

### Changed

- `aad-pod-identity` - updated chart to 4.1.7 [@sossickd](url)
- `cert-manager` - added toleration and node selector for startupapicheck [@sossickd](url)
- `cluster-autoscaler` - disabled autoscaling for node pools when min/max settings are the same [@dutsmiller](url)
- `ingress_internal_core` updated chart to 4.0.16 [@sossickd](url)
- `ingress_internal_core` replace dashboard with Grafana dashboard [14314](https://grafana.com/grafana/dashboards/14314) [@sossickd](url)
- `kubectl provider` - enabled server-side-apply aad-pod-identity [@sossickd](url)
- `kube-prometheus-stack` - updated chart to 30.1.0 and CRDs to 0.53.1 (see **IMPORTANT** note below) [@sossickd](url)
- `kube-prometheus-stack` - added resource limits for prometheusConfigReloader [@sossickd](url)
- `kube-prometheus-stack` - enabled update strategy for node-exporter daemonset [@sossickd](url)
- `kube-prometheus-stack` - enabled service monitor for kube-state-metrics, node-exporter [@sossickd](url)
- `kubectl provider` - enabled server-side-apply aad-pod-identity, kube-promethues-stack, ingress_internal_core, rbac, identity [@sossickd](url)
- `grafana` - updated container image to 8.3.3, removed temporary fix to mitigate [CVE-2021-43798](https://nvd.nist.gov/vuln/detail/CVE-2021-43798) & [CVE-2021-43813](https://grafana.com/blog/2021/12/10/grafana-8.3.2-and-7.5.12-released-with-moderate-severity-security-fix/) [@sossickd](url)
- `module` - Kubernetes patch versions updated for 1.20 and 1.21 (see **IMPORTANT** note below) [@dutsmiller](url)
- `storage-classes` - migrate storage classes created by the module to [CSI drivers](https://docs.microsoft.com/en-us/azure/aks/csi-storage-drivers) for 1.21.x clusters (see IMPORTANT note below)[@sossickd](url)

### Removed

- `module` - dropped support for Kubernetes version 1.19 (see **IMPORTANT** note below) [@dutsmiller](url)

> **IMPORTANT** - Dropped support for Kubernetes version 1.19, patch versions updated for 1.20 and 1.21. This will instigate a cluster upgrade, refer to [UPGRADE.md](/UPGRADE.md) for module and Kubernetes version upgrade instructions and troubleshooting steps.
> **IMPORTANT** - Due to an upgrade of the `kube-state-metrics` chart as part of the `kube-prometheus-stack` upgrade, removal of its deployment needs to done manually `prior` to upgrading to the `v1.0.0-beta.7` tag. Please see [UPGRADE.md](/UPGRADE.md#from-v100-beta6-to-v100-beta7) for details.
> **IMPORTANT** - The following storage classes have been migrated to CSI drivers in the 1.21 release - `azure-disk-standard-ssd-retain`, `azure-disk-premium-ssd-retain`, `azure-disk-standard-ssd-delete` and `azure-disk-premium-ssd-delete`. If you created custom storage classes using the kubernetes.io/azure-disk or kubernetes.io/azure-file provisioners they will need to be [migrated to CSI drivers](https://docs.microsoft.com/en-us/azure/aks/csi-storage-drivers#migrating-custom-in-tree-storage-classes-to-csi). Please use `v1.0.0-beta.7` or above to create new 1.21 clusters.

## [v1.0.0-beta.6] - 2022-01-14

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- `coredns` - added corends module to support on-premise name resolution [@sossickd](url)
- `module` - added required core_services_config parameters to examples [@sossickd](url)

### Changed

- `fluent-bit` - updated chart to 0.19.16 [@sossickd](url)
- `fluent-bit` - revert cri multi-line parser back to the standard parser until upstream [issue](https://github.com/fluent/fluent-bit/issues/4377) has been fixed [@sossickd](url)
- `fluentd` - updated chart to 2.6.7 [@sossickd](url)
- `fluentd` - fix image tag and repository override [@sossickd](url)
- `external-dns` - updated chart to 1.7.1 [@sossickd](url)
- `local_storage` - added dependency on kube-prometheus-stack CRDs [@sossickd](url)
- `module` - removed providers from module and version constraints from sub-modules (see IMPORTANT note below) [@sossickd](url)
- `cert-manager` - updated chart and CRDs to 1.6.1 [@sossickd](url)
- `kubectl provider` - enabled server-side-apply for fluent-bit, cert-manager [@sossickd](url)

> **IMPORTANT** - Providers have now been removed from the module which requires changes to the Terraform workspace. All providers **must** be declared and configuration for the `kubernetes`, `kubectl` & `helm` providers **must** be set. See [examples](/examples) for valid configuration and review the [CHANGELOG](/CHANGELOG.md) on each release.

## [v1.0.0-beta.5] - 2021-12-14

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- `CSI` - added local volume provisioner for local nvme & ssd disks [@dutsmiller](url)
- `Diagnostics` - AKS control plane logs written to log analytics workspace in cluster resource group [@sossickd](url)

### Changed

- `API` - added version field to node_types (see **IMPORTANT** note below) [@dutsmiller](url)
- `AzureUSGovernmentCloud` - added `azure_environment` variable to set cloud environment [@dutsmiller](url)
- `AzureUSGovernmentCloud` - added support for AAD member users [@dutsmiller](url) [@jamurtag](url)
- `AzureUSGovernmentCloud` - added support in external-dns & cert-manager [@sossickd](url)
- `Documentation` - clarification of Windows node pool support [@jamurtag](url)
- `external-dns` - changed logging format to json [@sossickd](url)
- `fluent-bit` - updated chart to 0.19.5 [@sossickd](url)
- `fluent-bit` - added update strategy & [multiline](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/multiline-parsing) support [@sossickd](url)
- `fluentd` - updated chart to 2.6.5 [@sossickd](url)
- `fluentd` - changed filter_config, route_config & output_config variables to filters, routes & outputs [@sossickd](url)
- `fluentd` - support for custom image repository and tag via image_repository & image_tag variables [@sossickd](url)
- `fluentd` - add extra fields to logs including cluster_name, subscription_id and location [@sossickd](url)
- `kube-prometheus-stack` - updated chart to 19.3.0 & CRDs to 0.50.0 [@sossickd](url)
- `kubectl provider` - updated version to 1.12.1 [@dutsmiller](url)
- `kubectl provider` - enabled server-side-apply for fluentd, kube-prometheus-stack, external-dns [@sossickd](url)
- `Grafana` - updated container image to 8.3.2 to mitigate [CVE-2021-43798](https://nvd.nist.gov/vuln/detail/CVE-2021-43798) & [CVE-2021-43813](https://grafana.com/blog/2021/12/10/grafana-8.3.2-and-7.5.12-released-with-moderate-severity-security-fix/) [@jamurtag](url)
- `Grafana` - managed identity support & Azure role assignment for access to managed resources [@jamurtag](url)
- `Grafana` - added grafana_identity output for custom Azure role assignments [@jamurtag](url)
- `Grafana` - added Azure Monitor data source for access to Azure resources [@sossickd](url)
- `Grafana` - added dashboard to view control plane diagnostics logs [@sossickd](url)
- `Tags` - added cloud tags to all provisioned resources [@prikesh-patel](url)
- `VM Types` - added gpd, mem, memd, and stor vm types (see [matrix](./modules/nodes/matrix.md) for node types) [@dutsmiller](url)

> **IMPORTANT** - Existing node types must have "-v1" appended to be compatible with beta.5.  Example:  The beta.4 node type of "x64-gp" would need to be changed to "x64-gp-v1" to maintain compatibility .  All future node types will be versioned.  See [matrix](./modules/nodes/matrix.md) for node types and details.
> **IMPORTANT** - If you are currently using `filter_config`, `route_config` or `output_config` in the fluentd section of the core_services_config these will need to be renamed accordingly.

## [v1.0.0-beta.4] - 2021-11-02

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Changed

- ingress-nginx chart updated to version 4.0.6 [@jamurtag](url)
- aad-pod-identity chart updated to version 4.1.5 [@jamurtag](url)
- aad-pod-identity requests and limits lowered for both NMI and MIC pods [@jamurtag](url)
- Default to AzurePublicCloud in cert-manager config [@jamurtag](url)
- Minor formatting change to cert-manager cluster-issuer config [@sossickd](url)
- Reduced ingress-nginx cpu / memory requests to 50m / 128MB (from 200m / 256MB) [@jamurtag](url)
- Changed prometheus-operator memory requests / limits to 128MB / 512 MB (from 256MB / 256MB) [@jamurtag](url)
- Changed kube-state-metrics memory requests / limits to 128MB / 1024MB (from 256MB / 512MB) [@jamurtag](url)
- Added documentation for system node pool service resource tracking and reporting [@jamurtag](url)
- Explicitly set Azure Policy and Dashboard add-on status to avoid noise in plans [@dutsmiller](url)
- Improve Virtual Network documentation [@dutsmiller](url)
- Explicitly set max_pods for kubenet/AzureCNI [@dutsmiller](url)
- Set `allowSnippetAnnotations` to `false` on ingress-nginx chart to mitigate [security vulnerability](https://www.armosec.io/blog/new-kubernetes-high-severity-vulnerability-alert-cve-2021-25742) [@prikesh-patel](url)
- Updated support policy regarding Windows node pools and nested Terraform modules [@jamurtag](url)

## [v1.0.0-beta.3] - 2021-09-29

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- AzureUSGovernmentCloud support in cert-manager [@jhisc](url)
- Helm chart for external-dns to create dns records in Azure private dns-zones [@sossickd](url)
- Grafana dashboard for external-dns [@sossickd](url)
- Grafana dashboard for ingress_internal_core [@sossickd](url)

### Changed

- Helm chart renamed from external-dns to external-dns-public [@sossickd](url)
- External dns helm chart moved from [bitnami external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns) to [kubernetes-sigs external-dns](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns) [@sossickd](url)
- Updated ingress_internal_core to helm version 4.0.2 [@sossickd](url)
- Updated kubernetes provder to v2.5 [@fabiendelpierre](url)

> **IMPORTANT** - Please change the core_services_config input for external_dns.

## [v1.0.0-beta.2] - 2021-09-10

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- Cluster ID output [@dutsmiller](url)

### Changed

- Set ingress-nginx & PrometheusOperator adminissionWebhook to run on system nodepool [@jamurtag](url)
- Output changed:  aks_cluster_name -> cluster_name [@dutsmiller](url)

## [v1.0.0-beta.1] - 2021-08-20

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- Azure Log Analytics support [@appkins](url)
- Ingress node pool [@dutsmiller](url)

### Changed

- Fix default-ssl-certificate in ingress_internal_core module [@sossickd](url)
- User guide updates [@jamurtag](url)

## [v0.12.0] - 2021-08-11

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- Support for k8s 1.21 [@dutsmiller](url)

### Changed

- Node pool variable changes [@dutsmiller](url)
- Change pod_cidr variable to podnet_cidr [@dutsmiller](url)
- Change core_services_config ingress_core_internal to ingress_internal_core [@dutsmiller](url)
- Change multi-vmss node pool capacity format [@dutsmiller](url)

### Removed

- Remove configmaps, secrets and namespaces variables [@dutsmiller](url)
- Remove assignment of public IPs for nodes in public subnet [@dutsmiller](url)

## [v0.11.0] - 2021-07-27

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- Calico network policy support [@jamurtag](url)
- AKS API firewall support [@dutsmiller](url)

### Changed

- Update README and simplify core_services_config variable input [@jamurtag](url)
- Update upstream AKS module version [@dutsmiller](url)
- Change name of UAI for AKS [@dutsmiller](url)
- Force host encryption to true [@dutsmiller](url)

### Removed

- Remove additional_priority_classes and additional_storage_classes api options [@jamurtag](url)
- Remove autodoc from repo [@dutsmiller](url)

## [v0.10.0] - 2021-07-19

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Changed

- Tolerate stateful services on system nodepools [@jamurtag](url)
- Rename config variable to core_services_config [@jamurtag](url)

## [v0.9.0] - 2021-07-14

> **IMPORTANT** - This pre-release isn't guaranteed to be stable and should not be used in production.

### Added

- Added wildcard certificate for core services [@sossickd](url)
- Documentation for cert-manager, external-dns, priority classes and storage claasses [@fabiendelpierre](url)

### Changed

- Node pool format to match EKS [@dutsmiller](url)
