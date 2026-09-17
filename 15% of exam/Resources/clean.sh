#!/bin/bash
set -e
kubectl delete namespace resources-ns --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
