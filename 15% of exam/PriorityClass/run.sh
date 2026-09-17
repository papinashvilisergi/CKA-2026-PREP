#!/bin/bash
set -e
kubectl create namespace priority --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: user-existing
value: 10000
globalDefault: false
description: "existing user-defined priority class"
EOF

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "while true; do echo logging...; sleep 5; done"]
EOF

cat <<'TASK'
==================================================================
TASK: PriorityClass
==================================================================
A Deployment named busybox-logger exists in the priority namespace.
An existing user-defined PriorityClass user-existing has value
10000.

Task:
1. Create a new PriorityClass named high-priority with a value
   one less than the highest existing user-defined value
   (i.e. 9999)
2. Patch the busybox-logger Deployment to use high-priority
==================================================================
TASK
