# Services (Use Cases)

Os Services contêm a lógica de negócio "pura". Eles orquestram chamadas aos repositórios e validam regras de domínio.

## Exemplo: Criar Transação

Ao criar uma transação, o service pode precisar:
1.  Verificar se a conta existe.
2.  Verificar se a categoria é válida.
3.  Salvar a transação.
4.  Atualizar o saldo da conta (se não for calculado on-the-fly).

```go
func (uc *TransactionUseCase) Create(ctx context.Context, t *entity.Transaction) error {
    // Regra de Negócio: Não permitir transação futura se configurado
    if t.Date.After(time.Now()) && !uc.allowFuture {
        return ErrFutureTransactionNotAllowed
    }

    // Persistência
    return uc.repo.Create(ctx, t)
}
```
