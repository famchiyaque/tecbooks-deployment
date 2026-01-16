#!/bin/bash

# SSL Setup Script for TecBooks
# This script uses Certbot to get Let's Encrypt certificates

set -e

DOMAIN="dev.tecbooks.org"
EMAIL="andrezala03@gmail.com"  # Change this!

echo "=== Setting up SSL for $DOMAIN ==="

# Install certbot if not already installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    sudo apt update
    sudo apt install -y certbot
fi

# Stop all containers to free up port 80
echo "Stopping all containers to free port 80..."
cd ~/tecbooks/deployment
sudo docker compose -f docker-compose.dev.yml down

# Get certificates
echo "Requesting SSL certificates..."
echo "Note: If this fails, DNS might not be propagated yet. Wait and try again."
sudo certbot certonly --standalone \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    --preferred-challenges http

# If standalone fails, you can try manual DNS validation:
# sudo certbot certonly --manual --preferred-challenges dns \
#     -d $DOMAIN -d www.$DOMAIN \
#     --email $EMAIL --agree-tos

# Copy certificates to deployment directory
echo "Copying certificates..."
sudo mkdir -p nginx/ssl
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/
sudo chmod 644 nginx/ssl/*.pem

# Start all containers
echo "Starting all containers..."
sudo docker compose -f docker-compose.dev.yml up -d

echo "=== SSL setup complete! ==="
echo "Now uncomment the HTTPS server block in nginx/nginx.conf"
echo "and uncomment the HTTP->HTTPS redirect"
