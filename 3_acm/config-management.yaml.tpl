apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  channel: cs
  # clusterName is required and must be unique among all managed clusters
  clusterName: ${CONTEXT}
  enableMultiRepo: true
  enableLegacyFields: false
  policyController:
    enabled: true
