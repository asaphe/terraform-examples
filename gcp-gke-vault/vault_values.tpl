global:
  enabled: true
  imagePullSecrets: []
  tlsDisable: true

injector:
  enabled: true
  externalVaultAddr: ""
  image:
    repository: "hashicorp/vault-k8s"
    tag: "0.2.0"
    pullPolicy: IfNotPresent
  agentImage:
    repository: "vault"
    tag: "1.3.2"
  namespaceSelector: {
    matchLabels: {
      injection: enabled
    }
  }
  certs:
    secretName: null
    caBundle: ""
    certName: tls.crt
    keyName: tls.key
  resources: {}

server:
  image:
    repository: "vault"
    tag: "1.3.2"
    pullPolicy: IfNotPresent
  updateStrategyType: "OnDelete"
  resources:
  ingress:
    enabled: false
  authDelegator:
    enabled: false
  extraContainers: null
  shareProcessNamespace: false
  extraArgs: ""
  readinessProbe:
    enabled: true
  livenessProbe:
    enabled: false
    path: "/v1/sys/health?standbyok=true"
    initialDelaySeconds: 60
  preStopSleepSeconds: 5

  extraEnvironmentVars: {
      GOOGLE_REGION: global,
      GOOGLE_PROJECT: ${project_name},
      GOOGLE_APPLICATION_CREDENTIALS: '/vault/userconfig/kms-creds/.sa_credentials.json'
  }

  extraSecretEnvironmentVars: []

  extraVolumes:
    - type: 'secret'
      name: 'kms-creds'
      path: '/vault/userconfig/'

  affinity: |
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: {{ template "vault.name" . }}
              app.kubernetes.io/instance: "{{ .Release.Name }}"
              component: server
          topologyKey: kubernetes.io/hostname
  tolerations: {}
  nodeSelector: {}
  extraLabels: {}
  annotations: {}

  service:
    enabled: true
    port: 8200
    targetPort: 8200
    annotations: {}

  dataStorage:
    enabled: true
    size: 10Gi
    storageClass: null
    accessMode: ReadWriteOnce

  auditStorage:
    enabled: true
    size: 10Gi
    storageClass: null
    accessMode: ReadWriteOnce

  dev:
    enabled: false

  standalone:
    enabled: false

  ha:
    enabled: true
    replicas: 3
    config: |
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "gcs" {
        bucket     = "${bucket_name}"
        ha_enabled = "true"
      }
      seal "gcpckms" {
        project     = "${project_name}"
        region      = "global"
        key_ring    = "${key_ring}"
        crypto_key  = "${crypto_key}"
      }

    disruptionBudget:
      enabled: true
      maxUnavailable: null

  serviceAccount:
    annotations: {}

ui:
  enabled: true
  serviceType: "ClusterIP"
  serviceNodePort: null
  externalPort: ${ui_port}
  annotations: {}