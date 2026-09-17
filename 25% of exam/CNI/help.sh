#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/tigera-operator.yaml
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/custom-resources.yaml
# get pod CIDR from kubeadm ConfigMap, then edit cidr in the file if needed
vi custom-resources.yaml
kubectl create -f custom-resources.yaml
kubectl get pods -n calico-system -w
kubectl get nodes
==================================================================
HELPEOF
