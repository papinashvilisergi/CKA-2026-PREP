#!/bin/bash
set -e
kubectl delete namespace prepium --ignore-not-found=true
kubectl config set-context --current --namespace=default 2>/dev/null || true
echo "Cleared. Run run.sh again to retry."
