---
sidebar_position: 1
---

# Instalação

Este guia descreve como configurar o ambiente do FinTrack para desenvolvimento e uso. O projeto é composto por dois submódulos principais: `frontend` e `backend`, além de um banco de dados PostgreSQL.

## Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas:

- **Git**: Para versionamento de código.
- **Docker** e **Docker Compose**: Para rodar o banco de dados e serviços auxiliares.
- **Go** (versão 1.22+): Para o backend.
- **Node.js** (versão 20+) e **npm/pnpm**: Para o frontend.
- **Make**: Para executar comandos de build e automação.

## Passo 1: Clonar o Repositório

Clone o repositório principal e inicialize os submódulos.

```bash
git clone https://github.com/PHRaulino-Space/fintrack.git
cd fintrack

# O projeto inclui um script utilitário para configurar os submódulos
bash install-submodules.sh
```

Caso prefira fazer manualmente:
```bash
git submodule update --init --recursive
```

## Passo 2: Configurar o Banco de Dados

O FinTrack utiliza PostgreSQL. Você pode subir uma instância rapidamente usando Docker (se houver um `docker-compose.yml` na raiz ou criar um).

Exemplo de comando para subir um container Postgres simples:

```bash
docker run --name fintrack-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=fintrack -p 5432:5432 -d postgres:15
```

Certifique-se de criar o banco de dados `fintrack` e aplicar o schema localizado em `backend/docs/fintrack_schema.sql`.

## Passo 3: Configurar o Backend

Navegue até a pasta do backend:

```bash
cd backend
```

1.  **Instalar dependências**:
    ```bash
    make deps
    ```

2.  **Configuração**:
    Verifique o arquivo `config/config.go` ou variáveis de ambiente para conectar ao banco de dados. Geralmente, você precisará definir `DB_URL` ou similar.

3.  **Rodar a aplicação**:
    ```bash
    make run
    ```
    O servidor iniciará (padrão: `localhost:8080`).

## Passo 4: Configurar o Frontend

Navegue até a pasta do frontend:

```bash
cd frontend
```

1.  **Instalar dependências**:
    ```bash
    npm install
    # ou
    pnpm install
    ```

2.  **Configuração**:
    Crie um arquivo `.env.local` na raiz do frontend com a URL do backend:
    ```env
    NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
    ```

3.  **Rodar a aplicação**:
    ```bash
    npm run dev
    ```
    O frontend estará acessível em `http://localhost:3000`.

## Verificação

Acesse `http://localhost:3000` no seu navegador. Você deve ver a tela de login do FinTrack.
