#!/bin/bash
set -e
BACKUP_DIR=$(cat /root/.last-drill-backup 2>/dev/null)
if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  echo "No backup found - restoring manually"
  sudo sed -i "s|--etcd-servers=https://192.168.1.1:2379|--etcd-servers=https://127.0.0.1:2379|" \
    /etc/kubernetes/manifests/kube-apiserver.yaml
  for f in kube-controller-manager kube-scheduler; do
    sudo python3 -c "
import re
p = \"/etc/kubernetes/manifests/${f}.yaml\"
c = open(p).read()
c = re.sub(r\"(requests:\n\s+cpu: )\S+\", r\"\g<1>200m\", c)
open(p, \"w\").write(c)
"
  done
else
  echo "Restoring from: $BACKUP_DIR"
  sudo cp "$BACKUP_DIR"/*.yaml /etc/kubernetes/manifests/
fi
sudo systemctl restart kubelet
sleep 25
kubectl get nodes
echo "Reset complete. Run run.sh again to retry."
