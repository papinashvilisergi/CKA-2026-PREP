#!/bin/bash
set -e
kubectl create namespace secure-space --dry-run=client -o yaml | kubectl apply -f -

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls-secure.key -out /tmp/tls-secure.crt \
  -subj "/CN=secure.k8s.local" 2>/dev/null
kubectl create secret tls secure-tls -n secure-space \
  --cert=/tmp/tls-secure.crt --key=/tmp/tls-secure.key \
  --dry-run=client -o yaml | kubectl apply -f -
rm -f /tmp/tls-secure.key /tmp/tls-secure.crt

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: tls-config
  namespace: secure-space
immutable: true
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443 ssl;
        ssl_certificate /etc/nginx/tls/tls.crt;
        ssl_certificate_key /etc/nginx/tls/tls.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
          return 200 "Hello TLS\n";
        }
      }
    }
EOF

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-web
  namespace: secure-space
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-web
  template:
    metadata:
      labels:
        app: secure-web
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: tls
          mountPath: /etc/nginx/tls
      volumes:
      - name: config
        configMap:
          name: tls-config
      - name: tls
        secret:
          secretName: secure-tls
EOF

cat <<'TASK'
==================================================================
TASK: TLS
==================================================================
The secure-web Deployment in namespace secure-space uses a
ConfigMap tls-config that currently supports both TLS 1.2 and
TLS 1.3.

Task: Modify the configuration so that only TLS 1.3 is supported.

Note: ConfigMaps are immutable — you must delete and recreate it,
then restart the Deployment.
==================================================================
TASK
