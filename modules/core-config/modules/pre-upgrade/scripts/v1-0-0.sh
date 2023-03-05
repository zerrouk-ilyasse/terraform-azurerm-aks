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

if [[ -n "$(kubectl get configmap -n default terraform-modules -o jsonpath='{.data}')" ]]
then
  kubectl patch configmap -n default terraform-modules --type='json' -p='[{"op": "replace", "path": "/data", "value":{}}]'
fi
