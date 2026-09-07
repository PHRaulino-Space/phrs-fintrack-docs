# Plano: paridade de projeções de cartão

## 1. Resumo

Unificar a composição de projeções recorrentes de cartão para que o total e a lista da fatura consumam exatamente o mesmo conjunto de itens. A competência de uma ocorrência recorrente deve ser a fatura do mês seguinte à data de referência. Assim, Duolingo em 23/07/2026 pertence à fatura `2026-08`; e ocorrências do Vivo já materializadas na fatura de agosto não voltam a ser projetadas em julho.

## 2. Contexto e diagnóstico

- [verified] `GetInvoiceTotalAmount` em `internal/usecase/card_transaction.go:375` soma despesas/estornos e depois calcula projeções por uma lógica própria, usando ocorrências cuja data está no próprio `billingMonth`.
- [verified] `listCardInvoiceTransactions` em `internal/controller/http/v1/card.go:486` monta a lista real e injeta projeções separadamente via `RecurringUseCase.ListPendingByContext`, filtrando `ReferenceDate.Format("2006-01") == billingMonth`.
- [verified] A reconciliação em `internal/usecase/reconciliation/reconciliation.go:178` resolve recorrências por contagem FIFO global de vínculos. Isso permite que um vínculo histórico indevido — como o item Shopee ligado ao Duolingo antes de sua primeira competência válida — esconda a projeção da lista, embora o total a calcule.
- [verified/user observation] A tela já trata itens com status `PROJECTED` como visíveis e não selecionáveis; a alteração proposta preserva o formato da resposta para manter esse comportamento.
- [inferred] `billing_month` representa a fatura seguinte à data de ocorrência recorrente: os exemplos fornecidos mostram uma ocorrência de 23/07 entrando em `2026-08`, e a criação automática também abre o próximo mês após o fechamento (`internal/usecase/repo/card_transaction_postgres.go:350-391`).

## 3. Objetivo e critérios de aceite

1. Para qualquer fatura de cartão, o total projetado será igual à soma das linhas exibidas (respeitando estornos e itens ignorados).
2. Uma recorrência anual Duolingo em 23/07/2026 será exibida como `PROJECTED` e entrará somente na fatura `2026-08`, nunca na `2026-07`.
3. A recorrência mensal Vivo que já possui ocorrências materializadas válidas até agosto não será duplicada como projeção na fatura de julho.
4. Um vínculo materializado anterior à primeira competência válida da recorrência não poderá consumir/suprimir uma projeção futura (caso Duolingo/Shopee).
5. A correção já entregue para recorrências finitas totalmente materializadas (Seguro Carro) continuará válida: não haverá cobrança adicional.
6. Itens `PROJECTED` continuarão visíveis por padrão, não selecionáveis e removíveis do total ao usar a opção de ocultá-los no frontend.

## 4. Decisão de desenho

Criar no caso de uso de transações de cartão uma única função privada que produza os itens recorrentes projetados de uma fatura. Ela será a única fonte de verdade para:

- adicionar projeções em `GetInvoiceTotalAmount`;
- preencher uma nova coleção de projeções em `InvoiceTransactions` retornada por `ListInvoiceTransactions`;
- serializar essas projeções na resposta HTTP da fatura, removendo a injeção paralela pelo controlador/reconciliação.

Para cada slot gerado, calcular a competência com `slot.AddDate(0, 1, 0).Format("2006-01")`. Ao determinar os slots já resolvidos, considerar somente despesas vinculadas, não ignoradas, cuja `billing_month` seja igual ou posterior à primeira competência possível da recorrência. Consumir os slots em ordem FIFO a partir desse conjunto válido. Isso preserva os vínculos adiantados/atrasados legítimos do Vivo, mas descarta o vínculo Shopee de `2026-04` para uma recorrência cuja primeira competência é `2026-08`.

## 5. Escopo de implementação

### Passo 1 — modelo e cálculo compartilhado

**Arquivos:**

- `internal/usecase/card_transaction.go`
- `internal/usecase/interfaces.go` (somente se a forma pública de `InvoiceTransactions` exigir ajuste de contrato)

**Mudanças:**

1. Adicionar uma representação interna/de resposta para uma despesa recorrente projetada, contendo identidade estável da recorrência, data do slot, descrição, valor, categoria/subcategoria e status `PROJECTED`.
2. Extrair um helper de projeção da fatura que:
   - carregue recorrências ativas e as despesas vinculadas necessárias;
   - gere slots até o último dia anterior à fatura solicitada;
   - traduza slot para competência da fatura seguinte;
   - valide o conjunto materializado contra a primeira competência elegível;
   - aplique o consumo FIFO somente a vínculos válidos;
   - devolva apenas slots pendentes cuja competência seja a `billingMonth` solicitada;
   - preserve o bloqueio de recorrências finitas totalmente materializadas já introduzido para Seguro Carro.
3. Fazer `GetInvoiceTotalAmount` somar o resultado desse helper em vez de manter uma segunda regra de contagem por mês.
4. Fazer `ListInvoiceTransactions` retornar essas mesmas projeções junto das despesas, estornos, pagamentos e parcelas.

**Símbolos alvo:** `CardTransactionUseCaseImpl.ListInvoiceTransactions`, `CardTransactionUseCaseImpl.GetInvoiceTotalAmount`, `InvoiceTransactions`.

### Passo 2 — resposta HTTP única

**Arquivo:** `internal/controller/http/v1/card.go`

**Mudanças:**

1. Converter a coleção projetada retornada pelo caso de uso em `invoiceTransactionResponse` com `type: CARD_EXPENSE`, `transaction_status: PROJECTED`, data de referência e IDs de categoria/recorrência.
2. Inseri-la na mesma ordenação das demais linhas da fatura.
3. Remover a chamada direta a `r.recurring.ListPendingByContext` e o filtro por mês de calendário do controlador, eliminando a divergência entre total e lista.
4. Manter sem mudanças o formato que o frontend já consome; confirmar que o ID de uma linha projetada seja estável no resultado para não gerar chave duplicada quando houver mais de um slot da mesma recorrência.

**Símbolo alvo:** `cardRoutes.listCardInvoiceTransactions`.

### Passo 3 — testes de regressão

**Arquivos:**

- `internal/usecase/card_transaction_test.go`
- `internal/controller/http/v1/card_invoice_response_test.go` ou um novo teste de rota de cartão, conforme as fixtures existentes

**Casos:**

1. Duolingo anual iniciado em 23/07/2026: ausente da fatura de julho; uma linha projetada e o valor correspondente na fatura de agosto.
2. Vínculo de despesa anterior à primeira competência prevista: não reduz os slots pendentes do Duolingo.
3. Vivo mensal com vínculos válidos suficientes, inclusive lançamentos na fatura de agosto: não é reprojetado em julho.
4. Seguro Carro finito com todos os slots materializados antecipadamente: não volta a compor nenhum total projetado.
5. Para a mesma fixture, o total é `despesas - estornos + soma(projeções)` e cada projeção retornada por `ListInvoiceTransactions` aparece na resposta HTTP com `PROJECTED`.
6. A resposta mantém o contrato já usado pelo frontend; validar visualmente que a projeção continue desmarcada no selecionar-todos.

## 6. Riscos e mitigação

- [graph] `GetInvoiceTotalAmount` tem quatro consumidores diretos identificados e impacto classificado como alto; eles incluem a consulta individual/listagem de faturas e resumos em `internal/controller/http/v1/card.go` e `transactions.go`. Reusar o helper reduz derivações, mas exige testar total e lista.
- [verified] A análise estática aponta uma fronteira de despacho por interface e um chamador sem tipo resolvido; portanto, a cobertura de impacto é um limite inferior. Executar a suíte relevante e uma verificação manual das telas de cartões e dos resumos após a alteração.
- [assumed] A regra "mês seguinte" é a semântica desejada para competência da fatura de recorrências de cartão. Confirmar com um exemplo de lançamento em/ao redor do fechamento caso exista exceção por emissora; o caso de usuário e os dados fornecidos sustentam a regra atual.
- Não persistir novos `card_expenses` para projeções: são itens derivados de leitura. Isso evita duplicação e mantém a ação de pagar/importar como responsável por materializar a transação real.

## 7. Fora de escopo

- Correção retroativa do vínculo histórico indevido Shopee → Duolingo; a mudança impede que ele afete projeções, mas não altera dados do usuário.
- Alterar o fluxo de importação ou materialização de despesas reais.
- Mudar o comportamento de seleção/edição de itens projetados no frontend, que já os trata como não selecionáveis.

## 8. Ordem de execução

1. Implementar e cobrir o helper compartilhado no caso de uso.
2. Migrar total e lista para ele.
3. Simplificar o controlador para apenas serializar o resultado do caso de uso.
4. Executar testes unitários e de rota; corrigir mocks/interfaces somente no escopo da mudança.
5. Conferir a tela de julho/agosto do cartão informado, incluindo seleção e o filtro de projeções.

## 9. Comandos de verificação

```bash
go test ./internal/usecase ./internal/controller/http/v1
go test ./...
```

Se a suíte Go completa continuar falhando por erros já existentes fora deste escopo, registrar a saída e validar ao menos os pacotes tocados após sanar as dependências de mock necessárias.

## 10. Evidências de comportamento

- [verified/user data] Em maio de 2026, `18.898,33 - 18.558,45 = 339,88`, correspondente ao Seguro Carro já integralmente materializado. A proteção de recorrência finita resolve esse caso.
- [verified/user data] Em julho de 2026, a diferença de `312,90` equivale a Duolingo (`269,90`) + Vivo (`43,00`).
- [verified/user data] Duolingo começa em 23/07/2026, mas há um vínculo de despesa Shopee em `2026-04`; Vivo tem despesas vinculadas em sequência até a fatura de agosto, com duas em agosto.

## 11. Context pack

```yaml
goal: "Unificar projeções recorrentes de cartão entre total e lista e atribuí-las à fatura seguinte"
scope:
  backend:
    - internal/usecase/card_transaction.go
    - internal/controller/http/v1/card.go
    - internal/usecase/card_transaction_test.go
    - internal/controller/http/v1/card_invoice_response_test.go
key_symbols:
  - CardTransactionUseCaseImpl.GetInvoiceTotalAmount
  - CardTransactionUseCaseImpl.ListInvoiceTransactions
  - cardRoutes.listCardInvoiceTransactions
  - ReconciliationUseCaseImpl.ListPendingByContext
contracts:
  - "GET /cards/:id/invoices/:billing_month returns total_amount"
  - "GET /cards/:id/invoices/:billing_month/transactions returns invoiceTransactionResponse[]"
invariants:
  - "total = real expenses - real chargebacks + same projected expenses returned in list"
  - "Projected card recurring slot belongs to the following billing month"
  - "Ignored and pre-eligibility linked expenses do not suppress a valid projection"
evidence_provenance: |-
  {
    "schema_version": 2,
    "head_commit": "b14f3eaba2b9339457c30b2a49e0646b175588af",
    "generated_plan_path": "docs/plans/2026-09-06-gitnexus-plan-card-projection-parity.md",
    "global_dirty_digest": {
      "algorithm": "sha256",
      "canonicalization": "gitnexus-evidence-provenance-v2 NUL-framed UTF-8 records",
      "value": "7e94564856e5d678f9d689f6ddb2ff33c768b4b6b9aa043fa798ce20bcd9a2b1"
    },
    "cited_path_manifest": [
      {
        "path": "internal/controller/http/v1/card.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "clean",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:76625e2021c478b006670b209f476ae053f6fa8e9da198c79248ecb85c19a93e",
        "index_digest": "sha256:76625e2021c478b006670b209f476ae053f6fa8e9da198c79248ecb85c19a93e",
        "worktree_digest": "sha256:76625e2021c478b006670b209f476ae053f6fa8e9da198c79248ecb85c19a93e",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/controller/http/v1/card_invoice_response_test.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "clean",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:e8f530730bda55e3abf93b1af3646134f90989c575f8b7ec7d8fb7d7ef0b7ea9",
        "index_digest": "sha256:e8f530730bda55e3abf93b1af3646134f90989c575f8b7ec7d8fb7d7ef0b7ea9",
        "worktree_digest": "sha256:e8f530730bda55e3abf93b1af3646134f90989c575f8b7ec7d8fb7d7ef0b7ea9",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/controller/http/v1/transactions.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "unstaged",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:5065078dcb02b53fadce2ed545a7ed5ccad116f363f8b1d26cf077cf56781028",
        "index_digest": "sha256:5065078dcb02b53fadce2ed545a7ed5ccad116f363f8b1d26cf077cf56781028",
        "worktree_digest": "sha256:e423af194441ea4df7e366cecec498d573b5b51802390ca68583a56b69d7c204",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/entity/card.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "clean",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:386ea244bcecc3ba1d56297101831a72c4530ba9d0c26d0e5486c98fd73622e6",
        "index_digest": "sha256:386ea244bcecc3ba1d56297101831a72c4530ba9d0c26d0e5486c98fd73622e6",
        "worktree_digest": "sha256:386ea244bcecc3ba1d56297101831a72c4530ba9d0c26d0e5486c98fd73622e6",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/usecase/card_transaction.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "unstaged",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:399b545e09a2668406f564ca0df19982b18a89a43b351a133fbba80e7133108b",
        "index_digest": "sha256:399b545e09a2668406f564ca0df19982b18a89a43b351a133fbba80e7133108b",
        "worktree_digest": "sha256:b0da6123c03bb3a0eb3678ae57995aa7c56ce479d90fdbaf867a7d3db3ed69f1",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/usecase/card_transaction_test.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "unstaged",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:78490a13a1b931a7e1bd133d03b974f4926e1f4b23c1c8c6ed8ae02ac6eeba3a",
        "index_digest": "sha256:78490a13a1b931a7e1bd133d03b974f4926e1f4b23c1c8c6ed8ae02ac6eeba3a",
        "worktree_digest": "sha256:9da4458dbed8ad6287893e26a9d0fb72e651c87e7b922348a439ad81a1f02cbd",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/usecase/interfaces.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "unstaged",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:fc4d05bbeb16877f5693bf38b5acc5c006b415328e4cf0d947a2cd7d7cb2eed5",
        "index_digest": "sha256:fc4d05bbeb16877f5693bf38b5acc5c006b415328e4cf0d947a2cd7d7cb2eed5",
        "worktree_digest": "sha256:01b9d47cc1bb784261a6389fe8db6fefde36c8e9b9e5e463b0ee07de9206888f",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/usecase/reconciliation/projection.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "clean",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:5ee44792b1968c4310236480352139693c007315896eb9d11bbdc58b082c8ff2",
        "index_digest": "sha256:5ee44792b1968c4310236480352139693c007315896eb9d11bbdc58b082c8ff2",
        "worktree_digest": "sha256:5ee44792b1968c4310236480352139693c007315896eb9d11bbdc58b082c8ff2",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/usecase/reconciliation/reconciliation.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "clean",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:1fb7462ea5afaa90387d8822b3cfd9f856460ee87ac4e7e93e310d3672d4e310",
        "index_digest": "sha256:1fb7462ea5afaa90387d8822b3cfd9f856460ee87ac4e7e93e310d3672d4e310",
        "worktree_digest": "sha256:1fb7462ea5afaa90387d8822b3cfd9f856460ee87ac4e7e93e310d3672d4e310",
        "untracked_digest": "absent"
      },
      {
        "path": "internal/usecase/repo/card_transaction_postgres.go",
        "object_kind": {
          "head": "regular",
          "index": "regular",
          "worktree": "regular",
          "untracked": "absent"
        },
        "state": "clean",
        "rename_from": null,
        "rename_to": null,
        "head_digest": "sha256:b3b7d6e24118410eb3571dc707dc98608edb9a665fc8af5c6de9827c7efd5a96",
        "index_digest": "sha256:b3b7d6e24118410eb3571dc707dc98608edb9a665fc8af5c6de9827c7efd5a96",
        "worktree_digest": "sha256:b3b7d6e24118410eb3571dc707dc98608edb9a665fc8af5c6de9827c7efd5a96",
        "untracked_digest": "absent"
      }
    ]
  }
```

## 12. Handoff checklist

- [ ] Preserve existing dirty worktree changes unrelated to this plan.
- [ ] Re-index/inspect impact immediately before editing because the current index covers only the backend and has interface-dispatch boundaries.
- [ ] Implement one projection source of truth before changing HTTP serialization.
- [ ] Test July/August Duolingo and Vivo, then re-test finite Seguro Carro.
- [ ] Verify frontend select-all and the hide-projected total after receiving the backend response.

## 13. Open implementation note

The invalid historical relation remains observable data, but it must not satisfy a slot that predates the first invoice eligibility of its recurrence. The implementation should document this eligibility guard next to the FIFO matching rule so a future reconciliation refactor does not reintroduce the mismatch.
