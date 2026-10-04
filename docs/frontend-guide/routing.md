# Roteamento e proteção

As rotas seguem arquivos page.tsx no Next.js App Router. O grupo (auth) contém entrada e recuperação; o grupo (fintrack) usa ProtectedRoute no layout para validar a sessão no cliente antes de mostrar a área de produto. Algumas páginas antigas redirecionam para destinos atuais, como metas dentro de Planejamento e investimentos na carteira. Uma rota existir não significa que apareça no menu lateral.

O menu efetivo é definido em frontend/src/components/layout/data/sidebar-data.tsx. A API tem outra fronteira: autenticação, MFA, CSRF e workspace são aplicados em backend/internal/controller/http/v1/router.go. Veja a [jornada de acesso](../product/access-categories-tools.md) e o [inventário de telas](../product/coverage.md).

Fontes: frontend/src/app/(fintrack)/layout.tsx, frontend/src/components/protected-route.tsx, frontend/src/components/layout/data/sidebar-data.tsx e backend/internal/controller/http/v1/router.go.
