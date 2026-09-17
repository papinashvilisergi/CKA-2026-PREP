#!/bin/bash
set -e
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

cat <<'TASK'
==================================================================
TASK: StorageClass
==================================================================
Create a new StorageClass named local-storage with the provisioner
rancher.io/local-path. Set volumeBindingMode to
WaitForFirstConsumer. Do not make it the default SC.

Patch the StorageClass to make it the default StorageClass.

Ensure local-storage is the only default class.

Do not modify any existing Deployments or PersistentVolumeClaims.
==================================================================
TASK
