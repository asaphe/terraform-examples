#!/usr/bin/env bash
# sh doesn't support arrays. can only run in a shell that supports arrays

kubectl exec -ti vault-0 -n vault -- sh -c 'vault login $(cat /tmp/admin_token) || exit 1'

export VAULT_ADDR="http://127.0.0.1:8200"

declare -a TENANTS=('tenant0' 'tenant01' 'tenant02' 'tenant03' 'tenant04')

for tenant in "${TENANTS[@]}"; 
  do
  kubectl exec -ti vault-0 -n vault -- sh -c 'vault write database/roles/${tenant} db_name=postgres creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT CONNECT ON DATABASE postgres TO \"{{name}}\"; GRANT USAGE ON SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\";" default_ttl=1h max_ttl=24h;'
  kubectl exec -ti vault-0 -n vault -- sh -c 'vault write database/roles/${tenant} db_name=postgres revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN; REVOKE CONNECT ON DATABASE postgres FROM \"{{name}}\"; REVOKE USAGE ON SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL ON ALL SEQUENCES IN SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL ON ALL TABLES IN SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${tenant} FROM \"{{name}}\"; DROP ROLE \"{{name}}\";" default_ttl=3600 max_ttl=86400;'
  kubectl exec -ti vault-0 -n vault -- sh -c 'vault write database/roles/${tenant} db_name=postgres renew_statements="ALTER ROLE \"{{name}}\" PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT CONNECT ON DATABASE postgres TO \"{{name}}\"; GRANT USAGE ON SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\";" default_ttl=1h max_ttl=24h;'
done



