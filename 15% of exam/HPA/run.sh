#!/bin/bash
set -e
kubectl create namespace auto-scale --dry-run=client -o yaml | kubectl apply -f -
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prep-server
  namespace: auto-scale
  labels:
    app: prep-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prep-server
  template:
    metadata:
      labels:
        app: prep-server
    spec:
      containers:
      - name: prep-server
        image: httpd
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
          limits:
            cpu: 200m
EOF

cat <<'TASK'
==================================================================
TASK: HPA
==================================================================
Create an HPA named prep-hpa for the Deployment prep-server in
namespace auto-scale.

Requirements:
- CPU target: 50% utilization per pod
- Min replicas: 1
- Max replicas: 4
- Downscale stabilization window: 30 seconds
==================================================================
TASK
