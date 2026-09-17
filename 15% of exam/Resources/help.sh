#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
Step 1 - Investigate the issue

kubectl describe deploy/web-app -n resources-ns
The Events section will show a FailedCreate error: the ReplicaSet cannot create pods because the ResourceQuota requires resource requests/limits but the pod spec has none.

Step 2 - Discover the resource budget

kubectl describe quota -n resources-ns
Look at the requests.cpu, requests.memory, limits.cpu, and limits.memory hard values. For example if the quota shows:

requests.cpu:    30m
requests.memory: 30Mi
limits.cpu:      30m
limits.memory:   30Mi
Then the total budget is 30m CPU and 30Mi memory.

Step 3 - Set equal resources per pod

Divide the quota evenly: 30m / 3 = 10m CPU, 30Mi / 3 = 10Mi memory per pod.

Set requests equal to limits so the pod gets Guaranteed QoS:

kubectl edit deployment web-app -n resources-ns
Under spec.template.spec.containers[0], add:

resources:
  requests:
    cpu: "10m"
    memory: "10Mi"
  limits:
    cpu: "10m"
    memory: "10Mi"
Save and exit. The pods will be created automatically.

Step 4 - Verify

kubectl get pods -n resources-ns
kubectl describe quota -n resources-ns
All 3 pods should be Running. The Used column in the quota should match the Hard limit.
==================================================================
HELPEOF
