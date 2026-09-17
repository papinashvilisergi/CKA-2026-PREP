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
HELPEOF
