#!/bin/bash
set -e
echo "Setup: assumes cert-manager CRDs are already installed on this cluster."
cat <<'TASK'
==================================================================
TASK: Cert — cert-manager CRDs
==================================================================
1. Create a list of all cert-manager CRDs and save it to
   /root/resources.yaml
2. Using kubectl, extract the documentation for the subject
   specification field of the Certificate Custom Resource and
   save it to /root/documentation.txt

You may use any output format that kubectl supports.
==================================================================
TASK
