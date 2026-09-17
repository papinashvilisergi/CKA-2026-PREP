#!/bin/bash
set -e
kubectl create namespace web-app --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  namespace: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: web-app
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: web-app
spec:
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: example.net/nginx-gateway-controller
EOF

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/web-tls.key -out /tmp/web-tls.crt \
  -subj "/CN=gateway.web.k8s.local" 2>/dev/null
kubectl create secret tls web-tls -n web-app \
  --cert=/tmp/web-tls.crt --key=/tmp/web-tls.key \
  --dry-run=client -o yaml | kubectl apply -f -
rm -f /tmp/web-tls.key /tmp/web-tls.crt

cat <<'TASK'
==================================================================
TASK: Gateway API Migration
==================================================================
Migrate the existing Ingress web in namespace web-app to the new
Gateway API.

A GatewayClass named nginx is already installed. Use API version
v1 (the older v1beta1 is also accepted on this environment).

Task 1: Create a Gateway named web-gateway with:
- hostname: gateway.web.k8s.local
- TLS termination using secret web-tls
- GatewayClass: nginx

Task 2: Create an HTTPRoute named web-route with:
- hostname: gateway.web.k8s.local
- path prefix / -> service web-service:80
- parentRef: the web-gateway
==================================================================
TASK
