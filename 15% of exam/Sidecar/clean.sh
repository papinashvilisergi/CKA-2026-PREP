#!/bin/bash
set -e
kubectl delete namespace wordpress-ns --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
