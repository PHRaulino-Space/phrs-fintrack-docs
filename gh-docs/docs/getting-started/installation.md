---
sidebar_position: 1
---

# Instalacao

Este guia explica como instalar e configurar o FinTrack em seu ambiente.

## Pre-requisitos

Antes de comecar, certifique-se de ter instalado:

### Obrigatorios

| Software | Versao Minima | Descricao |
|----------|---------------|-----------|
| **Docker** | 20.10+ | Container runtime |
| **Docker Compose** | 2.0+ | Orquestracao de containers |
| **Git** | 2.30+ | Controle de versao |

### Para Desenvolvimento

| Software | Versao | Descricao |
|----------|--------|-----------|
| **Node.js** | 18+ | Runtime JavaScript |
| **pnpm** | 8+ | Gerenciador de pacotes |
| **Go** | 1.24+ | Linguagem do backend |
| **PostgreSQL** | 15+ | Banco de dados |

## Instalacao com Docker (Recomendado)

### 1. Clone o Repositorio

```bash
git clone https://github.com/PHRaulino-Space/fintrack.git
cd fintrack
```

### 2. Configure as Variaveis de Ambiente

Copie o arquivo de exemplo e edite conforme necessario:

```bash
cp .env.example .env
```

Edite o arquivo `.env`:

```bash
# Aplicacao
APP_NAME=FinTrack
APP_VERSION=1.0.0
PORT=8080
SECRET_KEY=sua-chave-secreta-super-segura-mude-isso
LOG_LEVEL=info

# Banco de Dados
DATABASE_URL=postgresql://fintrack:fintrack@postgres:5432/fintrack?sslmode=disable

# Frontend
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
NEXT_PUBLIC_API_PREFIX=/api/v1

# OAuth (opcional)
GITHUB_ENABLED=false
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
GITHUB_REDIRECT_URL=http://localhost:8080/api/v1/auth/github/callback
```

### 3. Inicie os Containers

```bash
docker-compose up -d
```

### 4. Verifique a Instalacao

```bash
# Verificar status dos containers
docker-compose ps

# Verificar logs
docker-compose logs -f

# Testar API
curl http://localhost:8080/api/health
```

### 5. Acesse o Sistema

- **Frontend**: http://localhost:3000
- **API**: http://localhost:8080/api/v1
- **Swagger**: http://localhost:8080/api/v1/docs

## Instalacao Manual (Desenvolvimento)

### Backend

```bash
# Entre no diretorio do backend
cd backend

# Copie o arquivo de configuracao
cp .env.sample .env

# Edite as variaveis de ambiente
nano .env

# Instale as dependencias
go mod download

# Execute as migracoes
go run cmd/app/main.go migrate

# Inicie o servidor
go run cmd/app/main.go
```

### Frontend

```bash
# Entre no diretorio do frontend
cd frontend

# Instale as dependencias
pnpm install

# Configure as variaveis de ambiente
cp .env.example .env.local

# Inicie o servidor de desenvolvimento
pnpm dev
```

### Banco de Dados

```bash
# Crie o banco de dados
createdb fintrack

# Habilite as extensoes necessarias
psql -d fintrack -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
psql -d fintrack -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

## Estrutura de Portas

| Servico | Porta | Descricao |
|---------|-------|-----------|
| Frontend | 3000 | Interface web Next.js |
| Backend | 8080 | API REST Go/Gin |
| PostgreSQL | 5432 | Banco de dados |

## Verificacao da Instalacao

### Teste de Saude da API

```bash
curl -X GET http://localhost:8080/api/health
```

Resposta esperada:

```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

### Teste de Conexao com Banco

```bash
curl -X GET http://localhost:8080/api/v1/currencies
```

## Solucao de Problemas

### Container nao inicia

```bash
# Verifique os logs
docker-compose logs backend

# Reconstrua as imagens
docker-compose build --no-cache
docker-compose up -d
```

### Erro de conexao com banco

```bash
# Verifique se o PostgreSQL esta rodando
docker-compose ps postgres

# Verifique a string de conexao
echo $DATABASE_URL
```

### Porta ja em uso

```bash
# Encontre o processo usando a porta
lsof -i :8080

# Mate o processo ou mude a porta no .env
```

## Proximos Passos

Apos a instalacao bem-sucedida:

1. [Configure o sistema](/docs/getting-started/configuration)
2. [Siga os primeiros passos](/docs/getting-started/first-steps)
3. [Configure autenticacao OAuth](/docs/api-reference/authentication)
