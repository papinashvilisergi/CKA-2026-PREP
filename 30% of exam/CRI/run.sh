#!/bin/bash
set -e

# Clean any previous state so the task starts fresh
sudo systemctl stop cri-docker.service 2>/dev/null || true
sudo systemctl disable cri-docker.service 2>/dev/null || true
sudo rm -f /etc/sysctl.d/*cri* /etc/sysctl.d/kube.conf 2>/dev/null || true
rm -f ~/cri-dockerd.deb

# Provide the .deb the task expects, so it genuinely exists on disk
ARCH=$(dpkg --print-architecture)
VERSION="0.3.16"
URL="https://github.com/Mirantis/cri-dockerd/releases/download/v${VERSION}/cri-dockerd_${VERSION}.3-0.ubuntu-jammy_${ARCH}.deb"

echo "Downloading cri-dockerd package to ~/cri-dockerd.deb ..."
if curl -fsSL -o ~/cri-dockerd.deb "$URL"; then
  echo "Downloaded: $(ls -la ~/cri-dockerd.deb)"
else
  echo "WARNING: download failed (no internet?). Creating a placeholder so the path exists."
  echo "You will need to supply a real cri-dockerd .deb to complete Step 1."
  touch ~/cri-dockerd.deb
fi

# Fix service endpoint for compatibility
sudo sed -i 's#--container-runtime-endpoint fd://#--container-runtime-endpoint unix:///var/run/cri-dockerd.sock#' /usr/lib/systemd/system/cri-docker.service
#sudo systemctl reset-failed cri-docker.service cri-docker.socket if needed
# Step 2: Enable and start the service

cat <<"TASK"
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
