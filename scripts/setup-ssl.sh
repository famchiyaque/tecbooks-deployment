#!/bin/bash

# SSL Setup Script for TecBooks
# This script uses Certbot to get Let's Encrypt certificates

set -e

DOMAIN="tecbooks.org"
EMAIL="andrezala03@gmail.com"  # Change this!

echo "=== Setting up SSL for $DOMAIN ==="

# Install certbot if not already installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    sudo apt update
    sudo apt install -y certbot
fi

# Stop nginx temporarily to allow certbot to bind to port 80
echo "Stopping nginx container..."
cd ~/tecbooks/deployment
sudo docker compose -f docker-compose.production.yml stop nginx

# Get certificates
echo "Requesting SSL certificates..."
sudo certbot certonly --standalone \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    --preferred-challenges http

# Copy certificates to deployment directory
echo "Copying certificates..."
sudo mkdir -p nginx/ssl
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/
sudo chmod 644 nginx/ssl/*.pem

# Start nginx
echo "Starting nginx..."
sudo docker compose -f docker-compose.production.yml start nginx

echo "=== SSL setup complete! ==="
echo "Now uncomment the HTTPS server block in nginx/nginx.conf"
echo "and uncomment the HTTP->HTTPS redirect"
