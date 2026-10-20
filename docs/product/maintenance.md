# Manutenção da documentação e contexto futuro

## Fonte de verdade e checkout

Este site Docusaurus é o repositório `phrs-fintrack-docs`, incluído como submódulo tanto em `backend/docs` quanto em `frontend/docs`. A árvore canônica de edição é **`backend/docs`**; as fontes alteradas são espelhadas em `frontend/docs`. Ambos começaram em `9e35dbed4f5aa056d317d6a6697beeadc38a7c3c` na revisão de 20/10/2026. São checkouts separados: um commit de docs não atualiza automaticamente o irmão nem os ponteiros dos repositórios pais. Sem commit solicitado, as mudanças permanecem locais.

Bases de aplicativo: backend `8e68227cc642bb60e90db5dba313000e7f45e798` e frontend `bd33f1c8a6e2de962d1bb1d9f2248fcc97bc46f4`, com refatorações locais posteriores. Antes de editar, leia AGENTS e confira Git em cada árvore, preservando alterações existentes. Resultado transitório de check pertence a revisão/histórico, não ao contrato vivo.

## Sequência de atualização

1. Faça inventário do que mudou: `frontend/src/app/**/page.tsx`, `frontend/src/components/layout/data/sidebar-data.tsx`, hooks, serviços, handlers registrados em `backend/internal/controller/http/v1/router.go`, casos de uso, repositórios, entidades, setup SQL e testes. Use `rg` para encontrar símbolos e trate relatórios históricos como contexto, não contrato.
2. Siga uma jornada completa: entrada da UI → cliente HTTP → middleware/handler → caso de uso → persistência → resposta → representação na tela e efeito em outros módulos. Distinga chamadas existentes de ações visíveis para o usuário.
3. Para cada cálculo, anote fórmula, fonte de dados, status incluídos e excluídos, período e data civil, moeda, precisão/arredondamento, hipóteses e um exemplo com dados **fictícios** verificado contra código ou teste. Se a UI reformatar ou filtrar o resultado do backend, registre os dois comportamentos.
4. Atualize a [matriz](./coverage.md), a página do domínio e as [lacunas](./known-gaps.md). Nunca apresente uma intenção de roadmap como funcionalidade entregue, nem silencie uma divergência frontend/backend. Use caminho e símbolo como evidência; linha isolada é frágil.
5. Preserve `docs/api-simple` e `static/openapi.json` quando a mudança for apenas textual. Ao mudar rota/anotação no backend, siga `make swagger` conforme `backend/AGENTS.md`: gere `openapi`, sincronize `docs/static/openapi.json` e `docs/openapi.json`, rode `scripts/generate-openapi-md.js`, espelhe as mesmas fontes no checkout irmão e execute o teste de drift. Não regere OpenAPI apenas para revisar texto.
6. Execute o build Docusaurus (`node_modules/.bin/docusaurus build` com dependências já disponíveis; se ausentes e instalação estiver restrita, registre o bloqueio), confira links relativos e a navegação, e revise as páginas antigas do guia. O build detecta links que quebram a compilação, mas não prova que uma fórmula está correta.

O build gera `build/` local ignorado. Este repositório também contém HTML e assets estáticos versionados na raiz e em `en/` de uma publicação anterior; eles não são fonte editorial e **não** foram substituídos nesta revisão, que não publicou o site. Planeje a atualização desses artefatos pelo fluxo de publicação quando autorizada.

## Como escrever para usuários e desenvolvedores

Comece pelo resultado visível e pelas pré-condições. Descreva quais valores entram, a validação, a mudança de estado, o resultado, o erro e a possibilidade de tentar de novo. Em seguida, exponha a origem técnica em uma tabela curta. Para números, deixe claro se são dinheiro registrado, saldo estimado, projeção ou simulação. Não copie payloads, SQL ou arquivos extensos para a página; o nome de uma função e seu teste já permitem reencontrar a regra no futuro.

Datas `YYYY-MM-DD` são dias civis. A UI usa `frontend/src/lib/date-utils.ts` e `timezone.ts`; o `APP_TIMEZONE` configurado serve para instantes e para descobrir “hoje”, não para deslocar uma data civil. Valores em moedas diferentes só podem ser somados quando a operação efetivamente aplica uma taxa documentada. Salvar uma moeda na entidade não constitui conversão.

Use apenas dados sintéticos em exemplos, sem emails, IDs, nomes de instituição real, saldos ou tokens de usuários. Se um teste usa fixture realista, substitua-a por exemplo inventado. O site documenta a implementação e seus limites, não estabelece garantia fiscal, investimento ou conciliação bancária.
