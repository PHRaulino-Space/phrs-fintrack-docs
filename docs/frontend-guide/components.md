# Componentes de interface

Os componentes estão em frontend/src/components e dentro das rotas de frontend/src/app/(fintrack). O projeto prioriza blocos shadcnblocks, depois shadcn/ui, conforme frontend/AGENTS.md. Tabelas usam configuração compartilhada em frontend/src/lib/table-config.ts; a implementação de filtros e paginação deve ser conferida na tela do domínio, não inferida da aparência.

A navegação lateral está em frontend/src/components/layout/data/sidebar-data.tsx. O [inventário de páginas](../product/coverage.md) identifica rotas que não aparecem ali. Exemplos de composição podem ser encontrados nas telas atuais de contas, transações e planejamento; exemplos antigos genéricos não substituem essas fontes.

Fontes: frontend/AGENTS.md, frontend/src/components, frontend/src/app/(fintrack), frontend/src/lib/table-config.ts.
