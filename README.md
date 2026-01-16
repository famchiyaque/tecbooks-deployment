Deployment Repository for TecBooks/MxRep Stack

# Purpose

This repo has the docker configurations for the correct deployment of both the backend (MxRep-Backend) repo and the frontend (TecBooks_V2) repo, which should be on the same level as this directory, named 'backend' and 'frontend'.

# Contents

The contents consist of docker compose files for both development and production environments, as well as the nginx configurations for connection to the tecbooks domain, and scripts for deployment/re-deployment of the container.

# Services

The services included in the docker container:
- **Frontend**: React app (TecBooks_V2) - served via nginx (prod) or Vite dev server (dev)
- **Backend**: Node.js API (MxRep-Backend) - Express server
- **Nginx**: Reverse proxy for routing and SSL termination
- **Database**: MongoDB Atlas (cloud-hosted, not in container)

# Setup Instructions

## Production Setup

### 1. Clone Repositories

```bash
cd ~/tecbooks
git clone <backend-repo-url> backend
git clone <frontend-repo-url> frontend
git clone <deployment-repo-url> deployment
```

### 2. Configure Environment Variables

```bash
cd deployment
cp .env.production.example .env
# Edit .env with your actual values
```

### 3. Setup SSL

```bash
# Edit email in script
nano scripts/setup-ssl.sh
chmod +x scripts/setup-ssl.sh
./scripts/setup-ssl.sh
```

### 4. Build and Run

```bash
docker compose -f docker-compose.production.yml up -d --build
```

### 5. Check Status

```bash
docker compose -f docker-compose.production.yml ps
docker compose -f docker-compose.production.yml logs -f
```

## Development Setup

### 1. Clone Repositories (develop branch)

```bash
cd ~/tecbooks
git clone -b develop <backend-repo-url> backend
git clone -b develop <frontend-repo-url> frontend
git clone <deployment-repo-url> deployment
```

### 2. Configure Environment Variables

```bash
cd deployment
cp .env.dev.example .env
# Edit .env with your actual values
```

### 3. Setup SSL for dev subdomain

```bash
# Update domain in script to dev.tecbooks.org
nano scripts/setup-ssl.sh
./scripts/setup-ssl.sh
```

### 4. Build and Run

```bash
docker compose -f docker-compose.dev.yml up -d --build
```

### 5. Setup Auto-Deployment (Optional)

#### On Dev VM:

```bash
# 1. Install webhook server as systemd service
cd ~/tecbooks/deployment
sudo cp webhook-server.service /etc/systemd/system/
sudo nano /etc/systemd/system/webhook-server.service  # Update WEBHOOK_SECRET

# 2. Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable webhook-server
sudo systemctl start webhook-server
sudo systemctl status webhook-server

# 3. Open firewall for webhook
sudo ufw allow 9000/tcp

# 4. Make deploy script executable
chmod +x scripts/deploy-dev.sh
```

#### On GitHub:

1. Go to **Backend repo → Settings → Secrets and variables → Actions**
2. Add secrets:
   - `DEV_WEBHOOK_URL`: `http://dev-vm-ip:9000/webhook`
   - `WEBHOOK_SIGNATURE`: (same secret as in webhook-server.service)

3. Repeat for **Frontend repo**

4. Push to `develop` branch - deployment happens automatically!

# Architecture

## Production
```
Internet → Port 80/443
    ↓
[Nginx Reverse Proxy]
    ↓
    ├─→ /api/*  → Backend (Node.js:3000)
    └─→ /*      → Frontend (Static React)
```

## Development
```
Internet → Port 80/443
    ↓
[Nginx Reverse Proxy]
    ↓
    ├─→ /api/*  → Backend (Nodemon:3000) [Hot Reload]
    └─→ /*      → Frontend (Vite:5173) [HMR]
         ↑
    Code mounted from host (instant changes)
```

# Common Commands

## Production

```bash
# Start
sudo docker compose -f docker-compose.production.yml up -d

# Stop
sudo docker compose -f docker-compose.production.yml down

# Rebuild
sudo docker compose -f docker-compose.production.yml up -d --build

# View logs
sudo docker compose -f docker-compose.production.yml logs -f

# Restart single service
sudo docker compose -f docker-compose.production.yml restart nginx
```

## Development

```bash
# Start
sudo docker compose -f docker-compose.dev.yml up -d

# Stop
sudo docker compose -f docker-compose.dev.yml down

# Restart (after git pull)
sudo docker compose -f docker-compose.dev.yml restart

# View logs
sudo docker compose -f docker-compose.dev.yml logs -f frontend
```

# SSL Renewal

SSL certificates auto-renew via certbot. To manually renew:

```bash
cd ~/tecbooks/deployment
chmod +x scripts/renew-ssl.sh
./scripts/renew-ssl.sh
```

# Troubleshooting

## Docker DNS issues during build

```bash
./scripts/fix-docker-dns.sh
```

## Clear Docker cache

```bash
sudo docker builder prune -af
```

## Check webhook server

```bash
sudo systemctl status webhook-server
sudo journalctl -u webhook-server -f
```
