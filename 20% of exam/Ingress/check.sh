#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Ingress — checking ==="

check "Ingress app-ingress exists in cka-ingress" \
  "kubectl get ingress app-ingress -n cka-ingress &>/dev/null"

check "uses ingressClassName nginx" \
  "[ \"\$(kubectl get ingress app-ingress -n cka-ingress -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)\" = 'nginx' ]"

check "/app path routes to app-service:80" \
  "kubectl get ingress app-ingress -n cka-ingress -o json 2>/dev/null | python3 -c \"
import json,sys
d=json.load(sys.stdin)
paths=d['spec']['rules'][0]['http']['paths']
match=[p for p in paths if p['path']=='/app' and p['backend']['service']['name']=='app-service' and p['backend']['service']['port']['number']==80]
exit(0 if match else 1)
\""

check "/admin path routes to admin-service:80" \
  "kubectl get ingress app-ingress -n cka-ingress -o json 2>/dev/null | python3 -c \"
import json,sys
d=json.load(sys.stdin)
paths=d['spec']['rules'][0]['http']['paths']
match=[p for p in paths if p['path']=='/admin' and p['backend']['service']['name']=='admin-service' and p['backend']['service']['port']['number']==80]
exit(0 if match else 1)
\""

check "both rules use pathType Prefix" \
  "[ \"\$(kubectl get ingress app-ingress -n cka-ingress -o jsonpath='{.spec.rules[0].http.paths[*].pathType}' 2>/dev/null)\" = 'Prefix Prefix' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
