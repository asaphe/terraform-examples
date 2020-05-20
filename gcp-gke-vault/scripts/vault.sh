#!/usr/bin/env bash

CLUSTER_NAME="${1}"
DB_IP="${2}"
DB_USERNAME="${3:-postgres}"
DB_PASSWORD="${4:-password}"

if [[ -z "${1}" ]]; then echo "Cluster name must be specified"; exit 1; fi
export SA_SECRET=$(kubectl -n vault get sa vault -o jsonpath='{.secrets[0].name}')
export SA_TOKEN=$(kubectl -n vault get secret "${SA_SECRET}" -o jsonpath='{.data.token}' | base64 --decode)
export K8S_CA_CERT=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='${CLUSTER_NAME}')].cluster.certificate-authority-data}" --raw --minify --flatten | base64 --decode)
export K8S_ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='${CLUSTER_NAME}')].cluster.server}")

kubectl exec -ti vault-0 -n vault -- sh -c 'VAULT_STATUS=$(vault status | grep  Initialized | grep -o "true"); if [[ "${VAULT_STATUS}" != "true" ]]; then vault operator init -format yaml > /tmp/tokens && cat /tmp/tokens | sed -n -e "s/^.*\(root_token: \)//p" > /tmp/admin_token; else echo "Initialized"; fi'
kubectl apply --filename=./yamls/vault-auth-serviceaccount.yaml

sleep 2

kubectl exec -ti vault-0 -n vault -- sh -c 'vault login $(cat /tmp/admin_token)' || exit 1
kubectl exec -ti vault-0 -n vault -- sh -c 'vault auth enable kubernetes &>/dev/null && echo "kubernetes auth enabled" || echo "already enabled"'
kubectl exec -ti vault-0 -n vault -- sh -c "vault write auth/kubernetes/config \
                                            token_reviewer_jwt='${SA_TOKEN}' \
                                            kubernetes_host='${K8S_ENDPOINT}' \
                                            kubernetes_ca_cert='${K8S_CA_CERT}'"
kubectl exec -ti vault-0 -n vault -- sh -c 'vault write "auth/kubernetes/role/demo-app" \
                                             bound_service_account_names=demo-app \
                                             bound_service_account_namespaces=demo \
                                             policies=app-policy \
                                             ttl=1h'
kubectl exec -ti vault-0 -n vault -- sh -c 'vault secrets enable database &>/dev/null && echo "database secret engine enabled" || echo "database secret engine already enabled"'


if [[ -z "${DB_IP}" ]]; then echo "Database IP must be specified to enable db auth"; else kubectl exec -ti vault-0 -n vault -- sh -c "vault write database/config/postgres plugin_name=postgresql-database-plugin connection_url='postgresql://{{username}}:{{password}}@${DB_IP}:5432/postgres?sslmode=disable' allowed_roles=* username=${DB_USERNAME} password=${DB_PASSWORD}"; fi

kubectl exec -ti vault-0 -n vault -- sh -c 'vault secrets enable kv &>/dev/null && echo "secret-engine kv enabled at default path" || echo "secret-engine kv enabled at default path already enabled"'
kubectl exec -ti vault-0 -n vault -- sh -c 'vault secrets enable -path=secret kv &>/dev/null && echo "secret-engine kv enabled at path /secret" || echo "secret-engine kv enabled at path /secret already enabled"'
