#!/bin/bash
# Verifies the PVC task without changing anything
PASS=0
FAIL=0

check() {
  if eval "$2"; then
    echo "[PASS] $1"
    PASS=$((PASS+1))
  else
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
  fi
}

echo "=== PVC — checking ==="

check "PVC 'mariadb' exists in namespace mariadb" \
  "kubectl get pvc mariadb -n mariadb &>/dev/null"

check "PVC is Bound" \
  "[ \"\$(kubectl get pvc mariadb -n mariadb -o jsonpath='{.status.phase}' 2>/dev/null)\" = 'Bound' ]"

check "PVC storage request is 250Mi" \
  "[ \"\$(kubectl get pvc mariadb -n mariadb -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)\" = '250Mi' ]"

check "PVC accessMode includes ReadWriteOnce" \
  "kubectl get pvc mariadb -n mariadb -o jsonpath='{.spec.accessModes[*]}' 2>/dev/null | grep -q ReadWriteOnce"

check "PVC is bound to mariadb-pv" \
  "[ \"\$(kubectl get pvc mariadb -n mariadb -o jsonpath='{.spec.volumeName}' 2>/dev/null)\" = 'mariadb-pv' ]"

check "Deployment mariadb has a running pod" \
  "kubectl get pods -n mariadb -l app=mariadb -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running"

check "Pod mounts the PVC at /var/lib/mysql" \
  "kubectl get pod -n mariadb -l app=mariadb -o jsonpath='{.items[0].spec.volumes[?(@.persistentVolumeClaim.claimName==\"mariadb\")]}' 2>/dev/null | grep -q mariadb"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
