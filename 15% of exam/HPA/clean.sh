#!/bin/bash
set -e
kubectl delete namespace auto-scale --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
