#!/bin/bash
set -e

# Actually install the cert-manager CRDs the task depends on,
# so "list all cert-manager CRDs" has something real to find.
echo "Installing cert-manager CRDs ..."
if kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.crds.yaml; then
  echo "CRDs installed."
else
  echo "WARNING: install failed (no internet?). The task needs cert-manager CRDs present."
fi

sleep 5
echo "Current cert-manager CRDs:"
kubectl get crd | grep cert-manager || echo "(none found)"

rm -f /root/resources.yaml /root/documentation.txt

cat <<"TASK"
==================================================================
TASK: Cert — cert-manager CRDs
==================================================================
1. Create a list of all cert-manager CRDs and save it to
   /root/resources.yaml
2. Using kubectl, extract the documentation for the subject
   specification field of the Certificate Custom Resource and
   save it to /root/documentation.txt

You may use any output format that kubectl supports.
==================================================================
TASK
