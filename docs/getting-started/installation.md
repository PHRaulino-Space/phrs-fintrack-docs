---
sidebar_position: 1
---

# Instalação para desenvolvimento

Backend e frontend são repositórios independentes neste checkout. Antes de instalar, leia backend/README.md, frontend/README.md e os respectivos AGENTS.md; eles contêm a configuração vigente. O site de documentação é submódulo dos dois projetos.

Pré-requisitos atuais: Go conforme backend/go.mod (1.25.6 neste checkpoint), Node.js >=20.9, pnpm 10.x, PostgreSQL para execução integrada e Docker quando usar Compose ou testes de integração com Testcontainers. O frontend fixa pnpm no package.json e usa pnpm-lock.yaml.

Para conferir código sem serviços, use make check dentro de backend e pnpm install --frozen-lockfile seguido de pnpm run check dentro de frontend. Para executar a aplicação, copie apenas os arquivos de exemplo correspondentes, configure DATABASE_URL e SECRET_KEY no backend, as variáveis NEXT_PUBLIC_API_BASE_URL e NEXT_PUBLIC_API_PREFIX no frontend, e siga os README. O setup de banco é operação explícita via backend/cmd/dbsetup ou make db-setup; não use dump SQL antigo como fonte de schema.

O frontend em desenvolvimento usa a porta 7201 e a API usa 8080 por padrão. O site Docusaurus tem instalação separada com npm ci e npm run build. Veja [configuração](./configuration.md) e [setup de schema](../database/migrations.md).
