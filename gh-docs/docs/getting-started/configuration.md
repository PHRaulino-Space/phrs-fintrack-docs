---
sidebar_position: 2
---

# Configuracao

Este guia detalha todas as opcoes de configuracao do FinTrack.

## Variaveis de Ambiente

### Backend

| Variavel | Descricao | Padrao | Obrigatorio |
|----------|-----------|--------|-------------|
| `APP_NAME` | Nome da aplicacao | FinTrack API Go | Nao |
| `APP_VERSION` | Versao da aplicacao | 1.0.0 | Nao |
| `PORT` | Porta do servidor HTTP | 8080 | Nao |
| `SECRET_KEY` | Chave secreta para JWT | - | **Sim** |
| `LOG_LEVEL` | Nivel de log (debug, info, warn, error) | info | Nao |
| `API_PREFIX` | Prefixo das rotas da API | /api | Nao |
| `FRONTEND_URL` | URL do frontend (CORS) | http://localhost:3000 | Nao |
| `DATABASE_URL` | String de conexao PostgreSQL | - | **Sim** |

### Frontend

| Variavel | Descricao | Padrao | Obrigatorio |
|----------|-----------|--------|-------------|
| `NEXT_PUBLIC_API_BASE_URL` | URL base da API | http://localhost:8080 | **Sim** |
| `NEXT_PUBLIC_API_PREFIX` | Prefixo da API | /api/v1 | **Sim** |

### Autenticacao OAuth

| Variavel | Descricao | Padrao | Obrigatorio |
|----------|-----------|--------|-------------|
| `GITHUB_ENABLED` | Habilitar login com GitHub | false | Nao |
| `GITHUB_CLIENT_ID` | Client ID do GitHub App | - | Se habilitado |
| `GITHUB_CLIENT_SECRET` | Client Secret do GitHub App | - | Se habilitado |
| `GITHUB_REDIRECT_URL` | URL de callback OAuth | - | Se habilitado |

## Arquivo de Configuracao Exemplo

### Backend (.env)

```bash
# ===========================================
# CONFIGURACAO DO FINTRACK BACKEND
# ===========================================

# Aplicacao
APP_NAME=FinTrack API
APP_VERSION=1.0.0
PORT=8080
SECRET_KEY=minha-chave-secreta-muito-segura-32-chars
LOG_LEVEL=info
API_PREFIX=/api
FRONTEND_URL=http://localhost:3000

# Banco de Dados
DATABASE_URL=postgresql://fintrack:fintrack123@localhost:5432/fintrack?sslmode=disable

# GitHub OAuth (opcional)
GITHUB_ENABLED=true
GITHUB_CLIENT_ID=Iv1.abc123def456
GITHUB_CLIENT_SECRET=abc123def456ghi789jkl012mno345pqr678
GITHUB_REDIRECT_URL=http://localhost:8080/api/v1/auth/github/callback
```

### Frontend (.env.local)

```bash
# ===========================================
# CONFIGURACAO DO FINTRACK FRONTEND
# ===========================================

# API
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
NEXT_PUBLIC_API_PREFIX=/api/v1
```

## Configuracao do Banco de Dados

### String de Conexao

Formato da `DATABASE_URL`:

```
postgresql://[usuario]:[senha]@[host]:[porta]/[database]?sslmode=[modo]
```

Exemplos:

```bash
# Desenvolvimento local
DATABASE_URL=postgresql://fintrack:fintrack@localhost:5432/fintrack?sslmode=disable

# Docker
DATABASE_URL=postgresql://fintrack:fintrack@postgres:5432/fintrack?sslmode=disable

# Producao com SSL
DATABASE_URL=postgresql://fintrack:senha@db.exemplo.com:5432/fintrack?sslmode=require
```

### Extensoes Necessarias

O FinTrack requer as seguintes extensoes PostgreSQL:

```sql
-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Vector embeddings para IA
CREATE EXTENSION IF NOT EXISTS vector;
```

## Configuracao do GitHub OAuth

### 1. Crie um GitHub App

1. Acesse https://github.com/settings/developers
2. Clique em "New OAuth App"
3. Preencha:
   - **Application name**: FinTrack
   - **Homepage URL**: http://localhost:3000
   - **Authorization callback URL**: http://localhost:8080/api/v1/auth/github/callback

### 2. Configure as Variaveis

```bash
GITHUB_ENABLED=true
GITHUB_CLIENT_ID=seu-client-id
GITHUB_CLIENT_SECRET=seu-client-secret
GITHUB_REDIRECT_URL=http://localhost:8080/api/v1/auth/github/callback
```

### 3. URLs para Producao

Para producao, atualize as URLs:

```bash
GITHUB_REDIRECT_URL=https://api.seudominio.com/api/v1/auth/github/callback
FRONTEND_URL=https://app.seudominio.com
```

## Configuracao de CORS

O backend configura CORS automaticamente baseado em `FRONTEND_URL`:

```go
cors.Config{
    AllowOrigins:     []string{config.Server.FrontendURL},
    AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
    AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Workspace-ID"},
    AllowCredentials: true,
    MaxAge:           12 * time.Hour,
}
```

Para multiplas origens, separe por virgula:

```bash
FRONTEND_URL=http://localhost:3000,https://app.seudominio.com
```

## Niveis de Log

| Nivel | Descricao | Uso |
|-------|-----------|-----|
| `debug` | Maximo detalhe | Desenvolvimento |
| `info` | Operacoes normais | Staging |
| `warn` | Alertas | Producao |
| `error` | Apenas erros | Producao critica |

## Configuracao de Timeout

O servidor HTTP usa os seguintes timeouts:

| Parametro | Valor | Descricao |
|-----------|-------|-----------|
| Read Timeout | 5s | Tempo maximo para ler request |
| Write Timeout | 60s | Tempo maximo para escrever response |
| Shutdown Timeout | 3s | Tempo para graceful shutdown |

## Pool de Conexoes do Banco

Configuracoes padrao do pool:

| Parametro | Valor |
|-----------|-------|
| Max Idle Connections | 10 |
| Max Open Connections | 100 |
| Connection Max Lifetime | 1 hora |

## Configuracao de Seguranca

### Cookies de Autenticacao

| Cookie | Duracao | Flags |
|--------|---------|-------|
| `fintrack_token` | 24 horas | HttpOnly, Secure (prod), SameSite=Lax |
| `oauth_state` | 5 minutos | HttpOnly, Secure (prod) |
| `fintrack_post_login_redirect` | 5 minutos | HttpOnly |

### Boas Praticas

1. **SECRET_KEY**: Use pelo menos 32 caracteres aleatorios
2. **HTTPS**: Sempre use HTTPS em producao
3. **Senhas de banco**: Use senhas fortes e unicas
4. **Backup de .env**: Nunca commite arquivos .env no git

## Proximos Passos

- [Primeiros Passos](/docs/getting-started/first-steps)
- [Configuracao de Deployment](/docs/deployment/self-hosting)
