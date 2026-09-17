#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
Review the provided NetworkPolicy files

List the available manifests:

ls /root/exam_resources
Open the YAML files one by one:

cat /root/exam_resources/*.yaml
Choose the least permissive policy

The correct policy should:
- allow traffic from the frontend namespace
- allow traffic only to the backend pods
- allow traffic only on the required backend port, if a port is specified
- avoid allowing all namespaces or all pods

A good NetworkPolicy usually looks similar to this:

kind: NetworkPolicy
metadata:
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend
      podSelector:
        matchLabels:
          app: frontend
The policy should be created in the backend namespace because the backend pods are what you are protecting.

Apply the correct manifest

Once you identify the correct YAML, apply it:

kubectl apply -f /root/exam_resources/<correct-file>.yaml
For this lab, the correct file is:

kubectl apply -f /root/exam_resources/netpol2.yaml
Verify

kubectl get netpol -n backend
kubectl describe netpol -n backend
In simple words: choose the YAML that allows only frontend pods in the frontend namespace to reach backend pods in the backend namespace.

Avoid policies using broad rules like 0.0.0.0/0, empty {} selectors, or rules that allow all namespaces.
==================================================================
HELPEOF
