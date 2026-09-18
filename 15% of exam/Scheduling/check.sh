#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Scheduling — checking ==="

check "pod gpu-pod exists in namespace cka-taints" \
  "kubectl get pod gpu-pod -n cka-taints &>/dev/null"

check "uses image nginx:1.25" \
  "[ \"\$(kubectl get pod gpu-pod -n cka-taints -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)\" = 'nginx:1.25' ]"

check "has a toleration for dedicated=gpu:NoSchedule" \
  "kubectl get pod gpu-pod -n cka-taints -o json 2>/dev/null | python3 -c \"import json,sys; d=json.load(sys.stdin); t=d['spec'].get('tolerations',[]); exit(0 if any(x.get('key')=='dedicated' and x.get('value')=='gpu' and x.get('effect')=='NoSchedule' for x in t) else 1)\""

check "has nodeSelector gpu=true" \
  "[ \"\$(kubectl get pod gpu-pod -n cka-taints -o jsonpath='{.spec.nodeSelector.gpu}' 2>/dev/null)\" = 'true' ]"

check "pod is Running" \
  "[ \"\$(kubectl get pod gpu-pod -n cka-taints -o jsonpath='{.status.phase}' 2>/dev/null)\" = 'Running' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
