# Middleware HTTP

backend/internal/controller/http/v1/router.go compõe CORS, rate limit nas rotas públicas, autenticação, escopo de chave API, CSRF, MFA, step-up, administrador e workspace conforme o grupo. Sessão por cookie usa fintrack_token/fintrack_refresh e header X-CSRF-Token em mutações; X-API-Key e bearer têm tratamento próprio. Rotas financeiras requerem X-Workspace-ID (ou query workspace_id para SSE), mas gerenciamento de workspace e perfil não usa esse mesmo grupo.

Verifique a combinação efetiva da rota no router, pois nem toda rota autenticada requer as mesmas condições. Veja [acesso e membros](../product/access-categories-tools.md).

Fontes: backend/internal/controller/http/v1/router.go, backend/internal/controller/http/middleware e backend/AGENTS.md.
