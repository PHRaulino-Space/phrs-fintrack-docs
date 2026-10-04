# Operação própria

FinTrack pode ser executado em infraestrutura administrada pelo operador. Use backend/README.md, frontend/README.md e os arquivos de Compose do workspace para portas, variáveis, dependências e passos atuais; este site não mantém uma receita de produção paralela. O frontend incorpora NEXT_PUBLIC_* no build. O backend exige DATABASE_URL e SECRET_KEY. Integrações de Open Finance, embeddings, email, imagens e MCP são configuradas separadamente.

O schema deve ser preparado por backend/cmd/dbsetup em procedimento operacional controlado; não é aplicado no startup. Verifique o [setup de dados](../database/migrations.md) e a [configuração](../getting-started/configuration.md). Esta revisão não executou deploy, migração ou restart.
