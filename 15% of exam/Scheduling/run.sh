#!/bin/bash
set -e
kubectl create namespace cka-taints --dry-run=client -o yaml | kubectl apply -f -

WORKER=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$WORKER" ]; then
  WORKER=$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name | grep -v controlplane | head -1)
fi

kubectl taint node "$WORKER" dedicated=gpu:NoSchedule --overwrite
kubectl label node "$WORKER" gpu=true --overwrite

echo "Tainted and labeled node: $WORKER"

cat <<'TASK'
==================================================================
TASK: Scheduling — Taints, Tolerations & nodeSelector
==================================================================
A worker node has been tainted with dedicated=gpu:NoSchedule and
labeled gpu=true.

Task: Create a pod named gpu-pod in namespace cka-taints that:
- Uses image nginx:1.25
- Has a toleration for the taint dedicated=gpu:NoSchedule
- Has a nodeSelector that targets nodes with label gpu=true
- Is in a Running state
==================================================================
TASK
