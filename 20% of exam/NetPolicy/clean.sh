#!/bin/bash
set -e
kubectl delete namespace frontend backend --ignore-not-found=true
rm -rf /root/exam_resources
echo "Cleared. Run run.sh again to retry."
