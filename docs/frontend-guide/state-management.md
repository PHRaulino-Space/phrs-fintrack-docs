# Estado no frontend

frontend/src/hooks/use-auth.ts usa Zustand para usuário, workspaces e workspace ativo; a persistência guarda apenas a seleção do workspace. Tokens de sessão ficam em cookies HttpOnly do backend, não em uma store JWT. frontend/src/services/data-cache.ts e hooks por domínio administram cache/invalidação de dados de servidor. Formulários usam os componentes e validadores existentes do respectivo domínio.

O layout de produto é cliente porque ProtectedRoute usa hooks. Não presuma que toda leitura ocorre em Server Component. A seleção do workspace é fixada em cada requisição HTTP e validada pelo backend. Veja [arquitetura frontend](../architecture/frontend.md) e [acesso](../product/access-categories-tools.md).

Fontes: frontend/src/hooks/use-auth.ts, frontend/src/services/data-cache.ts, frontend/src/app/(fintrack)/layout.tsx, frontend/src/lib/api.ts.
