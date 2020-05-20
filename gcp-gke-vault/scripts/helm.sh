#!/usr/bin/env bash

bash -c "helm upgrade --install --namespace vault vault ./vault-helm --wait --cleanup-on-fail -f ./yamls/vault_values.yaml --kubeconfig ~/.kube/config || echo 'Error: check for failed deployments'"
