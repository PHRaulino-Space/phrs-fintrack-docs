# Arquitetura frontend

O projeto usa Next.js 16.1.6, React 19, TypeScript 5, Tailwind 4, App Router e componentes de shadcnblocks/shadcn. Rotas de autenticação ficam em src/app/(auth); páginas de produto em src/app/(fintrack). O layout de produto usa ProtectedRoute, sidebar e navegação móvel.

Chamadas à API passam por src/lib/api.ts. Cookies HttpOnly mantêm a sessão; o cookie CSRF é lido pelo cliente para mutações. O workspace é fixado por requisição antes das tentativas de recuperação, conforme src/lib/api-retry.ts. Um 401 pode acionar refresh coordenado entre abas; outras falhas são tentadas novamente apenas para métodos seguros ou escritas com chave de idempotência. Hooks e serviços em src/hooks e src/services transformam os dados para as telas.

Use data civil YYYY-MM-DD para calendário e competência YYYY-MM para meses; src/lib/date-utils.ts e timezone.ts distinguem essas formas de timestamps. Veja [transações e datas](../product/transactions-recurring.md), [mapa técnico](../product/domain-map.md) e [inventário de páginas](../product/coverage.md).

Fontes: frontend/package.json, frontend/src/app/(fintrack)/layout.tsx, frontend/src/components/protected-route.tsx, frontend/src/lib/api.ts e api-retry.ts.
