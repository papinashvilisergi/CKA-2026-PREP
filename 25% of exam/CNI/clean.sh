#!/bin/bash
set -e
sudo kubectl delete daemonset kube-flannel-ds -n kube-flannel --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete namespace kube-flannel --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete -n calico-system --all daemonset,deployment --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete namespace calico-system tigera-operator --ignore-not-found=true 2>/dev/null || true
sudo kubectl delete installation default --ignore-not-found=true 2>/dev/null || true
echo "Cleared. Run run.sh again to retry with either Flannel or Calico."
