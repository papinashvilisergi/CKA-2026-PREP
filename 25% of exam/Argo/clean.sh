#!/bin/bash
set -e
helm repo remove argo 2>/dev/null || true
rm -f /home/cloud_user/argo-helm.yaml
echo "Cleared. Run run.sh again to retry."
