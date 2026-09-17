#!/bin/bash
set -e
BACKUP_DIR="/root/manifests.bak.$(date +%s)"
sudo cp -r /etc/kubernetes/manifests "$BACKUP_DIR"
echo "$BACKUP_DIR" | sudo tee /root/.last-drill-backup > /dev/null

# Problem 1 - wrong etcd IP in kube-apiserver.yaml
sudo sed -i "s|--etcd-servers=https://127.0.0.1:2379|--etcd-servers=https://192.168.1.1:2379|" \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# Problem 2 - controller-manager CPU request unrealistically high
sudo python3 -c "
import re
p = \"/etc/kubernetes/manifests/kube-controller-manager.yaml\"
c = open(p).read()
c = re.sub(r\"(requests:\n\s+cpu: )\S+\", r\"\g<1>\\\"4\\\"\", c)
open(p, \"w\").write(c)
"

# Problem 3 - scheduler CPU request unrealistically high
sudo python3 -c "
import re
p = \"/etc/kubernetes/manifests/kube-scheduler.yaml\"
c = open(p).read()
c = re.sub(r\"(requests:\n\s+cpu: )\S+\", r\"\g<1>\\\"4\\\"\", c)
open(p, \"w\").write(c)
"

echo "Cluster broken. Waiting..."
sleep 20

cat <<"TASK"
==================================================================
TASK: Control Plane Failure
==================================================================
After a cluster migration, the control plane is completely down.
The kube-apiserver, kube-controller-manager, and kube-scheduler
static pods are all failing to start.

There are 3 separate problems across the static pod manifests in:
  /etc/kubernetes/manifests/

Task: Identify and fix all three issues so the control plane
recovers and kubectl get nodes works again.
==================================================================
TASK
