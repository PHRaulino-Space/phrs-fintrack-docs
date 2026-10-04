# Estratégia de testes

No backend, make check executa lint, typecheck e testes de unidade sem banco e sem segredos. make test-integration é separado, usa arquivos marcados com build tag integration e exige Docker/Testcontainers ou FINTRACK_TEST_PG_URL/DATABASE_URL. Não substitua testes de repositório por mocks quando a regra depende de transação, constraint ou gatilho.

No frontend, pnpm run check executa ESLint, TypeScript e Jest/MSW. pnpm run test:e2e usa Playwright com API falsa determinística para jornadas de navegador. O checkout frontend já declara falhas de baseline em AGENTS.md; registre-as separadamente de mudanças documentais.

Para regras financeiras, procure testes junto de backend/internal/usecase, backend/internal/infra/postgres/repository, frontend/src/services/__tests__, frontend/src/hooks/__tests__ e frontend/e2e. A [matriz de cobertura](../product/coverage.md) relaciona jornadas e evidência. A revisão documental não executou testes dependentes de banco.
