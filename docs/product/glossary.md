# Glossário operacional

| Termo | Significado neste produto |
| --- | --- |
| Workspace | Limite de dados e participação selecionado pelo usuário. A maioria das operações financeiras exige `X-Workspace-ID` válido. |
| Membro | Usuário com papel e acesso ao workspace; diferente do usuário atribuído a uma conta ou cartão. |
| Conta | Origem ou destino de caixa com tipo, moeda e saldo inicial. Conta arquivada preserva histórico. |
| Lançamento | Receita, despesa, transferência, compra de cartão ou movimento relacionado, conforme a consulta. Não equivale sempre a movimento liquidado. |
| Estado pago / pendente / projetado | Distinção entre liquidação registrada, obrigação ainda em aberto e ocorrência calculada. Cada consulta explicita os estados incluídos. |
| Competência | Mês `YYYY-MM` usado em faturas, orçamentos e painéis, distinto do timestamp de criação. |
| Data civil | Dia `YYYY-MM-DD` sem fuso embutido; a UI não deve deslocá-lo ao formatar. |
| Fatura | Agrupamento de compras, ajustes e pagamentos por cartão e mês de cobrança. Fechamento e vencimento têm papéis distintos. |
| Recorrência | Regra que gera ocorrências esperadas; a projeção ainda não é necessariamente um lançamento pago. |
| Reconciliação | Associação de lançamento efetivo a uma ocorrência prevista; não é rateio monetário automático. |
| Sessão de importação | Área temporária para upload, classificação, revisão e confirmação de linhas; staging não compõe o livro financeiro definitivo. |
| Snapshot de investimento | Valor informado para uma data; não é inferido apenas pela soma de depósitos. |
| Meta vinculada | Objetivo cujo progresso consulta investimentos associados. Vínculo não transfere dinheiro. |
| Realizado / projetado | Valores de fontes distintas: estados efetivos e cenários/ocorrências futuras. A definição exata depende da página. |
| Idempotência | Chave de operação usada para evitar duplicação em reenvios de determinadas escritas. Não deve ser presumida em toda rota. |
