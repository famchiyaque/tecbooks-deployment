#!/bin/bash

# Auto-deployment script for development environment
# This script is triggered by GitHub Actions webhook

set -e

echo "=== Starting Development Deployment ==="
date

cd ~/tecbooks

# Pull latest changes from develop branch
echo "Pulling backend changes..."
cd backend
git pull origin develop

echo "Pulling frontend changes..."
cd ../frontend
git pull origin develop

echo "Pulling deployment changes..."
cd ../deployment
git pull origin main

# Restart containers (no rebuild needed - volumes handle code changes)
echo "Restarting containers..."
sudo docker compose -f docker-compose.dev.yml restart

echo "=== Deployment Complete ==="
date

# Optional: Show container status
sudo docker compose -f docker-compose.dev.yml ps
