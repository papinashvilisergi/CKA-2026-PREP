#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== NodePort — checking ==="

check "current context namespace is prepium" \
  "[ \"\$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)\" = 'prepium' ]"

check "front-end Deployment has a named port 'http' on 80/TCP" \
  "kubectl get deploy front-end -n prepium -o json 2>/dev/null | python3 -c \"
import json,sys
d=json.load(sys.stdin)
ports=d['spec']['template']['spec']['containers'][0].get('ports',[])
match=[p for p in ports if p.get('name')=='http' and p.get('containerPort')==80]
exit(0 if match else 1)
\""

check "Service front-end-svc exists" \
  "kubectl get svc front-end-svc -n prepium &>/dev/null"

check "Service type is NodePort" \
  "[ \"\$(kubectl get svc front-end-svc -n prepium -o jsonpath='{.spec.type}' 2>/dev/null)\" = 'NodePort' ]"

check "Service selects app=front-end" \
  "[ \"\$(kubectl get svc front-end-svc -n prepium -o jsonpath='{.spec.selector.app}' 2>/dev/null)\" = 'front-end' ]"

check "Service targetPort references the named port 'http', not a raw number" \
  "[ \"\$(kubectl get svc front-end-svc -n prepium -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)\" = 'http' ]"

check "Service has a real endpoint (proves the named port actually resolved)" \
  "[ \"\$(kubectl get endpoints front-end-svc -n prepium -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)\" != '' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
