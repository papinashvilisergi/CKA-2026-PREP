#!/bin/bash
set -e

# Clean any previous attempt
helm repo remove argo 2>/dev/null || true
rm -f /home/cloud_user/argo-helm.yaml
mkdir -p /home/cloud_user

# The task premise is that CRDs are already pre-installed — make that true,
# so "install without CRDs" is a meaningful instruction rather than a guess.
echo "Pre-installing Argo CD CRDs (per task premise) ..."
if kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.13.0" 2>/dev/null; then
  echo "Argo CD CRDs installed."
else
  echo "WARNING: CRD pre-install failed (no internet?). The task premise assumes they exist."
fi

cat <<"TASK"
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
