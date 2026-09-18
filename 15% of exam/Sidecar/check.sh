#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== Sidecar — checking ==="

check "wordpress Deployment still has 2 containers" \
  "[ \"\$(kubectl get deploy wordpress -n wordpress-ns -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)\" = '2' ]"

check "sidecar container exists with image busybox:stable" \
  "[ \"\$(kubectl get deploy wordpress -n wordpress-ns -o json 2>/dev/null | python3 -c \"import json,sys; d=json.load(sys.stdin); c=[x for x in d['spec']['template']['spec']['containers'] if x['name']=='sidecar']; print(c[0]['image'] if c else '')\")\" = 'busybox:stable' ]"

check "volume named logs exists at pod level, using emptyDir" \
  "kubectl get deploy wordpress -n wordpress-ns -o json 2>/dev/null | python3 -c \"import json,sys; d=json.load(sys.stdin); v=[x for x in d['spec']['template']['spec'].get('volumes',[]) if x['name']=='logs' and 'emptyDir' in x]; exit(0 if v else 1)\""

check "both containers mount 'logs' at /var/log" \
  "kubectl get deploy wordpress -n wordpress-ns -o json 2>/dev/null | python3 -c \"
import json,sys
d=json.load(sys.stdin)
containers=d['spec']['template']['spec']['containers']
ok=True
for c in containers:
    mounts=c.get('volumeMounts',[])
    match=[m for m in mounts if m['name']=='logs' and m['mountPath']=='/var/log']
    if not match: ok=False
exit(0 if ok else 1)
\""

check "wordpress pod is Running (both containers ready)" \
  "kubectl get pods -n wordpress-ns -l app=wordpress -o jsonpath='{.items[0].status.containerStatuses[*].ready}' 2>/dev/null | grep -qv false"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
