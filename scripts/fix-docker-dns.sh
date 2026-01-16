#!/bin/bash

# Fix Docker DNS resolution issues during build

echo "=== Fixing Docker DNS configuration ==="

# Create or update Docker daemon config
sudo mkdir -p /etc/docker

# Backup existing config if it exists
if [ -f /etc/docker/daemon.json ]; then
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
    echo "Backed up existing daemon.json"
fi

# Write new config with DNS settings
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "dns": ["8.8.8.8", "8.8.4.4", "1.1.1.1"]
}
EOF

echo "Updated /etc/docker/daemon.json with DNS settings"

# Restart Docker to apply changes
echo "Restarting Docker daemon..."
sudo systemctl restart docker

echo "=== Docker DNS configuration complete ==="
echo "You can now try building again"
