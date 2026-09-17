#!/bin/bash
set -e
echo "Setup: assumes cert-manager CRDs are already installed (per task premise)."
cat <<'TASK'
==================================================================
TASK: Argo — ArgoCD Helm Template
==================================================================
Install Argo CD using Helm without installing CRDs (they are
pre-installed).

Requirements:
1. Add the official Argo CD Helm repo with the name argo
   (https://argoproj.github.io/argo-helm)
2. Generate a Helm template (not install) for chart version 7.7.3,
   namespace argocd, with CRDs disabled
3. Save the generated manifest to /home/cloud_user/argo-helm.yaml
==================================================================
TASK
