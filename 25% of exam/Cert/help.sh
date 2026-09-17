#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
kubectl get crd | grep cert-manager > /root/resources.yaml
kubectl explain certificate.spec.subject > /root/documentation.txt
==================================================================
HELPEOF
