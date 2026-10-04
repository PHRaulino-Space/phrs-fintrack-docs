# Visão geral da arquitetura

FinTrack combina o frontend Next.js 16 App Router, uma API Go/Gin e PostgreSQL. O navegador usa cookies de sessão; o cliente Axios central adiciona CSRF e workspace. O backend reúne handlers, casos de uso, repositórios e entidades. Há integrações opcionais de serviço de embeddings, armazenamento de imagens, Open Finance via Pluggy e MCP; a disponibilidade e o destino dos dados dessas integrações dependem da configuração.

O [mapa de domínio](../product/domain-map.md) mostra o caminho de uma operação e os efeitos entre módulos. Para comportamento financeiro e cálculos, comece pelo [índice de produto](../product/index.md). Os detalhes do ambiente estão nos README e AGENTS.md dos dois projetos.

Fontes: frontend/package.json, frontend/src/lib/api.ts, backend/internal/controller/http/v1/router.go, backend/internal/app, backend/internal/service/embedding_service.go e backend/internal/infra/openfinance/pluggy/client.go.
