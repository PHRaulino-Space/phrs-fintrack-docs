# Integração contínua

Backend e frontend têm workflows em seus próprios diretórios .github/workflows/check.yml. Eles são a fonte atual de jobs e versões usadas; não há um pipeline único dedutível deste site. O backend documenta make check e testes de integração separados; o frontend documenta pnpm run check e sua suíte Playwright. O site docs usa npm run build para validar geração Docusaurus e links.

Ao alterar um contrato financeiro, atualize testes e a [matriz de cobertura](../product/coverage.md). Ao mudar rota ou anotação Swagger, siga backend/AGENTS.md para regenerar OpenAPI em tarefa de código. Esta revisão de texto preservou os artefatos gerados.
