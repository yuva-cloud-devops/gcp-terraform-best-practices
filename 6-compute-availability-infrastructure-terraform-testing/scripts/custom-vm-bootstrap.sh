#!/bin/bash
set -euo pipefail

echo "===================================================================="
echo "===> [Custom Test VM Bootstrap] Initializing at $(date)"
echo "===================================================================="

# Prevent interactive prompts during package installation
export DEBIAN_FRONTEND=noninteractive

# Update apt repositories
apt-get update -y

# ------------------------------------------------------------------------------
# Install Essential Network Diagnostics & Load Balancing / MIG Testing Tools
# ------------------------------------------------------------------------------
apt-get install -y \
  curl \
  wget \
  jq \
  netcat-openbsd \
  telnet \
  dnsutils \
  iputils-ping \
  traceroute \
  mtr-tiny \
  tcpdump \
  nmap \
  socat \
  net-tools \
  iproute2 \
  ethtool \
  iperf3 \
  apache2-utils \
  stress-ng \
  htop \
  iotop \
  sysstat \
  git \
  unzip \
  ca-certificates

echo "===================================================================="
echo "===> Installed Testing Toolkit:"
echo "     - HTTP / Web: curl, wget, ab (Apache Bench)"
echo "     - Port / Socket Probing: nc (netcat), telnet, nmap, socat, ss"
echo "     - DNS & Routing: dig, nslookup, ping, traceroute, mtr"
echo "     - Traffic & Bandwidth: tcpdump, iperf3"
echo "     - Autoscaler Stress Testing: stress-ng, ab"
echo "===> [Custom Test VM Bootstrap] Completed successfully at $(date)"
echo "===================================================================="
