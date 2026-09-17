#!/bin/bash
set -e
sudo systemctl stop cri-docker.service 2>/dev/null || true
sudo systemctl disable cri-docker.service 2>/dev/null || true
sudo dpkg -r cri-dockerd 2>/dev/null || true
sudo rm -f /etc/sysctl.d/*cri* /etc/sysctl.d/kube.conf 2>/dev/null || true
rm -f ~/cri-dockerd.deb
echo "Cleared. Run run.sh again to retry."
