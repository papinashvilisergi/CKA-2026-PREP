#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Cert — checking ==="

check "/root/resources.yaml exists and is not empty" \
  "[ -s /root/resources.yaml ]"

check "/root/resources.yaml actually lists cert-manager CRDs" \
  "grep -q 'cert-manager.io' /root/resources.yaml"

check "/root/documentation.txt exists and is not empty" \
  "[ -s /root/documentation.txt ]"

check "/root/documentation.txt is genuinely about Certificate.spec.subject" \
  "grep -qi 'subject' /root/documentation.txt"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
