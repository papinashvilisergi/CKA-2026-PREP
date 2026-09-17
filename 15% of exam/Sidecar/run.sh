#!/bin/bash
set -e
kubectl create namespace wordpress-ns --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wordpress-ns
  labels:
    app: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:php8.2-apache
        command:
        - /bin/sh
        - -c
        - while true; do echo 'WordPress is running...' >> /var/log/wordpress.log; sleep 5; done
EOF

cat <<'TASK'
==================================================================
TASK: Sidecar
==================================================================
Update the existing wordpress Deployment in the wordpress-ns
namespace, adding a sidecar container named sidecar using the
busybox:stable image to the existing pod.

The new sidecar container has to run the following command:
  /bin/sh -c "tail -f /var/log/wordpress.log"

Use an emptyDir volume named logs, mounted at /var/log in both
the wordpress and sidecar containers, to make the log file
wordpress.log available to the co-located container. The volume
must be named logs.
==================================================================
TASK
