#!/bin/bash
set -e
kubectl delete namespace web-app --ignore-not-found=true
kubectl delete gatewayclass nginx --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
