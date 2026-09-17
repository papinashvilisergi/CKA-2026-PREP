#!/bin/bash
set -e
kubectl delete namespace cka-ingress --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
