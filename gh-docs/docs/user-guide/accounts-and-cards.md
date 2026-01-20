# Contas e Cartões

Para começar a registrar transações, você precisa configurar onde o dinheiro está (Contas) e como você gasta (Cartões).

## Contas (Accounts)

Representam qualquer lugar onde há saldo financeiro.

### Tipos de Conta
- **Conta Corrente (Checking)**: Contas bancárias tradicionais.
- **Carteira (Wallet)**: Dinheiro em espécie.
- **Investimentos**: Corretoras.
- **Poupança**: Reservas financeiras.

### Como Cadastrar
1.  Vá para **Configurações > Contas**.
2.  Clique em "Nova Conta".
3.  Preencha:
    - **Nome**: Ex: "Nubank", "Itaú".
    - **Tipo**: Selecione na lista.
    - **Saldo Inicial**: O valor que existe na conta hoje. Isso servirá de base para o cálculo de saldo futuro.

## Cartões de Crédito (Cards)

Cartões têm um comportamento diferente pois geram uma fatura (Invoice) e possuem datas de corte.

### Como Cadastrar
1.  Vá para **Configurações > Cartões**.
2.  Clique em "Novo Cartão".
3.  Preencha:
    - **Nome**: Ex: "Visa Platinum".
    - **Conta de Pagamento**: De qual conta (já cadastrada) o dinheiro sairá para pagar a fatura?
    - **Limite**: Seu limite de crédito.
    - **Dia de Fechamento**: O dia que a fatura "vira". Compras após esse dia caem no mês seguinte.
    - **Dia de Vencimento**: O dia que você paga a fatura.

### Ciclo do Cartão
O FinTrack gerencia automaticamente as faturas. Ao importar despesas de cartão:
1.  A despesa é registrada no cartão.
2.  O saldo da sua conta bancária **não** muda imediatamente.
3.  Uma "Fatura" mensal acumula essas despesas.
4.  Quando você paga a fatura, uma transação de "Pagamento" sai da sua Conta Corrente e zera a dívida do cartão.
