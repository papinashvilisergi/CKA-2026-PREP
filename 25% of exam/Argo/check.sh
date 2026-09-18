#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Argo — checking ==="

check "helm repo 'argo' is registered" \
  "helm repo list 2>/dev/null | grep -qE '^argo\s'"

check "repo URL is the official argo-helm one" \
  "helm repo list 2>/dev/null | grep argo | grep -q 'argoproj.github.io/argo-helm'"

check "output file exists at /home/cloud_user/argo-helm.yaml" \
  "[ -s /home/cloud_user/argo-helm.yaml ]"

check "output file contains NO CustomResourceDefinition (CRDs disabled)" \
  "! grep -q 'kind: CustomResourceDefinition' /home/cloud_user/argo-helm.yaml"

check "output file targets namespace argocd" \
  "grep -q 'namespace: argocd' /home/cloud_user/argo-helm.yaml"

check "output was NOT actually installed to the cluster (task asked for template only)" \
  "! kubectl get deploy -n argocd argocd-server &>/dev/null"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
