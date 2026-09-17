#!/bin/bash
set -e
echo "Setup: assumes ~/cri-dockerd.deb is present on this host (per task premise)."
cat <<'TASK'
==================================================================
TASK: CRI — cri-dockerd setup
==================================================================
Set up cri-dockerd on this node.

Step 1: Install the Debian package located at ~/cri-dockerd.deb
using dpkg.

Step 2: Enable and start the cri-docker service.

Step 3: Create a sysctl configuration file and apply it with the
following parameters:
  net.bridge.bridge-nf-call-iptables = 1
  net.ipv6.conf.all.forwarding = 1
  net.ipv4.ip_forward = 1
  net.netfilter.nf_conntrack_max = 131072
==================================================================
TASK
