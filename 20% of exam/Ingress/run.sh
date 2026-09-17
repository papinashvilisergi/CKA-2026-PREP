#!/bin/bash
set -e
kubectl create namespace cka-ingress --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-server
  namespace: cka-ingress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-server
  template:
    metadata:
      labels:
        app: app-server
    spec:
      containers:
      - name: app-server
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: cka-ingress
spec:
  selector:
    app: app-server
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-server
  namespace: cka-ingress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admin-server
  template:
    metadata:
      labels:
        app: admin-server
    spec:
      containers:
      - name: admin-server
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: admin-service
  namespace: cka-ingress
spec:
  selector:
    app: admin-server
  ports:
  - port: 80
    targetPort: 80
EOF

cat <<'TASK'
==================================================================
TASK: Ingress
==================================================================
Two backend services already exist in namespace cka-ingress:
- app-service (port 80)
- admin-service (port 80)

An NGINX Ingress Controller is already installed in the cluster.

Task: Create an Ingress resource named app-ingress in namespace
cka-ingress that:
- Uses ingressClassName: nginx
- Routes path /app to app-service on port 80
- Routes path /admin to admin-service on port 80
- Uses pathType: Prefix for both rules
==================================================================
TASK
