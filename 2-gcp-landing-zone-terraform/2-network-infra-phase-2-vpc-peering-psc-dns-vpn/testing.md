Here are the `gcloud` commands to create and test two private VMs—one in **`vpc-hub` (Mumbai)** and one in **`vpc-sub` (Singapore)**.

---

### Step 1: Create the Two Test VMs

#### VM 1: `vm-hub` in Mumbai (`vpc-hub`)
```bash
gcloud compute instances create vm-hub \
    --project="yuvaraj-internal-project" \
    --zone="asia-south1-a" \
    --machine-type="e2-micro" \
    --image-family="debian-12" \
    --image-project="debian-cloud" \
    --network-interface="subnet=projects/yuvaraj-internal-project/regions/asia-south1/subnetworks/subnet-hub,no-address" \
    --tags="allow-iap-ssh"
```

#### VM 2: `vm-sub` in Singapore (`vpc-sub`)
```bash
gcloud compute instances create vm-sub \
    --project="yuvaraj-internal-project" \
    --zone="asia-southeast1-a" \
    --machine-type="e2-micro" \
    --image-family="debian-12" \
    --image-project="debian-cloud" \
    --network-interface="subnet=projects/yuvaraj-internal-project/regions/asia-southeast1/subnetworks/subnet-sub,no-address" \
    --tags="allow-iap-ssh"
```

---

### Step 2: Get Their Private IP Addresses

Run this command to check the assigned internal IPs:

```bash
gcloud compute instances list --project="yuvaraj-internal-project" \
    --filter="name:(vm-hub vm-sub)" \
    --format="table(name, zone, networkInterfaces[0].networkIP:label=INTERNAL_IP)"
```
*(You will see `vm-hub` with an IP like `10.10.1.2` and `vm-sub` with an IP like `10.20.1.2`)*.

---

### Step 3: Connect and Test

#### 1. SSH into `vm-hub` via IAP:
```bash
gcloud compute ssh vm-hub \
    --project="yuvaraj-internal-project" \
    --zone="asia-south1-a" \
    --tunnel-through-iap
```

#### 2. Run the Verification Tests (Inside `vm-hub`):

* **Install tools (if needed):**
  ```bash
  sudo apt update && sudo apt install -y dnsutils iputils-ping curl
  ```

* **Test 1: Cross-VPC Peering Connectivity (Ping `vm-sub` in Singapore):**
  ```bash
  # Replace 10.20.1.2 with vm-sub's actual private IP
  ping -c 4 10.20.1.2
  ```
  *(Packets returning with ~30ms latency confirms cross-region VPC peering is active).*

* **Test 2: Cloud DNS Private Zone Resolution:**
  ```bash
  nslookup app.dev.internal
  nslookup db.dev.internal
  nslookup web.dev.internal
  ```
  *(Confirms Cloud DNS internal resolution is working without public internet).*

* **Test 3: Cloud NAT Outbound Internet:**
  ```bash
  curl -I https://www.google.com
  ```
  *(HTTP 200 confirms `nat-hub` is handling egress).*

---

### Step 4: Cleanup (When Done)

To avoid incurring compute costs, delete both instances once you finish testing:

```bash
gcloud compute instances delete vm-hub --zone="asia-south1-a" --project="yuvaraj-internal-project" --quiet
gcloud compute instances delete vm-sub --zone="asia-southeast1-a" --project="yuvaraj-internal-project" --quiet
```


### Next Steps to Deploy and Verify

#### 1. Initialize and Apply Terraform
From the directory `2-gcp-landing-zone-terraform/2-network-infra-phase-2-vpc-peering-psc-dns-vpn`:
```bash
terraform init
terraform plan
terraform apply
```

#### 2. Test from Your VM (`vm-hub` or `vm-sub`)
SSH into your VM via IAP:
```bash
gcloud compute ssh vm-hub --zone=asia-south1-a --tunnel-through-iap --project=yuvaraj-internal-project
```

Run DNS lookup checks:
```bash
# 1. Verify resolution of the PSC custom domain
nslookup storage.p.googleapis.com

# 2. Verify resolution of standard Google API domain (via override zone)
nslookup storage.googleapis.com
```
Both queries will resolve to your private PSC endpoint: `10.10.0.100`.

Run an HTTPS connectivity test over PSC:
```bash
curl -I https://storage.p.googleapis.com
```
*(Returns an HTTP/2 response from Google's internal API frontend server without traversing the public internet).*














