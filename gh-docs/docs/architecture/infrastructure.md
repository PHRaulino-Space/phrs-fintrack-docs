---
sidebar_position: 6
---

# Infraestrutura

O FinTrack e projetado para ser auto-hospedado, rodando em hardware proprio ou cloud privada.

## Topologia

```mermaid
graph TB
    subgraph "Internet"
        User[Usuario]
    end

    subgraph "Rede Privada"
        subgraph "Reverse Proxy"
            Nginx[Nginx/Traefik]
        end

        subgraph "Aplicacao"
            Frontend[Next.js Container]
            Backend[Go Container]
        end

        subgraph "Dados"
            Postgres[(PostgreSQL)]
        end

        subgraph "Opcional"
            Redis[(Redis Cache)]
            Prometheus[Prometheus]
            Grafana[Grafana]
        end
    end

    User --> Nginx
    Nginx --> Frontend
    Nginx --> Backend
    Backend --> Postgres
    Backend --> Redis
    Prometheus --> Backend
    Grafana --> Prometheus
```

## Docker Compose

### Configuracao Base

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: fintrack-db
    environment:
      POSTGRES_USER: fintrack
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: fintrack
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U fintrack"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: fintrack-api
    environment:
      - DATABASE_URL=postgresql://fintrack:${DB_PASSWORD}@postgres:5432/fintrack?sslmode=disable
      - PORT=8080
      - SECRET_KEY=${SECRET_KEY}
      - FRONTEND_URL=http://localhost:3000
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: fintrack-web
    environment:
      - NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
      - NEXT_PUBLIC_API_PREFIX=/api/v1
    ports:
      - "3000:3000"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### Dockerfile Backend

```dockerfile
# backend/Dockerfile
FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /fintrack-api ./cmd/app

FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/

COPY --from=builder /fintrack-api .

EXPOSE 8080
CMD ["./fintrack-api"]
```

### Dockerfile Frontend

```dockerfile
# frontend/Dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN corepack enable pnpm && pnpm build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
```

## Recursos de Hardware

### Minimos

| Componente | Especificacao |
|------------|---------------|
| CPU | 2 cores |
| RAM | 2 GB |
| Disco | 20 GB SSD |
| Rede | 100 Mbps |

### Recomendados

| Componente | Especificacao |
|------------|---------------|
| CPU | 4 cores |
| RAM | 8 GB |
| Disco | 100 GB SSD |
| Rede | 1 Gbps |

## Backup e Recuperacao

### Backup do PostgreSQL

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/backups/fintrack

# Dump do banco
docker exec fintrack-db pg_dump -U fintrack fintrack | gzip > $BACKUP_DIR/fintrack_$DATE.sql.gz

# Manter apenas ultimos 7 dias
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

### Restauracao

```bash
#!/bin/bash
# restore.sh

BACKUP_FILE=$1

# Parar aplicacao
docker-compose stop backend frontend

# Restaurar backup
gunzip -c $BACKUP_FILE | docker exec -i fintrack-db psql -U fintrack fintrack

# Reiniciar aplicacao
docker-compose start backend frontend
```

### Crontab

```cron
# Backup diario as 3h
0 3 * * * /opt/fintrack/backup.sh >> /var/log/fintrack-backup.log 2>&1
```

## Monitoramento

### Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'fintrack-api'
    static_configs:
      - targets: ['backend:8080']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
```

### Metricas Expostas

| Metrica | Tipo | Descricao |
|---------|------|-----------|
| http_requests_total | Counter | Total de requests HTTP |
| http_request_duration_seconds | Histogram | Latencia de requests |
| db_connections_active | Gauge | Conexoes ativas do banco |
| import_sessions_total | Counter | Sessoes de importacao |

### Alertas

```yaml
# alerts.yml
groups:
  - name: fintrack
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical

      - alert: HighLatency
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 2
        for: 5m
        labels:
          severity: warning

      - alert: DatabaseDown
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
```

## Seguranca

### Nginx como Reverse Proxy

```nginx
# /etc/nginx/conf.d/fintrack.conf
upstream frontend {
    server frontend:3000;
}

upstream backend {
    server backend:8080;
}

server {
    listen 443 ssl http2;
    server_name fintrack.example.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # Frontend
    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # API
    location /api {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Firewall

```bash
# UFW rules
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 443/tcp
ufw enable
```

## Escalabilidade

### Horizontal

```yaml
# docker-compose.prod.yml
services:
  backend:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1'
          memory: 1G

  postgres:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

### Load Balancer

```nginx
upstream backend {
    least_conn;
    server backend1:8080;
    server backend2:8080;
    server backend3:8080;
}
```

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and push Docker images
        run: |
          docker build -t fintrack-backend ./backend
          docker build -t fintrack-frontend ./frontend
          docker push fintrack-backend
          docker push fintrack-frontend

      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/fintrack
            docker-compose pull
            docker-compose up -d
```

## Proximos Passos

- [Guia de Self-Hosting](/docs/deployment/self-hosting)
- [Configuracao Docker](/docs/deployment/docker)
