#!/usr/bin/env bash
set -euo pipefail

config_file="$(mktemp -p /tmp)"
trap '{ rm -f "${config_file}"; }' EXIT

export KUBECONFIG="${config_file}"

if [[ -n "${AZURE_ENVIRONMENT:-}" ]]
then
  az cloud set --name "${AZURE_ENVIRONMENT}"
fi

if [[ -n "${AZURE_TENANT_ID:-}" ]] && [[ -n "${AZURE_CLIENT_ID:-}" ]] && [[ -n "${AZURE_CLIENT_SECRET:-}" ]]
then
  az login --service-principal --user "${AZURE_CLIENT_ID}"  --password "${AZURE_CLIENT_SECRET}" --tenant "${AZURE_TENANT_ID}"
fi

az aks get-credentials --subscription "${SUBSCRIPTION_ID}" --resource-group "${RESOURCE_GROUP_NAME}" --name "${CLUSTER_NAME}"

kubectl config set-credentials "azure-user" \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=kubelogin \
  --exec-arg=get-token \
  --exec-arg=--server-id \
  --exec-arg="6dae42f8-4368-4678-94ff-3960e28e3630" \
  --exec-arg=--login\
  --exec-arg=azurecli

kubectl config set-context "${CLUSTER_NAME}" --cluster="${CLUSTER_NAME}" --user=azure-user

if [[ -z "$(kubectl --namespace monitoring get daemonset.apps -l app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=prometheus-node-exporter --output name)" ]] && [[ -n "$(kubectl --namespace monitoring get daemonset.apps -l release=kube-prometheus-stack,app=prometheus-node-exporter --output name)" ]]
then
  json_value_0="$(kubectl --namespace monitoring get "$(kubectl --namespace monitoring get daemonset.apps -l app=prometheus-node-exporter --output name)" --output json)"
  json_value_1="$(echo "${json_value_0}" | jq -r '.spec.selector.matchLabels."app" |= "prometheus-node-exporter"' | jq -r '.spec.selector.matchLabels."app.kubernetes.io/name" = .spec.selector.matchLabels."app" | del(.spec.selector.matchLabels."app")')"
  json_value_2="$(echo "${json_value_1}" | jq -r '.spec.selector.matchLabels."release" |= "kube-prometheus-stack"' | jq -r '.spec.selector.matchLabels."app.kubernetes.io/instance" = .spec.selector.matchLabels."release" | del(.spec.selector.matchLabels."release")')"
  json_value_3="$(echo "${json_value_2}" | jq -r '.spec.template.metadata.labels."app" |= "prometheus-node-exporter"' | jq -r '.spec.template.metadata.labels."app.kubernetes.io/name" = .spec.template.metadata.labels."app" | del(.spec.template.metadata.labels."app")')"
  json_value_4="$(echo "${json_value_3}" | jq '.spec.template.metadata.labels |= .+ {"app.kubernetes.io/instance": "kube-prometheus-stack"}')"

  kubectl --namespace monitoring delete "$(kubectl --namespace monitoring get daemonset.apps -l app=prometheus-node-exporter --output name)"
  echo "${json_value_4}" | kubectl apply -f -
fi
