# Estrutura do frontend

O App Router do Next.js 16 está em frontend/src/app. (auth) contém login, registro, verificação de email/MFA e recuperação; (fintrack) contém dashboard, planejamento, transações, importação, carteira, metas, workspace, notificações e configurações; (errors) contém páginas de erro. O [inventário](../product/coverage.md) lista as 42 páginas observadas e distingue menu de rota.

frontend/src/components reúne componentes de domínio e UI, src/hooks reúne consultas e estado reutilizável, src/services contém clientes e transformações, e src/lib/api.ts centraliza chamadas HTTP. Os testes de interface estão em frontend/e2e e os unitários junto aos módulos. O README e o AGENTS.md do frontend são os guias de instalação e convenções atuais.

Fonte: frontend/src/app, frontend/src/components/layout/data/sidebar-data.tsx, frontend/src/hooks, frontend/src/services e frontend/package.json.
