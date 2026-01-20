---
sidebar_position: 2
---

# Configuração

O FinTrack pode ser configurado através de arquivos de configuração e variáveis de ambiente.

## Backend

O backend em Go utiliza configurações que podem ser sobrescritas por variáveis de ambiente.

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `PORT` | Porta do servidor HTTP | `8080` |
| `DB_HOST` | Host do PostgreSQL | `localhost` |
| `DB_PORT` | Porta do PostgreSQL | `5432` |
| `DB_USER` | Usuário do Banco | `postgres` |
| `DB_PASSWORD` | Senha do Banco | `postgres` |
| `DB_NAME` | Nome do Banco | `fintrack` |
| `JWT_SECRET` | Chave secreta para tokens JWT | (obrigatório em prod) |
| `LOG_LEVEL` | Nível de log (debug, info, error) | `info` |

## Frontend

O frontend Next.js utiliza variáveis de ambiente prefixadas com `NEXT_PUBLIC_` para configurações expostas ao navegador.

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `NEXT_PUBLIC_API_BASE_URL` | URL base da API do Backend | `http://localhost:8080` |
| `NEXT_PUBLIC_API_PREFIX` | Prefixo da API (opcional) | `/api/v1` |

## Banco de Dados

O banco de dados deve ser inicializado com o schema correto. O arquivo de dump inicial está localizado em `backend/docs/fintrack_schema.sql`.

Para restaurar o schema:

```bash
psql -h localhost -U postgres -d fintrack < backend/docs/fintrack_schema.sql
```
