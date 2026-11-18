Here is the complete, production-grade, and reproducible **End-to-End Setup Guide** for configuring a Linux VM as an on-premises / branch office VPN router connecting to Google Cloud HA VPN.

---

### Architecture Reference

| Component | Setting / Value |
| :--- | :--- |
| **GCP HA VPN Gateway IP (`GCP_VPN_IP`)** | `34.152.106.188` (Interface 0) |
| **GCP Cloud Router ASN / BGP IP** | `ASN 65001` / `169.254.1.1` |
| **Remote VM Public IP (`MY_PUBLIC_IP`)** | `35.197.151.95` (Static External IP) |
| **Remote VM Private IP (`MY_PRIVATE_IP`)** | `10.148.0.2` (Internal Subnet IP) |
| **Remote VM ASN / BGP IP** | `ASN 65002` / `169.254.1.2` |
| **IPsec Pre-Shared Key (PSK)** | `VpnStrongSwanSecret2026!#` |

---

### Complete One-Shot Setup Script

SSH into your `vpn-router` VM and run this complete automated script as `root`:

```bash
sudo -i

# ==============================================================================
# 1. DEFINE VARIABLES
# ==============================================================================
GCP_VPN_IP="34.152.106.188"
MY_PUBLIC_IP="35.197.151.95"
MY_PRIVATE_IP=$(hostname -I | awk '{print $1}')
PSK="VpnStrongSwanSecret2026!#"

GCP_BGP_IP="169.254.1.1"
VM_BGP_IP="169.254.1.2"
GCP_ASN="65001"
VM_ASN="65002"

# ==============================================================================
# 2. INSTALL SOFTWARE PACKAGES
# ==============================================================================
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y strongswan strongswan-pki libcharon-extra-plugins frr

# ==============================================================================
# 3. KERNEL & NETWORKING CONFIGURATION
# ==============================================================================
# Enable IP Forwarding
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Disable Reverse Path Filtering (Required for VTI tunnels)
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.default.rp_filter=0

# Clamp TCP MSS to prevent packet fragmentation inside IPsec
iptables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || \
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# ==============================================================================
# 4. CONFIGURE STRONGSWAN (IPSEC)
# ==============================================================================
# Prevent StrongSwan from installing routes into table 220 (bypassing VTI)
cat << 'EOF' > /etc/strongswan.d/charon.conf
charon {
    install_routes = no
    install_virtual_ip = no
}
EOF

# StrongSwan IPsec connection profile
cat << EOF > /etc/ipsec.conf
config setup
    charondebug="ike 1, knl 1, cfg 1"

conn gcp-vpn
    authby=secret
    auto=start
    keyexchange=ikev2
    type=tunnel
    left=${MY_PRIVATE_IP}
    leftid=${MY_PUBLIC_IP}
    leftsubnet=0.0.0.0/0
    right=${GCP_VPN_IP}
    rightid=${GCP_VPN_IP}
    rightsubnet=0.0.0.0/0
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    mark=100
    dpdaction=restart
    dpddelay=30s
EOF

# Pre-Shared Key
cat << EOF > /etc/ipsec.secrets
${MY_PUBLIC_IP} ${GCP_VPN_IP} : PSK "${PSK}"
EOF

# ==============================================================================
# 5. CREATE VIRTUAL TUNNEL INTERFACE (VTI)
# ==============================================================================
ip link delete vti0 2>/dev/null || true
ip tunnel add vti0 mode vti local ${MY_PRIVATE_IP} remote ${GCP_VPN_IP} okey 100
ip addr add ${VM_BGP_IP}/30 dev vti0
ip link set dev vti0 mtu 1400
ip link set dev vti0 up

# Kernel settings for vti0
sysctl -w net.ipv4.conf.vti0.disable_policy=1
sysctl -w net.ipv4.conf.vti0.rp_filter=0

# Ensure BGP subnet routes to vti0
ip route add ${GCP_BGP_IP}/32 dev vti0 2>/dev/null || true

# Allow all traffic across vti0 interface
iptables -I INPUT -i vti0 -j ACCEPT
iptables -I OUTPUT -o vti0 -j ACCEPT
iptables -I FORWARD -i vti0 -j ACCEPT
iptables -I FORWARD -o vti0 -j ACCEPT

# Source NAT (SNAT) outbound packets to VM's RFC1918 private IP (accepted by GCP firewall)
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o vti0 -j SNAT --to-source ${MY_PRIVATE_IP}

# ==============================================================================
# 6. CONFIGURE FRROUTING (BGP)
# ==============================================================================
# Enable BGP daemon
sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons

# Configure FRR BGP peering with Google Cloud Router
cat << EOF > /etc/frr/frr.conf
frr version 8.1
frr defaults traditional
hostname vpn-router
!
route-map PERMIT-ALL permit 10
!
router bgp ${VM_ASN}
 bgp router-id ${VM_BGP_IP}
 no bgp ebgp-requires-policy
 neighbor ${GCP_BGP_IP} remote-as ${GCP_ASN}
 neighbor ${GCP_BGP_IP} timers 20 60
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor ${GCP_BGP_IP} activate
  neighbor ${GCP_BGP_IP} route-map PERMIT-ALL in
  neighbor ${GCP_BGP_IP} route-map PERMIT-ALL out
 exit-address-family
!
EOF

# ==============================================================================
# 7. RESTART SERVICES
# ==============================================================================
systemctl restart strongswan-starter
systemctl restart frr
```

---

### Step 2: Make the VTI Tunnel Persistent Across Reboots

Because Linux tunnel interfaces (`vti0`) and routing tables disappear when the VM reboots, create a simple systemd startup service:

```bash
cat << 'EOF' > /etc/systemd/system/vpn-vti.service
[Unit]
Description=Set up VTI Tunnel and Routing for GCP HA VPN
After=network-online.target strongswan-starter.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '\
    MY_PRIVATE_IP=$(hostname -I | awk "{print \$1}"); \
    ip tunnel add vti0 mode vti local $MY_PRIVATE_IP remote 34.152.106.188 okey 100 2>/dev/null || true; \
    ip addr add 169.254.1.2/30 dev vti0 2>/dev/null || true; \
    ip link set dev vti0 mtu 1400; \
    ip link set dev vti0 up; \
    sysctl -w net.ipv4.conf.vti0.disable_policy=1; \
    sysctl -w net.ipv4.conf.vti0.rp_filter=0; \
    ip route add 169.254.1.1/32 dev vti0 2>/dev/null || true; \
    iptables -t nat -A POSTROUTING -o vti0 -j SNAT --to-source $MY_PRIVATE_IP 2>/dev/null || true; \
    iptables -I FORWARD -i vti0 -j ACCEPT 2>/dev/null || true; \
    iptables -I FORWARD -o vti0 -j ACCEPT 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vpn-vti.service
```

---

### Step 3: Verification & Operational Commands

#### 1. Check IPsec Tunnel Status:
```bash
ipsec status
```
*Expected*:
```
Security Associations (1 up, 0 connecting):
     gcp-vpn[1]: ESTABLISHED ... 10.148.0.2[35.197.151.95]...34.152.106.188[34.152.106.188]
     gcp-vpn{1}:  INSTALLED, TUNNEL, reqid 1, ESP in UDP
```

#### 2. Check BGP Neighbor Status:
```bash
vtysh -c "show ip bgp summary"
```
*Expected*:
```
Neighbor     V  AS     MsgRcvd  MsgSent  Up/Down   State/PfxRcd
169.254.1.1  4  65001  14       16       00:05:12  1
```

#### 3. View Routes Received via BGP:
```bash
vtysh -c "show ip route bgp"
```
*Expected*:
```
B>* 10.10.1.0/24 [20/100] via 169.254.1.1, vti0
```

#### 4. End-to-End Ping & HTTP Test:
```bash
# Ping the Mumbai VM
ping -c 3 10.10.1.3

# Fetch the web server over the private encrypted tunnel
curl http://10.10.1.3/
```

















To cleanly remove the temporary lab resources created in the Singapore `default` VPC, run the following commands in your terminal:

```bash
# Set environment variables
PROJECT_ID="yuvaraj-internal-project"
ZONE="asia-southeast1-a"
REGION="asia-southeast1"

# 1. Delete the vpn-router VM instance (Releases the static IP)
gcloud compute instances delete vpn-router \
    --zone=$ZONE \
    --project=$PROJECT_ID \
    --quiet

# 2. Release and delete the reserved Static IP address
gcloud compute addresses delete vpn-router-ip \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet

# 3. Delete the VPN firewall rule
gcloud compute firewall-rules delete default-allow-vpn-traffic \
    --project=$PROJECT_ID \
    --quiet
```

*(Note: If you named the firewall rule `allow-vpn-traffic` instead, replace `default-allow-vpn-traffic` with `allow-vpn-traffic`).*

### Cleanup Order Note
The VM is deleted first so that Google Cloud detaches and releases the static IP, allowing the address to be deleted without "resource in use" errors.