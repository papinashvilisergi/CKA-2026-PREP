#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
CKA: Restore MariaDB with retained PV

1. Inspect the PV

kubectl get pv mariadb-pv -o yaml | grep -E 'storageClassName|accessModes|capacity' -A1
Match the PVC storageClassName and accessModes to what you see on the PV, otherwise the PVC will not bind.

2. Create the PVC

Create mariadb-pvc.yaml:

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: mariadb
spec:
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
  volumeName: mariadb-pv
Apply it and confirm it binds:

kubectl apply -f mariadb-pvc.yaml
kubectl get pvc -n mariadb
The PVC status should be Bound.

volumeName: mariadb-pv is what forces the PVC to bind to that specific retained PV.

3. Edit the Deployment

vi ~/mariadb-deployment.yaml
Add volumeMounts to the MariaDB container and volumes to the pod spec:

spec:
  template:
    spec:
      containers:
      - name: mariadb
        # existing fields stay here
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: mariadb
Indentation matters: volumes: is at the same level as containers:, not inside the container.

4. Apply and verify

kubectl apply -f ~/mariadb-deployment.yaml
kubectl get pods -n mariadb
kubectl describe pod -n mariadb -l app=mariadb | grep -A2 Mounts
Watch out for

The PVC must be in the mariadb namespace.
The PV is retained. If it is still Released from an old PVC, clear spec.claimRef:
kubectl patch pv mariadb-pv -p '{"spec":{"claimRef":null}}'
volumes: goes under spec.template.spec, not under containers:.
==================================================================
HELPEOF
