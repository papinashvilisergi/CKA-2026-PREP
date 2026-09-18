#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== StorageClass — checking ==="

check "local-storage StorageClass exists" \
  "kubectl get sc local-storage &>/dev/null"

check "provisioner is rancher.io/local-path" \
  "[ \"\$(kubectl get sc local-storage -o jsonpath='{.provisioner}' 2>/dev/null)\" = 'rancher.io/local-path' ]"

check "volumeBindingMode is WaitForFirstConsumer" \
  "[ \"\$(kubectl get sc local-storage -o jsonpath='{.volumeBindingMode}' 2>/dev/null)\" = 'WaitForFirstConsumer' ]"

check "local-storage is the default StorageClass" \
  "[ \"\$(kubectl get sc local-storage -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' 2>/dev/null)\" = 'true' ]"

check "local-storage is the ONLY default (no other SC also marked default)" \
  "[ \"\$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{\"\n\"}{end}' 2>/dev/null | grep -c '^true$')\" = '1' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
