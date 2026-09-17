#!/bin/bash
set -e
kubectl create namespace prepium --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: front-end
  namespace: prepium
  labels:
    app: front-end
spec:
  replicas: 1
  selector:
    matchLabels:
      app: front-end
  template:
    metadata:
      labels:
        app: front-end
    spec:
      containers:
      - name: nginx
        image: nginx
EOF

cat <<'TASK'
==================================================================
TASK: NodePort
==================================================================
The front-end Deployment in namespace prepium has an nginx
container with no port specification.

Task 1: Set your current namespace context to prepium.

Task 2: Update the Deployment to add a container port named http
(port 80/TCP).

Task 3: Create a Service named front-end-svc that:
- Selects pods with app: front-end
- Exposes port 80
- Uses targetPort: http to reference the named pod port
- Type: NodePort
==================================================================
TASK
