#!/usr/bin/env bash

kubectl exec -ti vault-0 -n vault -- sh -c "vault kv put secret/helloworld username='appuser' \
                                            password='suP3rsec(et!' \
                                            ttl='30s'"