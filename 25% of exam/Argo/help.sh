#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm template argocd argo/argo-cd --version 7.7.3 --namespace argocd --set crds.install=false > /home/cloud_user/argo-helm.yaml
ls -l /home/cloud_user/argo-helm.yaml
==================================================================
HELPEOF
