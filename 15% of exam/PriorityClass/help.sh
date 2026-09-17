#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
Check the existing PriorityClasses
kubectl get priorityclass
You should see something like:

user-existing   10000
So the new value must be 9999.

kubectl edit deployment busybox-logger -n priority
This opens the Deployment YAML.

Find this part:

spec:
  template:
    spec:
Under that spec:, add this line:

      priorityClassName: high-priority
So it should look like this:

spec:
  template:
    spec:
      priorityClassName: high-priority
      containers:
      - name: busybox
Save and exit.

In vi, you can save and quit with:

Esc
:wq
Enter
Then verify:

kubectl get deployment busybox-logger -n priority -o yaml | grep priorityClassName
Expected:

priorityClassName: high-priority
Create the new PriorityClass
kubectl create priorityclass high-priority --value=9999 --description="High priority class"
==================================================================
HELPEOF
