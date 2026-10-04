# Testes frontend

pnpm run check executa lint, typecheck e Jest. Os testes de serviço/hook ficam em frontend/src/services/__tests__, frontend/src/hooks/__tests__ e junto a componentes. MSW fornece respostas falsas de API para parte deles. A suíte Playwright em frontend/e2e cobre jornadas de autenticação, planejamento, dashboard, metas, importação, categorias e responsividade com API falsa determinística.

Use pnpm, não npm, no frontend. O baseline de check conhecido está descrito em frontend/AGENTS.md e deve ser separado de regressões novas. A [matriz de cobertura](../product/coverage.md) indica os testes mais relevantes para cada fluxo.

Fontes: frontend/package.json, frontend/jest.config.ts, frontend/playwright.config.ts e frontend/e2e.
