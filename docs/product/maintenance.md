# Manutenção da documentação e contexto futuro

## Fonte de verdade e checkout

Este site Docusaurus é o repositório `phrs-fintrack-docs`, incluído como submódulo tanto em `backend/docs` quanto em `frontend/docs`. Nesta revisão a árvore editada é **`backend/docs`**. No início, ambas apontavam ao commit `e3f78176a5ad8dfc355e28d659e415bf6af62060`, sem alterações locais, mas são diretórios de trabalho diferentes. Um commit posterior no submódulo não atualiza automaticamente o checkout irmão nem deve ser confundido com alteração de código em um dos pais. O autor decidirá quando registrar o commit do docs e, se desejar, os ponteiros nos projetos pais.

Os checkpoints de leitura do aplicativo são backend `cc862284112cd171e145895b2fb83fa576e5befc` e frontend `fbb75d06862c324b5e5a0fc2076498d634c6e627`. Antes de editar de novo, leia `AGENTS.md` dos projetos e verifique `git status` dos três repositórios, sem descartar arquivos dirty ou untracked.

## Sequência de atualização

1. Faça inventário do que mudou: `frontend/src/app/**/page.tsx`, `frontend/src/components/layout/data/sidebar-data.tsx`, hooks, serviços, handlers registrados em `backend/internal/controller/http/v1/router.go`, casos de uso, repositórios, entidades, setup SQL e testes. Use `rg` para encontrar símbolos e trate relatórios históricos como contexto, não contrato.
2. Siga uma jornada completa: entrada da UI → cliente HTTP → middleware/handler → caso de uso → persistência → resposta → representação na tela e efeito em outros módulos. Distinga chamadas existentes de ações visíveis para o usuário.
3. Para cada cálculo, anote fórmula, fonte de dados, status incluídos e excluídos, período e data civil, moeda, precisão/arredondamento, hipóteses e um exemplo com dados **fictícios** verificado contra código ou teste. Se a UI reformatar ou filtrar o resultado do backend, registre os dois comportamentos.
4. Atualize a [matriz](./coverage.md), a página do domínio e as [lacunas](./known-gaps.md). Nunca apresente uma intenção de roadmap como funcionalidade entregue, nem silencie uma divergência frontend/backend. Use caminho e símbolo como evidência; linha isolada é frágil.
5. Preserve `docs/api-simple` e `static/openapi.json` quando a mudança for apenas textual. Ao mudar rota/anotação no backend, siga o processo `make swagger` descrito em `backend/AGENTS.md` em uma tarefa de código própria. Não regere OpenAPI apenas para revisar texto.
6. Execute o build Docusaurus (`npm ci` se as dependências estiverem ausentes, depois `npm run build`), confira links relativos e a navegação, e revise as páginas antigas do guia. O build detecta links que quebram a compilação, mas não prova que uma fórmula está correta.

O build gera `build/` local ignorado. Este repositório também contém HTML e assets estáticos versionados na raiz e em `en/` de uma publicação anterior; eles não são fonte editorial e **não** foram substituídos nesta revisão, que não publicou o site. Planeje a atualização desses artefatos pelo fluxo de publicação quando autorizada.

## Como escrever para usuários e desenvolvedores

Comece pelo resultado visível e pelas pré-condições. Descreva quais valores entram, a validação, a mudança de estado, o resultado, o erro e a possibilidade de tentar de novo. Em seguida, exponha a origem técnica em uma tabela curta. Para números, deixe claro se são dinheiro registrado, saldo estimado, projeção ou simulação. Não copie payloads, SQL ou arquivos extensos para a página; o nome de uma função e seu teste já permitem reencontrar a regra no futuro.

Datas `YYYY-MM-DD` são dias civis. A UI usa `frontend/src/lib/date-utils.ts` e `timezone.ts`; o `APP_TIMEZONE` configurado serve para instantes e para descobrir “hoje”, não para deslocar uma data civil. Valores em moedas diferentes só podem ser somados quando a operação efetivamente aplica uma taxa documentada. Salvar uma moeda na entidade não constitui conversão.

Use apenas dados sintéticos em exemplos, sem emails, IDs, nomes de instituição real, saldos ou tokens de usuários. Se um teste usa fixture realista, substitua-a por exemplo inventado. O site documenta a implementação e seus limites, não estabelece garantia fiscal, investimento ou conciliação bancária.
