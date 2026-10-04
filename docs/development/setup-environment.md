# Ambiente de desenvolvimento

Leia backend/README.md, frontend/README.md e seus AGENTS.md antes de executar comandos. Backend usa Go 1.25.6 neste checkpoint e frontend usa Node.js >=20.9 com pnpm 10.x. Os dois projetos têm checks sem segredos; banco/Docker são necessários somente para operação integrada ou testes de integração. O site docs usa Docusaurus 3 com package-lock.json próprio.

Comece por [instalação](../getting-started/installation.md), [configuração](../getting-started/configuration.md) e [estratégia de testes](./testing-strategy.md). Não misture o ponteiro de docs de um projeto com commits do outro: são checkouts separados do mesmo repositório de documentação.

Fontes: backend/go.mod, backend/Makefile, frontend/package.json, frontend/pnpm-lock.yaml e package.json deste site.
