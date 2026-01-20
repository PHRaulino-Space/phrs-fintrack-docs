# Rodando Localmente

Como iniciar todos os serviços para desenvolvimento.

## 1. Banco de Dados

Suba o Postgres via Docker:

```bash
docker run --name fintrack-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=fintrack -p 5432:5432 -d postgres:15
```

Rode o script de criação de tabelas:
```bash
psql -h localhost -U postgres -d fintrack < backend/docs/fintrack_schema.sql
```

## 2. Backend

Abra um terminal na pasta `backend/`:

```bash
# Baixar dependências
go mod tidy

# Rodar servidor
go run cmd/app/main.go
```
O backend rodará em `localhost:8080`.

## 3. Frontend

Abra outro terminal na pasta `frontend/`:

```bash
# Instalar dependências
npm install

# Rodar servidor de desenvolvimento
npm run dev
```
O frontend rodará em `localhost:3000`.

## 4. Testando

Acesse `http://localhost:3000`. O frontend deve carregar e tentar conectar ao backend. Se houver erro de conexão, verifique o console do browser e do backend.
