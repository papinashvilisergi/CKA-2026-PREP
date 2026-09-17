#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
1. Identify the tainted node

kubectl get nodes -l gpu=true
kubectl describe node <worker-name> | grep -A2 Taints
You should see dedicated=gpu:NoSchedule.

2. Create the gpu-pod with toleration and nodeSelector

Create gpu-pod.yaml:

apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
  namespace: cka-taints
spec:
  nodeSelector:
    gpu: "true"
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx:1.25
Apply:

kubectl apply -f gpu-pod.yaml
3. Verify

kubectl -n cka-taints get pod gpu-pod -o wide
The pod should be Running and scheduled on the tainted worker node.

Also verify the web-app pods are NOT on that node:

kubectl -n cka-taints get pods -l app=web-app -o wide
Key concepts

A taint on a node repels pods that don't tolerate it
nodeSelector ensures the pod lands on a specific node
The toleration must match the taint's key, value, and effect exactly
operator: Equal requires both key and value to match; operator: Exists only requires the key
==================================================================
HELPEOF
