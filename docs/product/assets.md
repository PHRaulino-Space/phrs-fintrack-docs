---
title: Patrimônio
description: Bens, gastos classificados e histórico de avaliação.
---

# Patrimônio

O menu **Patrimônio** (`/assets`) acompanha bens sem criar lançamentos. Ao cadastrar um bem, o sistema cria na mesma transação uma tag nova, com o nome do bem e no mesmo workspace. A tag é vinculada exclusivamente àquele bem. Cada meta também cria e vincula sua própria tag; tags criadas avulsas podem ficar sem vínculo com bem ou meta. Uma tag gerenciada não pode ser editada ou excluída isoladamente. A mesma despesa pode ter simultaneamente a tag de uma meta e a tag de um bem: ela aparece nos dois acompanhamentos e continua sendo um único lançamento financeiro.

Bens criados pelo contrato anterior preservam sua tag existente. A migração não troca suas tags automaticamente, pois isso poderia alterar classificações de transações já registradas. Se um bem antigo tiver sido vinculado à tag de uma meta, esse vínculo legado precisa ser revisto antes de renomear o bem; o fluxo novo não cria esse compartilhamento.

## Gastos e finalidade

- A lista do bem reúne despesas de conta (`expenses`) e compras de cartão (`card_expenses`) com sua tag. Transferências, pagamentos de fatura, aportes, resgates e avaliações não entram. Cada lançamento aparece uma vez, mesmo que tenha outras tags.
- `IGNORE`, `PROJECTED` e lançamentos excluídos logicamente ficam fora dos totais. `VALIDATING`, `PENDING` e `PAID` entram. Edição do valor, da data, do status ou das tags reflete na próxima leitura. Exclusão ou retirada da tag retira o gasto; restaurá-lo ou reanexar a tag o inclui novamente.
- A finalidade padrão é **aquisição sem detalhe**. Há dois grupos locais ao bem: **Aquisição** (Entrada, Amortização extraordinária e Parcela de financiamento) e **Custos e melhorias** (Manutenção e reparos, Despesas fixas, Impostos e taxas e Melhorias e reformas). Os códigos anteriores `ACQUISITION` e `MAINTENANCE` continuam legíveis e selecionáveis sem inventar subcategorias para gastos antigos. Os dois subtotais somam o **total gasto**. Uma compra de cartão conta na compra, não novamente no pagamento da fatura.
- Na tabela, **Finalidade** mostra o grupo e **Detalhamento** mostra a subcategoria. A edição usa dois campos dependentes: mudar o grupo deixa um rascunho sem detalhe, e nada é gravado até escolher uma opção compatível e clicar **Salvar**. **Cancelar** restaura a classificação anterior. A opção **Sem detalhamento (legado)** aparece apenas quando aquele lançamento já possui o código antigo do mesmo grupo; ela não é atribuída automaticamente em uma mudança de grupo. O código `purpose` da API continua único e local ao bem.
- Como a tag é criada junto do bem, a avaliação inicial na data de aquisição informada começa em zero. Em **Editar bem**, o usuário pode corrigir a data e o valor dessa avaliação inicial; é uma correção do mesmo registro histórico, sem inserir outra avaliação. Despesas marcadas com a nova tag depois do cadastro passam a compor os subtotais atuais, mas não reescrevem a fotografia inicial. O usuário pode registrar avaliações posteriores separadamente.
- Uma avaliação é um valor estimado de venda datado, sem transação financeira. O histórico é ordenado pela data. Renomear o bem renomeia sua tag na mesma transação. Excluir o bem elimina apenas seu cadastro, classificações e avaliações; os lançamentos e a tag continuam, e a tag fica avulsa.
- Um estorno de cartão é atualmente um registro independente sem vínculo seguro com uma compra específica. Portanto, ele não reduz automaticamente o subtotal do bem. Para corrigir um gasto atribuído, ajuste ou exclua a compra original, ou retire sua tag. Nenhuma associação de estorno é presumida por texto/valor/data.

## Acompanhamento opcional de financiamento

O financiamento pode ser ativado ou desativado por bem, com configuração incompleta. Ele guarda apenas metadados do Patrimônio: principal originalmente financiado, data civil de referência desse principal, amortização padrão opcional por parcela e taxa contratual opcional com periodicidade e tipo. A taxa fica para consulta e **não** alimenta um simulador SAC/Price ou correções por indexador. A entrada não é subtraída novamente do principal originalmente financiado. Nenhum desses campos lança dinheiro, altera a compra original ou ajusta automaticamente o valor estimado de venda.

Somente gastos classificados **Parcela de financiamento** entram na lista de parcelas. A lista exibe o valor e o status originais do lançamento. O indicador **Parcelas pagas** e a redução do principal consideram apenas lançamentos `PAID`; `PENDING` e `VALIDATING` aparecem como pendentes/validação, sem reduzir o principal até a mudança de status. Em cada parcela, a amortização e os encargos conhecidos podem ser informados; ambos somados não podem exceder o valor do lançamento. Se não houver amortização informada, a amortização padrão, quando configurada, é usada **como estimativa** limitada ao valor da parcela. O residual é exibido como **juros/encargos**; quando amortização e encargos são conhecidos, a diferença é exibida como juros calculados por diferença (estimados se a amortização veio do padrão). Sem amortização, o residual fica indeterminado. Amortizações extraordinárias classificadas e pagas reduzem o principal; entrada, manutenção, impostos e melhorias não reduzem esse principal.

O indicador de principal restante só aparece com principal original **e** data de referência. Ele subtrai amortizações informadas e extraordinárias posteriores ou iguais à referência; é um valor indicativo, não o saldo bancário exato. A projeção separada subtrai também amortizações padrão estimadas. Gastos anteriores à referência são sinalizados e excluídos do cálculo do restante. Caso as amortizações superem o principal, o restante é mostrado como zero com o excesso destacado, para revisão das premissas. Contratos indexados, seguros, tarifas e correções futuras podem divergir: o sistema não finge conhecer esses valores.

Edição de valor/data/status/tag de uma despesa se reflete na próxima leitura. Uma parcela excluída, ignorada, projetada ou destaggeada sai da lista e do cálculo. A classificação local e decomposição ficam guardadas por ID do lançamento para eventual restauração/revinculação; reclassificar para outra finalidade limpa a decomposição da parcela. Se a edição reduzir o valor pago abaixo da amortização/encargos antes informados, o cálculo sinaliza a decomposição inválida e não a usa até ser corrigida. Desativar o financiamento apenas oculta seus indicadores, preservando as finalidades e a configuração para reativação.

## API e isolamento

Todas as rotas exigem autenticação, MFA, `X-Workspace-ID` autorizado e CSRF em mutações por cookie. IDs de bens de outro workspace retornam 404. A criação grava tag, bem e avaliação inicial atomicamente; a classificação de lançamento verifica o workspace da conta ou cartão de origem e o vínculo com a tag do bem.

| Método | Rota | Função |
| --- | --- | --- |
| `GET` | `/assets` | Lista bens com subtotais, lançamentos e avaliações |
| `POST` | `/assets` | Cria bem e tag exclusiva: `name` (até 100 caracteres), `kind`, `acquisition_date` (`YYYY-MM-DD`); `tag_id` vem apenas na resposta |
| `GET` | `/assets/{id}` | Detalhe |
| `PATCH` | `/assets/{id}` | Edita `name` e `kind`; opcionalmente corrige `acquisition_date` (`YYYY-MM-DD`) e `initial_value` (não negativo) no registro inicial. A tag acompanha o nome e mantém seu ID. Avaliações posteriores e gastos permanecem intactos. |
| `DELETE` | `/assets/{id}` | Remove apenas metadados do bem |
| `POST` | `/assets/{id}/valuations` | Adiciona `{date, value}` com valor não negativo |
| `PUT` | `/assets/{id}/expenses/{kind}/{source_id}/purpose` | Define uma das finalidades locais; `kind` é `expense` ou `card_expense` |
| `PUT` | `/assets/{id}/financing` | Substitui a configuração opcional `{enabled, original_principal, reference_date, default_principal, rate_percent, rate_period, rate_type}`; campos opcionais ausentes são limpos |
| `PUT` | `/assets/{id}/expenses/{kind}/{source_id}/payment` | Define ou limpa `{principal_amount, fees_amount}` de uma parcela classificada |

`GET` retorna `acquisition`, `maintenance` (grupo Custos e melhorias, nome de campo legado), `total`, `purpose_totals`, `expenses[]`, `valuations[]`, `financing` e `financing_summary`. Cada despesa informa `transaction_status`; a soma `pending_amount` é separada de `paid`. Cada parcela pode ter `breakdown` com origem `INFORMED`, `DEFAULT_ESTIMATE`, `UNSPECIFIED` ou `INVALID`. As somas monetárias são arredondadas em centavos; despesas não são duplicadas ao decompor principal, juros e encargos. A ordenação e a paginação da tabela de lançamentos são locais na interface. A API não altera as transações durante leitura, classificação, avaliação ou acompanhamento.

**Ativação:** aplicar a migration pelo procedimento normal do backend (`go run cmd/dbsetup/main.go -migrate`) depois de revisar o esquema. Não executar no banco do usuário durante desenvolvimento.
