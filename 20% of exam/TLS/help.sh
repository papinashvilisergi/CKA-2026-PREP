#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
1. Inspect the current ConfigMap

kubectl get cm tls-config -n secure-space -o yaml > tls-config.yaml
cat tls-config.yaml
Look for the field listing TLS versions. Common names are protocols, ssl_protocols, tls_versions, or something similar depending on the app config stored under data:.

2. Edit the file

vi tls-config.yaml
Remove TLSv1.2 and keep only TLSv1.3.

Also clean up generated metadata so the file can be re-applied:
- delete resourceVersion
- delete uid
- delete creationTimestamp
- delete the managedFields block if present

Example data section after editing:

data:
  nginx.conf: |
    ssl_protocols TLSv1.3;
Your key name may differ. Keep the existing ConfigMap key and only change the TLS version value.

3. Delete and recreate

kubectl delete cm tls-config -n secure-space
kubectl apply -f tls-config.yaml
4. Restart the Deployment

kubectl rollout restart deployment secure-web -n secure-space
kubectl rollout status deployment secure-web -n secure-space
The restart is required because pods load ConfigMap values at startup. Even when the ConfigMap is mounted as a file, the running process may not reload the new value automatically.

5. Verify

kubectl get cm tls-config -n secure-space -o yaml | grep -i tls
kubectl get pods -n secure-space
Watch out for

Do not forget the namespace flag. The ConfigMap and Deployment are in secure-space, not default.
Keep the same ConfigMap name: tls-config. If you change the name, the Deployment will not find it.
Do not use only kubectl edit; the task explicitly requires delete and recreate.
==================================================================

IMPORTANT — a real, documented kubelet limitation you may hit here:
If the running pod still shows the OLD ssl_protocols line even after
delete + recreate + rollout restart, this is a known Kubernetes
behavior, not a mistake in your steps. Once a ConfigMap is marked
immutable, kubelet stops watching it for changes entirely — and
deleting/recreating one with the SAME NAME does not reliably clear
that cache. Kubernetes' own docs confirm the fix is either:
  a) restart kubelet on the affected node:
       sudo systemctl restart kubelet
       kubectl delete pod -n secure-space -l app=secure-web
  b) or give the new ConfigMap a different name and repoint the
     Deployment's volume at it instead of reusing the old name
Source: https://kubernetes.io/docs/concepts/configuration/configmap/
==================================================================
HELPEOF
