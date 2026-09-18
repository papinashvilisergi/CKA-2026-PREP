#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== HPA — checking ==="

check "HPA prep-hpa exists in namespace auto-scale" \
  "kubectl get hpa prep-hpa -n auto-scale &>/dev/null"

check "targets Deployment prep-server" \
  "[ \"\$(kubectl get hpa prep-hpa -n auto-scale -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)\" = 'prep-server' ]"

check "CPU target is 50%" \
  "[ \"\$(kubectl get hpa prep-hpa -n auto-scale -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)\" = '50' ]"

check "minReplicas is 1" \
  "[ \"\$(kubectl get hpa prep-hpa -n auto-scale -o jsonpath='{.spec.minReplicas}' 2>/dev/null)\" = '1' ]"

check "maxReplicas is 4" \
  "[ \"\$(kubectl get hpa prep-hpa -n auto-scale -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)\" = '4' ]"

check "downscale stabilizationWindowSeconds is 30" \
  "[ \"\$(kubectl get hpa prep-hpa -n auto-scale -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}' 2>/dev/null)\" = '30' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
