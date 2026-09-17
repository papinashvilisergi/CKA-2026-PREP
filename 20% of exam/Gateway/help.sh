#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
# 1. Create the manifest file:

nano gateway-api.yaml
# 2. Put this inside the file:

apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: web-app
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    hostname: gateway.web.k8s.local
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: web-app
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - gateway.web.k8s.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
Save and exit.

# 3. Apply the manifest:

kubectl apply -f gateway-api.yaml
# 4. Verify the Gateway and HTTPRoute:

kubectl get gateway,httproute -n web-app
# 5. Check the details:

kubectl describe gateway web-gateway -n web-app
kubectl describe httproute web-route -n web-app
==================================================================
HELPEOF
