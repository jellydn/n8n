# Dokku Deployment Guide

This guide covers deploying n8n to Dokku (self-hosted Heroku).

## Prerequisites

- Dokku server set up
- PostgreSQL plugin installed (`dokku postgres`)
- Redis plugin installed (`dokku redis`)

## Quick Start

```bash
# 1. Enable Dockerfile-based deployment
dokku dockerfile:enable n8n

# 2. Set environment variables
dokku config:set n8n \
  N8N_PROTOCOL=https \
  WEBHOOK_URL=https://your-domain.com \
  GENERIC_TIMEZONE=UTC \
  N8N_HOST=0.0.0.0 \
  N8N_PORT=5678

# 3. Create and link PostgreSQL database
dokku postgres:create n8n-db
dokku postgres:link n8n-db n8n

# 4. Create and link Redis (optional, for scaling)
dokku redis:create n8n-cache
dokku redis:link n8n-cache n8n

# 5. Set encryption key (generate a random string)
dokku config:set n8n N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

# 6. Deploy
git push dokku master
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_PROTOCOL` | Protocol (http/https) | `http` |
| `WEBHOK_URL` | Public URL for webhooks | - |
| `GENERIC_TIMEZONE` | Timezone | `UTC` |
| `N8N_HOST` | Host to bind to | `0.0.0.0` |
| `N8N_PORT` | Port | `5678` |
| `N8N_ENCRYPTION_KEY` | Encryption key for credentials | - |
| `EXECUTIONS_TIMEOUT` | Max execution time (seconds) | `3600` |
| `EXECUTIONS_TIMEOUT_MAX` | Max total execution time | `7200` |
| `QUEUE_BULL_REDIS` | Redis URL for queue scaling | - |

## Database Configuration

PostgreSQL is recommended. The `DATABASE_URL` is automatically set when linking:

```bash
dokku postgres:info n8n-db
```

## Troubleshooting

### Build fails

Ensure you're using the correct Node.js version. The Dockerfile specifies Node 22.

### Webhooks not working

Set `WEBHOOK_URL` to your public domain:

```bash
dokku config:set n8n WEBHOOK_URL=https://n8n.yourdomain.com
```

### Static files not loading

Ensure `N8N_PROTOCOL` matches your setup (http/https).

### Slow startup

The first deployment builds the entire monorepo. Subsequent deployments are faster due to Docker layer caching.

## Scaling (Advanced)

For scaling with multiple workers:

```bash
# Set Redis for queue
dokku config:set n8n QUEEN_BULL_REDIS=redis://dokku-redis-n8n-cache:6379

# Scale web processes
dokku ps:scale n8n web=2
```

## Updates

To update:

```bash
git add -A
git commit -m "Update"
git push dokku master
```
