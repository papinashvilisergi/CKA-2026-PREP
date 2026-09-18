#!/bin/bash
set -e
# Guarantee a clean slate — remove any pre-existing CNI so the task
# starts from genuinely "no CNI installed", avoiding the collision
# problem from earlier practice (two CNIs fighting each other).
sudo kubectl delete daemonset cilium -n kube-system --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete daemonset cilium-envoy -n kube-system --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete deployment cilium-operator -n kube-system --ignore-not-found=true 2>/dev/null || true

# Wait for Cilium pods to ACTUALLY terminate before touching CNI conf files —
# `kubectl delete` returns immediately, but the agent stays alive for a bit
# and can re-write its own CNI conf file if we clean up too early (race condition).
echo "Waiting for Cilium pods to fully terminate..."
for i in $(seq 1 30); do
  REMAINING=$(kubectl get pods -n kube-system -l k8s-app=cilium --no-headers 2>/dev/null | wc -l)
  [ "$REMAINING" -eq 0 ] && break
  sleep 2
done

sudo rm -f /etc/cni/net.d/*.conflist /etc/cni/net.d/*.conf 2>/dev/null || true
sleep 2
# Do it again, in case anything raced past the wait above
sudo rm -f /etc/cni/net.d/*.conflist /etc/cni/net.d/*.conf 2>/dev/null || true
sudo kubectl delete daemonset kube-flannel-ds -n kube-flannel --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete namespace kube-flannel --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete daemonset -n calico-system --all --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete namespace calico-system --ignore-not-found=true 2>/dev/null || true
sudo rm -f /etc/cni/net.d/*.conflist /etc/cni/net.d/*.conf 2>/dev/null || true

echo "Clean slate — no CNI installed."
sleep 5

cat <<'TASK'
==================================================================
TASK: CNI Installation — Variant A (Original brief, Exam-style)
==================================================================
Install and configure one Container Network Interface (CNI)
plugin from the options below.

Available options:
- Flannel v0.26.1 - manifest: kube-flannel.yml
  https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml

- Calico v3.32.2 - install the Tigera operator manifest, then apply
  the Calico custom resources manifest
  https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/tigera-operator.yaml
  https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/custom-resources.yaml

Requirements:
The CNI you install must:
- allow pods to communicate with each other
- support Kubernetes NetworkPolicy enforcement
- be installed from manifests
==================================================================
TASK
