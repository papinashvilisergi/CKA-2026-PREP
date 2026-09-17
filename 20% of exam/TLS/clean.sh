#!/bin/bash
set -e
kubectl delete namespace secure-space --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
