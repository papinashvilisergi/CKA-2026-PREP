#!/bin/bash
set -e
kubectl delete namespace priority --ignore-not-found=true
kubectl delete priorityclass user-existing high-priority --ignore-not-found=true
echo "Cleared. Run run.sh again to retry."
