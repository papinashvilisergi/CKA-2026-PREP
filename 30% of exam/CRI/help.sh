#!/bin/bash
cat <<'HELPEOF'
==================================================================
SOLUTION
==================================================================
1. Install the cri-dockerd package

dpkg -i ~/cri-dockerd.deb
Verify:

dpkg -l cri-dockerd | grep '^ii'
which cri-dockerd
2. Enable and start the cri-docker service

systemctl enable cri-docker.service
systemctl start cri-docker.service
Or in one command:

systemctl enable --now cri-docker
Verify:

systemctl is-enabled cri-docker
systemctl is-active cri-docker
Both should return enabled and active.

3. Create the sysctl configuration

tee /etc/sysctl.d/99-cri-dockerd.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
net.netfilter.nf_conntrack_max = 131072
EOF
4. Apply the settings

sysctl -p /etc/sysctl.d/99-cri-dockerd.conf
5. Verify

sysctl -n net.bridge.bridge-nf-call-iptables
sysctl -n net.ipv6.conf.all.forwarding
sysctl -n net.ipv4.ip_forward
sysctl -n net.netfilter.nf_conntrack_max
Expected values: 1, 1, 1, 131072.

Complete command sequence

dpkg -i ~/cri-dockerd.deb
systemctl enable --now cri-docker
tee /etc/sysctl.d/99-cri-dockerd.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
net.netfilter.nf_conntrack_max = 131072
EOF
sysctl -p /etc/sysctl.d/99-cri-dockerd.conf
==================================================================
HELPEOF
