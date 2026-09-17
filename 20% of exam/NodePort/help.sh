#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
1. Set namespace context

kubectl config set-context --current --namespace=prepium
2. Add the named port to the Deployment

kubectl edit deployment front-end
Under the nginx container, add:

ports:
- name: http
  containerPort: 80
  protocol: TCP
Indentation matters: ports: aligns with image: inside the container spec.

Save and exit. The rollout happens automatically.

Verify the rollout:

kubectl rollout status deployment front-end
3. Create the Service

Create front-end-svc.yaml:

apiVersion: v1
kind: Service
metadata:
  name: front-end-svc
  namespace: prepium
spec:
  type: NodePort
  selector:
    app: front-end
  ports:
  - port: 80
    targetPort: http
    protocol: TCP
Apply it:

kubectl apply -f front-end-svc.yaml
targetPort: http references the named port on the pod. That is what the task is asking for: use the name, not the number.

4. Verify

kubectl get svc front-end-svc
kubectl get endpoints front-end-svc
ENDPOINTS should list pod IPs, not be empty.

If ENDPOINTS is empty, the selector does not match any pods. Check the pod labels:

kubectl get pods --show-labels
Watch out for

targetPort must equal http, not 80.
Do not set nodePort manually unless the task gives a specific number. Let Kubernetes pick it.
The selector must match the pod labels exactly: app: front-end, not the Deployment name.
==================================================================
HELPEOF
