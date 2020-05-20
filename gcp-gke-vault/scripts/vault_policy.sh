#!/usr/bin/env bash

kubectl exec -ti vault-0 -n vault -- sh -c 'cat << EOF > /tmp/app-policy.hcl
path "kv/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "kubernetes/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF'

kubectl exec -ti vault-0 -n vault -- sh -c 'vault policy write app-policy /tmp/app-policy.hcl'