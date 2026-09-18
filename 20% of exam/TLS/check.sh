#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== TLS — checking ==="

check "ConfigMap tls-config exists in secure-space" \
  "kubectl get cm tls-config -n secure-space &>/dev/null"

check "ssl_protocols line contains ONLY TLSv1.3 (not TLSv1.2 too)" \
  "kubectl get cm tls-config -n secure-space -o jsonpath='{.data.nginx\.conf}' 2>/dev/null | grep 'ssl_protocols' | grep -q 'TLSv1.3' && ! kubectl get cm tls-config -n secure-space -o jsonpath='{.data.nginx\.conf}' 2>/dev/null | grep 'ssl_protocols' | grep -q 'TLSv1.2'"

check "secure-web pod is actually serving the NEW config (live, not stale)" \
  "kubectl exec -n secure-space deploy/secure-web -- cat /etc/nginx/nginx.conf 2>/dev/null | grep 'ssl_protocols' | grep -q 'TLSv1.3' "

check "the running pod's config does NOT still allow TLSv1.2" \
  "! kubectl exec -n secure-space deploy/secure-web -- cat /etc/nginx/nginx.conf 2>/dev/null | grep 'ssl_protocols' | grep -q 'TLSv1.2'"

check "secure-web Deployment is fully rolled out (no stale pods from before the restart)" \
  "[ \"\$(kubectl get deploy secure-web -n secure-space -o jsonpath='{.status.updatedReplicas}')\" = \"\$(kubectl get deploy secure-web -n secure-space -o jsonpath='{.status.replicas}')\" ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
