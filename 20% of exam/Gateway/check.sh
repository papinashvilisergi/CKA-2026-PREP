#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Gateway — checking ==="

check "Gateway web-gateway exists in web-app" \
  "kubectl get gateway web-gateway -n web-app &>/dev/null"

check "GatewayClass is nginx" \
  "[ \"\$(kubectl get gateway web-gateway -n web-app -o jsonpath='{.spec.gatewayClassName}' 2>/dev/null)\" = 'nginx' ]"

check "listener hostname is gateway.web.k8s.local" \
  "kubectl get gateway web-gateway -n web-app -o jsonpath='{.spec.listeners[*].hostname}' 2>/dev/null | grep -q 'gateway.web.k8s.local'"

check "TLS uses secret web-tls" \
  "kubectl get gateway web-gateway -n web-app -o jsonpath='{.spec.listeners[*].tls.certificateRefs[*].name}' 2>/dev/null | grep -q 'web-tls'"

check "HTTPRoute web-route exists in web-app" \
  "kubectl get httproute web-route -n web-app &>/dev/null"

check "HTTPRoute parentRef points to web-gateway" \
  "kubectl get httproute web-route -n web-app -o jsonpath='{.spec.parentRefs[*].name}' 2>/dev/null | grep -q 'web-gateway'"

check "HTTPRoute hostname is gateway.web.k8s.local" \
  "kubectl get httproute web-route -n web-app -o jsonpath='{.spec.hostnames[*]}' 2>/dev/null | grep -q 'gateway.web.k8s.local'"

check "HTTPRoute backendRef is web-service on port 80" \
  "kubectl get httproute web-route -n web-app -o jsonpath='{.spec.rules[0].backendRefs[0].name}{\":\"}{.spec.rules[0].backendRefs[0].port}' 2>/dev/null | grep -q 'web-service:80'"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
