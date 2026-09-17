#!/bin/bash
set -e
rm -f /root/resources.yaml /root/documentation.txt
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.crds.yaml --ignore-not-found=true 2>/dev/null || true
echo "Cleared. Run run.sh again to retry."
