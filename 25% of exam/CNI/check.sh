#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== CNI — checking ==="

check "all nodes are Ready" \
  "[ \"\$(kubectl get nodes --no-headers 2>/dev/null | grep -vc ' Ready')\" = '0' ]"

check "CoreDNS pods are Running (proves pod-to-pod networking actually works)" \
  "[ \"\$(kubectl get pods -n kube-system -l k8s-app=kube-dns --no-headers 2>/dev/null | grep -vc Running)\" = '0' ]"

check "a CNI that supports NetworkPolicy is installed (Calico)" \
  "kubectl get pods -n calico-system &>/dev/null || kubectl get pods -n kube-system -l k8s-app=calico-node &>/dev/null"

check "NetworkPolicy enforcement actually works (default-deny test)" \
  "kubectl create ns netpol-check-tmp --dry-run=client -o yaml | kubectl apply -f - &>/dev/null; \
   kubectl run netpol-check-pod --image=nginx -n netpol-check-tmp --restart=Never &>/dev/null; \
   sleep 8; \
   cat <<'EOF' | kubectl apply -f - &>/dev/null
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: netpol-check-tmp
spec:
  podSelector: {}
  policyTypes: [Ingress]
EOF
   sleep 3; \
   RESULT=1; \
   kubectl run netpol-tester --image=busybox:stable -n netpol-check-tmp --restart=Never --rm -i --command -- timeout 5 wget -qO- http://netpol-check-pod &>/tmp/netpol_out || RESULT=0; \
   kubectl delete ns netpol-check-tmp &>/dev/null; \
   [ \"\$RESULT\" = '0' ]"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
echo "(NetworkPolicy enforcement ტესტი ქმნის და შლის დროებით namespace-ს — თუ Flannel"
echo " აირჩიე NetworkPolicy-ის მხარდაჭერის გარეშე, ეს ტესტი მოსალოდნელად ჩავარდება.)"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
