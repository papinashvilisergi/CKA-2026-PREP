#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
Edit the Deployment
kubectl edit deployment wordpress -n wordpress-ns
Add this inside the pod template
Under:

spec:
  template:
    spec:
add the volume:

volumes:
- name: logs
  emptyDir: {}
Then under the existing wordpress container, add:

volumeMounts:
- name: logs
  mountPath: /var/log
Then add the sidecar as another container:

- name: sidecar
  image: busybox:stable
  command: ["/bin/sh", "-c", "tail -f /var/log/wordpress.log"]
  volumeMounts:
  - name: logs
    mountPath: /var/log
Important: keep the wordpress container’s existing command exactly as it is - it is what creates wordpress.log and keeps that container running. You are only adding the volume, the two mounts, and the sidecar container.

So the important part should look like this:

spec:
  template:
    spec:
      volumes:
      - name: logs
        emptyDir: {}

      containers:
      - name: wordpress
        image: busybox:stable
        command: ["/bin/sh", "-c", "touch /var/log/wordpress.log && tail -f /var/log/wordpress.log"]
        volumeMounts:
        - name: logs
          mountPath: /var/log

      - name: sidecar
        image: busybox:stable
        command: ["/bin/sh", "-c", "tail -f /var/log/wordpress.log"]
        volumeMounts:
        - name: logs
          mountPath: /var/log
Save and check
kubectl get deployment wordpress -n wordpress-ns
kubectl get pods -n wordpress-ns
kubectl describe pod <wordpress-pod-name> -n wordpress-ns
==================================================================
HELPEOF
