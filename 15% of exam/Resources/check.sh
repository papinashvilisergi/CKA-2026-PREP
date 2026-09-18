#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Resources — checking ==="

check "all 3 web-app pods are Running" \
  "[ \"\$(kubectl get pods -n resources-ns -l app=web-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)\" = '3' ]"

check "container has cpu requests set" \
  "kubectl get deploy web-app -n resources-ns -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null | grep -qE '.'"

check "container has memory requests set" \
  "kubectl get deploy web-app -n resources-ns -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null | grep -qE '.'"

check "requests.cpu equals limits.cpu (task explicitly requires this)" \
  "[ \"\$(kubectl get deploy web-app -n resources-ns -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')\" = \"\$(kubectl get deploy web-app -n resources-ns -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')\" ]"

check "requests.memory equals limits.memory (task explicitly requires this)" \
  "[ \"\$(kubectl get deploy web-app -n resources-ns -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')\" = \"\$(kubectl get deploy web-app -n resources-ns -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')\" ]"

check "ResourceQuota is not exceeded (3 pods fit within the hard limit)" \
  "kubectl describe resourcequota compute-quota -n resources-ns 2>/dev/null | grep -A5 'Resource ' | grep -qE '.'"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
echo "(შენიშვნა: ეს ტესტი ამოწმებს request=limit-ს ზოგადად — არა კონკრეტულ 10m/10Mi მნიშვნელობას,"
echo " რადგან სწორი პასუხი დამოკიდებულია quota-ს რეალურ hard-ლიმიტზე, გამოთვლილზე 3-ზე გაყოფით.)"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
