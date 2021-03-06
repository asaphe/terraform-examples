#!/usr/bin/env bash

declare -a TENANTS=('tenant0' 'tenant01' 'tenant02' 'tenant03' 'tenant04')

for tenant in "${TENANTS[@]}"; do
  kubectl exec -ti vault-0 -n vault -- sh -c "
  vault login \$(cat /tmp/admin_token);"
done


  # TO-DO: correct escaping to work via script
  # vault write database/roles/${tenant} db_name=postgres creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT CONNECT ON DATABASE postgres TO \"{{name}}\"; GRANT USAGE ON SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\""; default_ttl=1h max_ttl=24h;
  # vault write database/roles/${tenant} db_name=postgres revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN; REVOKE CONNECT ON DATABASE postgres FROM \"{{name}}\"; REVOKE USAGE ON SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL ON ALL SEQUENCES IN SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL ON ALL TABLES IN SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${tenant} FROM \"{{name}}\"; REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${tenant} FROM \"{{name}}\"; DROP ROLE \"{{name}}\""; default_ttl=3600 max_ttl=86400;
  # vault write database/roles/${tenant} db_name=postgres renew_statements="ALTER ROLE \"{{name}}\" PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT CONNECT ON DATABASE postgres TO \"{{name}}\"; GRANT USAGE ON SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${tenant} TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${tenant} TO \"{{name}}\""; default_ttl=1h max_ttl=24h;