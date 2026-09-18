#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== ControlPlane — checking ==="

check "kubectl get nodes actually works (API server responds)" \
  "kubectl get nodes &>/dev/null"

check "all nodes report Ready" \
  "[ \"\$(kubectl get nodes --no-headers 2>/dev/null | grep -vc ' Ready')\" = '0' ]"

check "kube-apiserver static pod is Running" \
  "kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running"

check "kube-controller-manager static pod is Running" \
  "kubectl get pods -n kube-system -l component=kube-controller-manager -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running"

check "kube-scheduler static pod is Running" \
  "kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running"

check "etcd-servers points to the client port 2379, not peer port 2380" \
  "grep -q 'etcd-servers=https://127.0.0.1:2379' /etc/kubernetes/manifests/kube-apiserver.yaml"

check "controller-manager CPU request is realistic (not the broken '4')" \
  "! grep -A2 'requests:' /etc/kubernetes/manifests/kube-controller-manager.yaml | grep -q 'cpu: \"4\"'"

check "scheduler CPU request is realistic (not the broken '4')" \
  "! grep -A2 'requests:' /etc/kubernetes/manifests/kube-scheduler.yaml | grep -q 'cpu: \"4\"'"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
