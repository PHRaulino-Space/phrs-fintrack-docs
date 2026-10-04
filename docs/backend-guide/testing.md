# Testes backend

make check reúne lint, typecheck e testes de unidade sem .env, 1Password, API ou banco. make test-integration executa testes marcados integration; requer Docker/Testcontainers ou FINTRACK_TEST_PG_URL/DATABASE_URL. Testes adjacentes aos casos de uso usam mocks manuais quando apropriado; repositórios com locks, constraints e gatilhos precisam de integração.

Não execute testes de integração contra banco de produção. A [matriz de cobertura](../product/coverage.md) aponta cenários relevantes e seus limites. Consulte backend/AGENTS.md e backend/README.md para os alvos reais.

Fontes: backend/Makefile, backend/AGENTS.md, backend/internal/usecase/*_test.go e backend/internal/infra/postgres/repository/*_integration_test.go.
