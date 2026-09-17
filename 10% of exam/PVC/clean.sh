#!/bin/bash
set -e
kubectl delete namespace mariadb --ignore-not-found=true
kubectl delete pv mariadb-pv --ignore-not-found=true
rm -f ~/mariadb-deployment.yaml
echo "Cleared. Run run.sh again to retry."
