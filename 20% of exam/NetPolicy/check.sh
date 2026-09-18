#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== NetPolicy — checking ==="

check "exactly one NetworkPolicy deployed in backend namespace" \
  "[ \"\$(kubectl get networkpolicy -n backend --no-headers 2>/dev/null | wc -l)\" = '1' ]"

check "the deployed policy is the least permissive one (podSelector-based, no ipBlock, no allow-all)" \
  "kubectl get networkpolicy -n backend -o json 2>/dev/null | python3 -c \"
import json,sys
d=json.load(sys.stdin)
items=d.get('items',[])
if not items: sys.exit(1)
spec=items[0]['spec']
ingress=spec.get('ingress',[])
# must NOT be allow-all (empty podSelector + empty ingress rule)
if spec.get('podSelector',{}) == {} : sys.exit(1)
for rule in ingress:
    for f in rule.get('from',[]):
        if 'ipBlock' in f: sys.exit(1)
sys.exit(0)
\""

check "frontend pod can actually reach backend on port 80" \
  "kubectl exec -n frontend \$(kubectl get pods -n frontend -o jsonpath='{.items[0].metadata.name}') -- curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 http://backend-service.backend.svc.cluster.local 2>/dev/null | grep -qE '^[23]'"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
