Deployment Repository for TecBooks/MxRep Stack

# Purpose

This repo has the docker configurations for the correct deployment of both the backend (MxRep-Backend) repo and the frontend (TecBooks_V2) repo, which should be on the same level as this directory, named 'backend' and 'frontend'.

# Contents

The contents consist of docker compose files for both development and production environments, as well as the nginx configurations for connection to the tecbooks domain, and scripts for deployment/re-deployment of the container.

# Services

The services included in the docker container:
- **Frontend**: React app (TecBooks_V2) - served via nginx
- **Backend**: Node.js API (MxRep-Backend) - Express server
- **Nginx**: Reverse proxy for routing and SSL termination
- **Database**: MongoDB Atlas (cloud-hosted, not in container)

# Setup Instructions

## 1. Clone Repositories

```bash
cd ~/tecbooks
git clone <backend-repo-url> backend
git clone <frontend-repo-url> frontend
git clone <deployment-repo-url> deployment
```

## 2. Configure Environment Variables

```bash
cd deployment
cp .env.production.example .env.production
# Edit .env.production with your actual values
```

## 3. Build and Run

```bash
docker-compose -f docker-compose.production.yml up -d --build
```

## 4. Check Status

```bash
docker-compose -f docker-compose.production.yml ps
docker-compose -f docker-compose.production.yml logs -f
```

## 5. Stop Services

```bash
docker-compose -f docker-compose.production.yml down
```

# SSL Setup (After Domain)

1. Get SSL certificates (use certbot/Let's Encrypt)
2. Place certificates in `nginx/ssl/`
3. Uncomment HTTPS server block in `nginx/nginx.conf`
4. Restart nginx: `docker-compose restart nginx`

# Architecture

```
Internet → Port 80/443
    ↓
[Nginx Reverse Proxy]
    ↓
    ├─→ /api/*  → Backend (Node.js:3000)
    └─→ /*      → Frontend (Static React)
```
