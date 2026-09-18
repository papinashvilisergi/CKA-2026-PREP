#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== PriorityClass — checking ==="

check "PriorityClass high-priority exists" \
  "kubectl get priorityclass high-priority &>/dev/null"

check "value is exactly 9999 (one less than user-existing's 10000)" \
  "[ \"\$(kubectl get priorityclass high-priority -o jsonpath='{.value}' 2>/dev/null)\" = '9999' ]"

check "not set as globalDefault" \
  "[ \"\$(kubectl get priorityclass high-priority -o jsonpath='{.globalDefault}' 2>/dev/null)\" != 'true' ]"

check "busybox-logger Deployment uses high-priority in its template" \
  "[ \"\$(kubectl get deploy busybox-logger -n priority -o jsonpath='{.spec.template.spec.priorityClassName}' 2>/dev/null)\" = 'high-priority' ]"

check "the actual running pod has priority 9999 (not just the template)" \
  "[ \"\$(kubectl get pods -n priority -l app=busybox-logger -o jsonpath='{.items[0].spec.priority}' 2>/dev/null)\" = '9999' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
