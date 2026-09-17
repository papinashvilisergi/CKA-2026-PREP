#!/bin/bash
set -e
kubectl create namespace mariadb --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
  labels:
    app: mariadb
spec:
  capacity:
    storage: 300Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/data/mariadb
EOF

cat <<'EOF' > ~/mariadb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.6
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpass
        volumeMounts:
        - name: mariadb-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        persistentVolumeClaim:
          claimName: ""
EOF

echo "Setup complete."
cat <<'TASK'
==================================================================
TASK: PVC — Restore MariaDB
==================================================================
A MariaDB Deployment in namespace mariadb was deleted by mistake.
A retained PV named mariadb-pv (300Mi, storageClass: standard)
already exists.

Task 1: Create a PVC in namespace mariadb:
- Name: mariadb
- Storage: 250Mi
- AccessMode: ReadWriteOnce
- Must bind to the existing PV mariadb-pv

Task 2: Update ~/mariadb-deployment.yaml to mount the PVC at
/var/lib/mysql and apply it.
==================================================================
TASK
