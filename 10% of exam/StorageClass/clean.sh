#!/bin/bash
set -e
kubectl delete storageclass local-storage --ignore-not-found=true
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 2>/dev/null || true
echo "Cleared. Run run.sh again to retry."
