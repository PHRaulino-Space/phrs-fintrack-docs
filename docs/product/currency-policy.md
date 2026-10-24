# Moedas: isolamento sem conversão

A política de moeda bloqueia operações entre moedas diferentes enquanto não houver conversão explícita implementada. Não existe cotação implícita, câmbio pelo valor numérico, conversão ao vincular uma entidade nem migração automática do histórico. Uma quantia de USD 100 não representa BRL 100.

## De onde vem a moeda

| Recurso | Moeda usada |
| --- | --- |
| Conta | `currency_code` cadastrado na conta |
| Investimento e seus movimentos | Moeda da conta do investimento |
| Workspace | `default_currency_code` cadastrado no workspace |
| Cartão, meta e orçamento | Moeda padrão do workspace |
| Importação manual ou CSV | Moeda do contexto da sessão: conta, ou workspace quando o alvo é cartão |
| Produto e transação Open Finance | Código explícito informado pelo provedor, comparado com o alvo local |

Contas de moedas diferentes podem coexistir em um workspace. Isso permite consultar uma conta individual na própria moeda; não autoriza somar as contas como se fossem equivalentes. Cartões e metas não possuem uma conversão própria que substitua a moeda do workspace.

A moeda de uma conta e a moeda padrão de um workspace são imutáveis após o cadastro. Alterar apenas o código reinterpretaria saldos iniciais, compras, limites, metas e lançamentos históricos. A API rejeita essa troca; corrigir um cadastro antigo exige uma decisão e um procedimento específicos, não a edição comum do campo.

## Operações monetárias

- **Transferência e transferência recorrente:** origem e destino devem ter a mesma moeda. A regra também se aplica à execução de ocorrências, aos workers e aos caminhos internos que materializam movimentos.
- **Aporte e resgate:** conta da movimentação e conta do investimento devem ter a mesma moeda, além das regras existentes de vínculo. Vincular um investimento não converte seu valor.
- **Pagamento de cartão:** conta pagadora e cartão devem ter a mesma moeda. Como o cartão herda a moeda do workspace, uma conta estrangeira não pode pagar a fatura sem uma operação de conversão explícita.
- **Metas:** investimentos ligados à meta devem usar a moeda do workspace. Dados legados incompatíveis geram erro; não se calcula um progresso somando moedas diferentes.
- **Planejamento e orçamento:** valores e limites pertencem à moeda do workspace. Eles não representam um total convertido de contas estrangeiras.

Código ausente, desconhecido ou recurso sem moeda resolvível impede a operação. A validação não assume BRL para preencher uma origem desconhecida e não troca o código para fazer uma comparação passar. Recursos continuam sujeitos às verificações de workspace e às outras regras de negócio.

## Importações e Open Finance

O vínculo de um produto Open Finance exige moeda conhecida e igual à da conta ou do cartão local. Cada transação recebida também deve informar moeda compatível com o produto e o alvo. A validação do lote acontece antes das gravações de sincronização e é compartilhada por busca manual, sincronização agendada e processamento de webhooks.

A normalização preserva `currency_code` no preparado. Para linhas manuais/CSV novas, o código é obtido do contexto da sessão e gravado no preparado; isso expressa a moeda em que o usuário informou o valor, sem inferir câmbio de texto ou símbolo no CSV. Um CSV que representa outra moeda não deve ser enviado para um contexto incompatível.

A revisão preserva a moeda de origem já registrada, mesmo quando altera categoria, tipo ou outros campos. Staging, revisão, vínculo recorrente e commit verificam as moedas dos recursos monetários envolvidos. Trocar o alvo da sessão também não permite reinterpretar valores em outra moeda. O commit repete a validação antes da materialização do lote selecionado.

Restauração de transação sincronizada verifica novamente a moeda do snapshot e do alvo antes de recriar o preparado. Registro Open Finance legado sem código suficiente é bloqueado; a falta não é suprida pela moeda atual da conta. Essa política não corrige, por si só, outros limites de deduplicação, atomicidade ou autorização descritos em [importações](./imports-open-finance.md).

## Consultas e totais

Dashboard, Superedição e consultas consolidadas de transações devem falhar com erro explícito quando o universo consultado contiver moedas incompatíveis. Não retornam um número obtido somando valores de moedas diferentes nem um zero que esconda a indisponibilidade. A consulta de uma conta individual permanece disponível na moeda dessa conta. A Superedição mantém seus indicadores na moeda do workspace e também bloqueia o filtro por conta estrangeira; para essa conta, use o extrato individual. Os termos monetários da busca incluem a moeda efetiva, sem presumir o símbolo de BRL.

A carteira de investimentos mantém os grupos por moeda. Apresentar BRL e USD em grupos separados não é uma conversão e não cria um total geral entre eles. Patrimônio conserva os indicadores de moeda mista e os valores indisponíveis descritos na [regra de patrimônio](./assets.md).

## Legado e reparação

A implantação desta política não reescreve saldos, não converte lançamentos e não altera automaticamente códigos antigos. Um erro novo em uma consulta ou operação pode revelar uma inconsistência preexistente; não significa que seus números devam ser substituídos por zero.

Antes de uma futura reparação, é necessário decidir a moeda econômica real de cada registro, a origem dos valores e se houve conversão fora do sistema. O plano deve definir quais entidades precisam de novo cadastro, como preservar vínculos e auditoria e como validar os totais por moeda em ambiente descartável. Quando faltarem provas da origem, o dado deve permanecer indisponível para consolidação, com o motivo explícito.

Qualquer migração ou reparação exige escopo e autorização próprios, simulação e conferência por moeda. Não se recomenda executar atualizações em massa para uniformizar códigos, atribuir BRL a códigos ausentes nem editar diretamente o banco para contornar a validação. Não há execução de reparação de dados nesta mudança.

## Implementação e verificação

A política compartilhada está em `backend/internal/usecase/currency_guard.go`, com lookup de recurso/workspace e catálogo em `backend/internal/infra/postgres/repository/currency_guard_postgres.go`. Os usecases monetários recebem a política por `WithCurrencyGuard`; ausência de configuração bloqueia a operação em vez de liberar valores sem validação.

Importações e Open Finance aplicam as verificações em `backend/internal/usecase/import.go`, `import_currency.go` e `openfinance.go`. Testes isolados em `import_currency_test.go` cobrem divergência, ausência de código, preservação da origem, bloqueio antes de gravação e caminhos de commit, vínculo e restauração. Testes de unidade com mocks não comprovam execução concorrente ou migração em PostgreSQL real; não se acessam banco financeiro, credenciais ou provedor real para validar esta regra.

## Recorrências e importações na apresentação

Receitas, despesas e transferências recorrentes são apresentadas na moeda da conta de origem; cartão usa a moeda do workspace. Moeda desconhecida fica indisponível. Seleção com moedas diferentes não recebe total nominal. O resumo recorrente é um consolidado na moeda do workspace e recusa universo com moedas desconhecidas/incompatíveis antes da soma, seguindo a política conservadora do Dashboard. A lista de contratos individuais continua disponível mesmo quando o resumo não pode ser calculado; a UI mostra os totais como indisponíveis e o erro do resumo separadamente.

Em importações de conta, a moeda vem da conta da sessão; em cartão, do workspace. A ausência de metadata não vira BRL. Conciliação, edição, tabela, listagem e diálogo de commit usam esse contexto. Fontes: `RecurringUseCaseImpl.GetRecurringSummary`, `useRecurringTransactions`, `recorrencias-tab.tsx`, `import-currency-context.tsx`.
