# Fintrack Database Migration Tool

Este diretório contém a ferramenta Python para migração do banco de dados Fintrack, resolvendo o problema de referências cross-database.

## 📁 Estrutura do Projeto

```
app/
├── migrate_fintrack.py    # Script principal de migração
├── requirements.txt       # Dependências Python
├── .env.example          # Exemplo de configuração
└── README.md             # Esta documentação
```

## 🚀 Instalação Rápida

### 1. **Instalar dependências:**
```bash
cd app
pip install -r requirements.txt
```

### 2. **Configurar credenciais:**
```bash
cp .env.example .env
# Edite o arquivo .env com suas credenciais
```

### 3. **Criar schema de destino:**
```bash
psql -d phrspace -f "../database/DLL - Fintrack.sql"
```

### 4. **Executar migração:**
```bash
python migrate_fintrack.py
```

## ⚙️ Configuração (.env)

O arquivo `.env` deve conter as credenciais dos bancos:

```env
# Banco de origem (fintrack)
SOURCE_DB_HOST=localhost
SOURCE_DB_NAME=fintrack
SOURCE_DB_USER=postgres
SOURCE_DB_PASSWORD=sua_senha

# Banco de destino (phrspace)
TARGET_DB_HOST=localhost
TARGET_DB_NAME=phrspace
TARGET_DB_USER=postgres
TARGET_DB_PASSWORD=sua_senha
```

## 🔄 O que o Script Faz

### **Migração Automática:**
- ✅ **Tabelas de Lookup**: users, categories, tags, sub_categories
- ✅ **Moedas e Contas**: currencies, accounts (enum→varchar)
- ✅ **Cartões e Faturas**: cards, invoices (nova estrutura)
- ✅ **Transações**: transfers, incomes, expenses (status atualizado)
- ✅ **Cartão de Crédito**: card_expenses (sem invoice_id)

### **Transformações Aplicadas:**
- 🔄 Enum `currency` → string `currency_code`
- 🔄 Status `pending` → `validating`
- 🔄 Data `billing_month` → formato `YYYY-MM`
- 🔄 Validação de cores hexadecimais
- 🔄 Adição de campos obrigatórios com defaults

## 📊 Logs e Monitoramento

O script gera logs detalhados:
- **Console**: Progress em tempo real
- **Arquivo**: `migration_YYYYMMDD_HHMMSS.log`
- **Resumo**: Contadores por tabela ao final

Exemplo de saída:
```
✅ Migration completed successfully!
📋 Migration Summary:
  ✅ users: 5 → 5
  ✅ accounts: 12 → 12
  ✅ expenses: 1,234 → 1,234
```

## 🛠️ Resolução de Problemas

### **Erro de Conexão**
```
Database connection failed: could not connect to server
```
**✅ Solução:** Verificar credenciais no `.env`

### **Schema não encontrado**
```
Target database missing 'fintrack' schema
```
**✅ Solução:** Executar o DDL primeiro:
```bash
psql -d phrspace -f "../database/DLL - Fintrack.sql"
```

### **Dados duplicados**
```
ON CONFLICT DO NOTHING
```
**✅ Comportamento:** Script ignora duplicados automaticamente

### **Permissões negadas**
```
permission denied for schema fintrack
```
**✅ Solução:** Verificar permissões do usuário PostgreSQL

## 📋 Checklist Pós-Migração

### 1. **Aprovar Transações**
```sql
SELECT * FROM fintrack.approve_all_validating_transactions();
```

### 2. **Verificar Contadores**
```sql
SELECT 
    'users' as table_name, COUNT(*) as records 
FROM fintrack.users
UNION ALL
SELECT 'expenses', COUNT(*) FROM fintrack.expenses;
```

### 3. **Testar Conectividade**
```sql
-- Teste simples de consulta
SELECT COUNT(*) FROM fintrack.v_account_balances;
```

## ⚠️ Importante

- ✋ **Backup**: Sempre faça backup antes da migração
- 🧪 **Teste**: Execute em ambiente de desenvolvimento primeiro
- 🔒 **Segurança**: Nunca commite o arquivo `.env`
- ⏱️ **Performance**: Migração pode demorar com grandes volumes

## 🎯 Próximos Passos

1. **Conectar aplicação** ao novo schema `phrspace.fintrack`
2. **Atualizar queries** para usar a nova estrutura
3. **Testar funcionalidades** críticas
4. **Remover** banco antigo após validação completa

## 📞 Suporte

Se encontrar problemas:
1. Verificar logs gerados
2. Consultar seção de resolução de problemas
3. Validar credenciais e permissões
4. Testar conexão manual com `psql`