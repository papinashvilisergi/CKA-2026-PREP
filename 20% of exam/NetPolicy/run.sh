#!/bin/bash
set -e
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend
spec:
  selector:
    app: backend
  ports:
  - port: 80
EOF

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

mkdir -p /root/exam_resources
cat <<'EOF' > /root/exam_resources/netpol1.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-x
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
EOF

cat <<'EOF' > /root/exam_resources/netpol2.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-z
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF

cat <<'EOF' > /root/exam_resources/netpol3.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy-y
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend
    - ipBlock:
        cidr: 172.16.0.0/16
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
EOF

cat <<'TASK'
==================================================================
TASK: NetPolicy
==================================================================
There are two deployments, Frontend and Backend.
Frontend is in the frontend namespace. Backend is in the backend
namespace.

Task: Look at the Network Policy YAML files in
/root/exam_resources. Decide which of the policies provides the
functionality to allow interaction between the frontend and the
backend deployments in the least permissive way, and deploy that
YAML.
==================================================================
TASK
