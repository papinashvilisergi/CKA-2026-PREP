#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
1. Check the Ingress Controller and IngressClass

kubectl get ingressclass
kubectl -n ingress-nginx get pods
Confirm the NGINX Ingress Controller is running and the IngressClass nginx exists.

2. Create the Ingress resource

Create app-ingress.yaml:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: cka-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
Apply:

kubectl apply -f app-ingress.yaml
Alternative: one-liner with kubectl

kubectl create ingress app-ingress \
  --class=nginx \
  --rule="/app=app-service:80" \
  --rule="/admin=admin-service:80" \
  -n cka-ingress
Note: kubectl create ingress sets pathType: Exact by default. You may need to edit afterward to change to Prefix:

kubectl -n cka-ingress edit ingress app-ingress
3. Verify

kubectl -n cka-ingress get ingress app-ingress
kubectl -n cka-ingress describe ingress app-ingress
Check that both paths show the correct backend service and port.

Key concepts

ingressClassName replaced the deprecated kubernetes.io/ingress.class annotation
pathType: Prefix matches the path and all subpaths (e.g., /app matches /app/foo)
pathType: Exact only matches the exact path
All paths under the same rule share the same host (or no host for default)
==================================================================
HELPEOF
