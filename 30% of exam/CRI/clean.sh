#!/bin/bash
set -e
sudo systemctl stop cri-docker.service 2>/dev/null || true
sudo systemctl disable cri-docker.service 2>/dev/null || true
sudo rm -f /etc/sysctl.d/kube.conf
echo "Cleared (service state reset; package itself not uninstalled). Run run.sh again to retry."
