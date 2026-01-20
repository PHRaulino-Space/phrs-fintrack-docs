# Queries Comuns

Exemplos de consultas SQL úteis para manutenção ou análise direta.

## Verificar Saldo de Contas

```sql
SELECT name, initial_balance, type
FROM accounts
WHERE workspace_id = 'uuid-aqui';
```

## Listar Transações por Categoria

```sql
SELECT
    c.name as category,
    SUM(e.amount) as total
FROM expenses e
JOIN categories c ON e.category_id = c.id
WHERE e.transaction_date >= '2023-01-01'
GROUP BY c.name
ORDER BY total DESC;
```

## Encontrar Transações Não Categorizadas (IA Falhou)

```sql
SELECT description, amount
FROM expenses
WHERE category_id IS NULL OR is_trusted = false;
```
