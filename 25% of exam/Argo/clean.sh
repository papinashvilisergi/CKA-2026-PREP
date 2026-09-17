#!/bin/bash
set -e
helm repo remove argo 2>/dev/null || true
rm -f /home/cloud_user/argo-helm.yaml
kubectl delete -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.13.0" --ignore-not-found=true 2>/dev/null || true
echo "Cleared. Run run.sh again to retry."
