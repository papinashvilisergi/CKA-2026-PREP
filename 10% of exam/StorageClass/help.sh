#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
Goal

You need to:

Create a StorageClass named local-storage
Use provisioner rancher.io/local-path
Set volumeBindingMode: WaitForFirstConsumer
First create it not default
Then patch it to become the default
Make sure no other StorageClass is still default

Step 1: Check existing StorageClasses

kubectl get storageclass
You may see something like:

NAME                 PROVISIONER
standard (default)   kubernetes.io/...
This means another StorageClass is currently default.

Step 2: Create the new StorageClass YAML

Create a file:

nano local-storage.yaml
Put this inside:

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
Notice there is no default annotation yet. This means it is not default when created.

Save and exit:

CTRL + O
Enter
CTRL + X
Step 3: Apply the StorageClass

kubectl apply -f local-storage.yaml
Check it:

kubectl get storageclass
At this point, local-storage should exist, but it should not show (default) yet.

Step 4: Patch local-storage to make it default

kubectl patch storageclass local-storage \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
Now check:

kubectl get storageclass
You should see:

local-storage (default)
Step 5: Remove default from any other StorageClass

Run:

kubectl get storageclass
If you see another one with (default), for example:

standard (default)
local-storage (default)
Then remove default from the old one:

kubectl patch storageclass standard \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
Replace standard with the real name of the old default StorageClass.

Step 6: Final check

kubectl get storageclass
Expected result: only this one should have (default):

local-storage (default)
No Deployments or PVCs need to be changed.
==================================================================
HELPEOF
