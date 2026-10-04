# Integração HTTP no frontend

Use a instância existente em frontend/src/lib/api.ts. Ela monta a origem e o prefixo público, envia cookies, acrescenta CSRF a mutações e fixa o X-Workspace-ID da requisição. Em 401, o refresh é coordenado entre abas; retries transitórios seguem as condições de segurança de frontend/src/lib/api-retry.ts. Não crie um Axios paralelo nos componentes.

Serviços em frontend/src/services encapsulam chamadas por domínio; hooks em frontend/src/hooks fornecem os dados e atualização às páginas. Para uma nova operação, siga um serviço existente do mesmo domínio e verifique os testes de MSW. Consulte o [mapa técnico](../product/domain-map.md) e a [jornada de acesso](../product/access-categories-tools.md).

Fontes: frontend/src/lib/api.ts, frontend/src/lib/api-retry.ts, frontend/src/services/transactions.ts e frontend/src/hooks/use-transaction-queries.ts.
