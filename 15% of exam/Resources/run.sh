#!/bin/bash
set -e
kubectl create namespace resources-ns --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: resources-ns
spec:
  hard:
    requests.cpu: "30m"
    requests.memory: 30Mi
    limits.cpu: "30m"
    limits.memory: 30Mi
EOF

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: resources-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:1-alpine
EOF

sleep 5
cat <<'TASK'
==================================================================
TASK: Resources
==================================================================
The web-app Deployment in namespace resources-ns has 3 replicas
but none of the pods are running.

A ResourceQuota has been applied to the namespace that limits
total CPU and memory. The Deployment does not have resource
requests or limits configured, so the pods are being blocked by
the quota.

Task:
1. Investigate why the pods are not being created
2. Inspect the ResourceQuota to find the total CPU and memory
   budget
3. Edit the Deployment so that each pod gets an equal share of
   the quota (requests must equal limits)
4. Confirm all 3 pods are Running
==================================================================
TASK
