apiVersion: configsync.gke.io/v1alpha1
kind: RootSync
metadata:
  name: root-sync
  namespace: config-management-system
spec:
  sourceFormat: hierarchy
  git:
    repo: git@${GITLAB_HOSTNAME}:platform-admins/anthos-config-management.git
    branch: master
    dir: clusters/${CONTEXT}
    auth: ssh
    secretRef:
      name: git-crds
