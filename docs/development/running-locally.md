# Execução local

O caminho operacional atual está nos READMEs de backend e frontend. O backend usa DATABASE_URL e SECRET_KEY; a aplicação HTTP não aplica migrations/seed no startup. Um operador prepara banco com backend/cmd/dbsetup ou make db-setup após configurar o ambiente. O frontend instala com pnpm install --frozen-lockfile e usa pnpm run dev na porta 7201. A API usa PORT 8080 por padrão.

Para inspeção sem serviços: execute make check no backend e pnpm run check no frontend, dentro de cada repositório. Os testes de integração do backend são alvo separado e requerem Docker/Testcontainers ou DSN de teste. O frontend pode usar MSW com NEXT_PUBLIC_MSW_ENABLED=true, conforme frontend/README.md; isso não testa o banco.

Não há schema canônico em backend/docs/fintrack_schema.sql nem instrução atual para restaurar esse arquivo. Veja [migrações](../database/migrations.md) e [configuração](../getting-started/configuration.md).
