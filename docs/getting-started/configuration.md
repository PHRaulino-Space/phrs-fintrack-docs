---
sidebar_position: 2
---

# Configuração

A configuração canônica do backend está em backend/README.md, backend/config e backend/.env.sample. As variáveis centrais são DATABASE_URL para PostgreSQL, SECRET_KEY para assinatura/cifra, PORT (padrão 8080) e API_PREFIX (padrão /api). PG_URL e AUTH_SECRET são fallbacks legados, não nomes recomendados. Recursos opcionais (mailer, imagens, embeddings, Open Finance, MCP) exigem configuração própria; não presuma que todos estejam ativos.

O frontend documenta variáveis em frontend/.env.example e frontend/README.md. NEXT_PUBLIC_API_BASE_URL contém a origem pública (por exemplo, http://localhost:8080) e NEXT_PUBLIC_API_PREFIX contém /api/v1. NEXT_PUBLIC_MSW_ENABLED controla o worker de mocks no navegador. NEXT_PUBLIC_APP_TIMEZONE afeta instantes e “hoje”, sem deslocar datas civis. Variáveis NEXT_PUBLIC_* entram no build e não devem conter segredos.

Schema, migração, funções e gatilhos são aplicados explicitamente por backend/cmd/dbsetup, segundo [migrações](../database/migrations.md). Esta página não instrui restaurar um dump histórico nem executou setup em banco.
