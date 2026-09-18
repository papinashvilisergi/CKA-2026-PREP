#!/bin/bash
PASS=0; FAIL=0
check() {
  if eval "$2"; then echo "[PASS] $1"; PASS=$((PASS+1));
  else echo "[FAIL] $1"; FAIL=$((FAIL+1)); fi
}

echo "=== CRI — checking ==="

check "cri-dockerd package is installed" \
  "dpkg -l | grep -q cri-dockerd"

check "cri-docker.service is active" \
  "systemctl is-active cri-docker.service | grep -q '^active$'"

check "cri-docker.service is enabled (survives reboot)" \
  "systemctl is-enabled cri-docker.service | grep -q '^enabled$'"

check "net.bridge.bridge-nf-call-iptables = 1" \
  "[ \"\$(sysctl -n net.bridge.bridge-nf-call-iptables 2>/dev/null)\" = '1' ]"

check "net.ipv6.conf.all.forwarding = 1" \
  "[ \"\$(sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null)\" = '1' ]"

check "net.ipv4.ip_forward = 1" \
  "[ \"\$(sysctl -n net.ipv4.ip_forward 2>/dev/null)\" = '1' ]"

check "net.netfilter.nf_conntrack_max = 131072" \
  "[ \"\$(sysctl -n net.netfilter.nf_conntrack_max 2>/dev/null)\" = '131072' ]"

check "a sysctl config file exists in /etc/sysctl.d/ (persistence across reboot)" \
  "grep -rl 'bridge-nf-call-iptables' /etc/sysctl.d/ &>/dev/null"

echo
echo "=== შედეგი: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
