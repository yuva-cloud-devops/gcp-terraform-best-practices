#!/bin/bash
set -euo pipefail

echo "===> [Bastion Bootstrap] Starting instance initialization at $(date)"

# Update and install required packages
apt-get update -y
apt-get install -y nginx curl jq net-tools

# Configure Nginx landing page
cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Production Bastion Jump Host</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f8; color: #333; }
    .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    h1 { color: #1a73e8; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Production Bastion Jump Host Active</h1>
    <p><strong>Hostname:</strong> $(hostname)</p>
    <p><strong>Deployment Mode:</strong> Shell Script Bootstrap</p>
    <p><strong>Initialized:</strong> $(date)</p>
  </div>
</body>
</html>
EOF

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

echo "===> [Bastion Bootstrap] Completed successfully at $(date)"
