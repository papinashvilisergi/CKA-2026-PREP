#!/bin/bash
set -e
kubectl delete namespace cka-taints --ignore-not-found=true
for n in $(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name); do
  kubectl taint node "$n" dedicated=gpu:NoSchedule- 2>/dev/null || true
  kubectl label node "$n" gpu- 2>/dev/null || true
done
echo "Cleared. Run run.sh again to retry."
