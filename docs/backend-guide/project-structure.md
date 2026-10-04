# Estrutura do backend

O backend é um projeto Go/Gin. cmd/app inicia a API; cmd/dbsetup executa setup explícito de schema, migrações, funções e gatilhos; cmd/mcp-server inicia o serviço MCP separado. internal/app compõe dependências; internal/controller/http/v1 implementa transporte; internal/usecase contém regras e interfaces; internal/entity modela o domínio; internal/infra/postgres/repository persiste com GORM e SQL; pkg reúne infraestrutura compartilhada.

A [arquitetura backend](../architecture/backend.md) explica o caminho de uma requisição. O README e o AGENTS.md do backend trazem comandos atuais. Não há migração nem seed automática no startup.

Fontes: backend/cmd, backend/internal/app, backend/internal/controller/http/v1/router.go, backend/internal/usecase, backend/internal/infra/dbsetup e backend/AGENTS.md.
