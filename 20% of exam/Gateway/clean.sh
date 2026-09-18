#!/bin/bash
set -e
kubectl delete namespace web-app --ignore-not-found=true
kubectl delete gatewayclass nginx --ignore-not-found=true
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml --ignore-not-found=true 2>/dev/null || true
echo "Cleared. Run run.sh again to retry."
