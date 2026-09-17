#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
kubectl autoscale deployment prep-server \
  -n auto-scale \
  --name=prep-hpa \
  --cpu=50% \
  --min=1 \
  --max=4

kubectl get hpa -n auto-scale
kubectl edit hpa prep-hpa -n auto-scale
behavior:
  scaleDown:
    stabilizationWindowSeconds: 30

kubectl describe hpa prep-hpa -n auto-scale
kubectl get hpa prep-hpa -n auto-scale -o yaml
==================================================================
HELPEOF
