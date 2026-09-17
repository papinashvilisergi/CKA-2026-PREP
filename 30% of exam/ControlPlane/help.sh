#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
There are 3 problems to fix across the control-plane manifests.

Problem 1 - Wrong ETCD IP in kube-apiserver.yaml

The API server cannot connect to etcd because the endpoint IP is wrong.

grep -- '--etcd-servers=' /etc/kubernetes/manifests/kube-apiserver.yaml
You'll see something like --etcd-servers=https://192.168.1.1:2379. Find the correct IP from the manifest annotations or liveness probe:

grep -E 'endpoint:|host:' /etc/kubernetes/manifests/kube-apiserver.yaml
Edit the manifest and fix the etcd endpoint:

vi /etc/kubernetes/manifests/kube-apiserver.yaml
Change --etcd-servers=https://192.168.1.1:2379 to use the correct IP (e.g. https://127.0.0.1:2379 or the IP from the annotation).

Problem 2 - Controller Manager CPU request too high

grep -A5 'resources:' /etc/kubernetes/manifests/kube-controller-manager.yaml
The CPU request is set to "4" (4 full cores), which is unrealistic. Edit the manifest:

vi /etc/kubernetes/manifests/kube-controller-manager.yaml
Reduce the CPU request to a reasonable value like "200m".

Problem 3 - Scheduler CPU request too high

grep -A5 'resources:' /etc/kubernetes/manifests/kube-scheduler.yaml
Same issue - CPU request of "4". Edit and fix:

vi /etc/kubernetes/manifests/kube-scheduler.yaml
Reduce the CPU request to "200m".

Verify the control plane recovers

After saving all three manifests, kubelet automatically restarts the static pods. Wait ~30 seconds, then:

kubectl get nodes
The node should be Ready. Check that all control-plane pods are running:

kubectl get pods -n kube-system
If kubectl still fails, double-check your fixes:

grep -- '--etcd-servers=' /etc/kubernetes/manifests/kube-apiserver.yaml
grep -A3 'resources:' /etc/kubernetes/manifests/kube-controller-manager.yaml
grep -A3 'resources:' /etc/kubernetes/manifests/kube-scheduler.yaml
If the manifests look correct but the API server isn't back yet, use crictl to check container status directly:

crictl ps -a | grep -E 'apiserver|controller|scheduler'
==================================================================
HELPEOF
