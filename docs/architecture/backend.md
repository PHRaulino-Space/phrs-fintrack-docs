# Arquitetura backend

O entrypoint está em backend/cmd/app/main.go. A composição de dependências usa backend/internal/app/app.go e arquivos wiring_*.go. A rota HTTP atravessa os middlewares de backend/internal/controller/http/v1/router.go, chega ao handler, chama o caso de uso e finalmente um repositório PostgreSQL. Entidades ficam em backend/internal/entity. Contratos são interfaces no caso de uso; implementações concretas ficam em backend/internal/infra/postgres/repository.

O mesmo router separa rotas públicas, autenticadas antes de MFA, protegidas por MFA, administração, gerenciamento de workspace e operações com workspace obrigatório. Cookie, chave API e bearer têm condições diferentes de CSRF. Uma rota não herda automaticamente todas as condições de outra; consulte a [jornada de acesso](../product/access-categories-tools.md).

Swagger UI é servida em /api/v1/docs/index.html com prefixo padrão; o JSON em /api/v1/openapi.json. OpenAPI gerado não deve ser regenerado por uma revisão exclusivamente textual.

Fontes: backend/AGENTS.md, backend/internal/controller/http/v1/router.go, backend/internal/app e backend/internal/usecase.
