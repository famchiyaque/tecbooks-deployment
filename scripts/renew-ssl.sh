#!/bin/bash

# SSL Renewal Script
# Add to crontab: 0 0 * * * /path/to/renew-ssl.sh

set -e

DOMAIN="tecbooks.org"

echo "=== Renewing SSL certificates ==="

cd ~/tecbooks/deployment

# Stop nginx
sudo docker compose -f docker-compose.production.yml stop nginx

# Renew certificates
sudo certbot renew --standalone

# Copy renewed certificates
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/
sudo chmod 644 nginx/ssl/*.pem

# Start nginx
sudo docker compose -f docker-compose.production.yml start nginx

echo "=== SSL renewal complete ==="
