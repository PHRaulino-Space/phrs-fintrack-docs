# Contas e cartões

Cadastre contas em **Workspace → Contas** e cartões em **Workspace → Cartões**. Verifique o usuário atribuído, a moeda, o saldo inicial e, para cartões, a conta de pagamento, o limite, o fechamento e o vencimento. Uma compra de cartão forma saldo de fatura; o débito da conta ocorre por pagamento registrado.

A [jornada de contas e cartões](../product/accounts-cards.md) explica saldo atual, status, arquivamento, transferência, competência de compra, parcelas, antecipações, pagamento parcial e efeitos de exclusão com fórmulas e exemplos fictícios. Leia as [lacunas](../product/known-gaps.md) antes de comparar saldo de tela com caixa disponível no planejamento.

Fontes: frontend/src/app/(fintrack)/workspace/accounts e cards; backend/internal/usecase/account.go, card.go e invoice.go.
