# Notificações em Tempo Real

O FinTrack oferece um sistema de notificações em tempo real via **Server-Sent Events (SSE)**. Este endpoint permite que o frontend receba atualizações instantâneas quando dados são modificados no workspace, eliminando a necessidade de polling.

## Visão Geral

```
PostgreSQL Trigger → pg_notify() → SSE Handler → Frontend
```

Quando uma entidade é criada, atualizada ou deletada no banco de dados, um trigger PostgreSQL dispara uma notificação que é enviada instantaneamente para todos os clientes conectados ao workspace.

## Endpoint

**Método:** `GET`
**Rota:** `/notifications/stream`
**Autenticação:** JWT (Cookie ou Bearer Token)
**Header Obrigatório:** `X-Workspace-ID`

### Headers de Resposta

```
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

---

## Formato dos Eventos

Todos os eventos seguem o formato SSE padrão:

```
event: <event_type>
data: <json_payload>
```

### Estrutura do Payload

```json
{
  "event_type": "account.updated",
  "workspace_id": "550e8400-e29b-41d4-a716-446655440000",
  "payload": {
    "id": "660e8400-e29b-41d4-a716-446655440001"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `event_type` | string | Tipo do evento (ex: `account.created`) |
| `workspace_id` | UUID | ID do workspace onde ocorreu a mudança |
| `payload` | object | Dados específicos do evento |
| `timestamp` | string | Data/hora do evento (ISO 8601) |

---

## Tipos de Eventos

### Eventos de Sistema

| Evento | Descrição | Payload |
|--------|-----------|---------|
| `connected` | Conexão estabelecida | `{workspace_id}` |
| `heartbeat` | Keep-alive (a cada 10s) | `{ts}` |

### Contas e Cartões

| Evento | Trigger | Payload |
|--------|---------|---------|
| `account.created` | INSERT em accounts | `{id}` |
| `account.updated` | UPDATE em accounts | `{id}` |
| `account.deleted` | DELETE em accounts | `{id}` |
| `card.created` | INSERT em cards | `{id}` |
| `card.updated` | UPDATE em cards | `{id}` |
| `card.deleted` | DELETE em cards | `{id}` |
| `invoice.created` | INSERT em invoices | `{id}` |
| `invoice.updated` | UPDATE em invoices | `{id}` |

### Categorização

| Evento | Trigger | Payload |
|--------|---------|---------|
| `category.created` | INSERT em categories | `{id}` |
| `category.updated` | UPDATE em categories | `{id}` |
| `category.deleted` | DELETE em categories | `{id}` |
| `subcategory.created` | INSERT em subcategories | `{id}` |
| `subcategory.updated` | UPDATE em subcategories | `{id}` |
| `subcategory.deleted` | DELETE em subcategories | `{id}` |
| `tag.created` | INSERT em tags | `{id}` |
| `tag.updated` | UPDATE em tags | `{id}` |
| `tag.deleted` | DELETE em tags | `{id}` |

### Transações

Todos os eventos de transação incluem o campo `type` no payload para identificar o tipo específico.

| Evento | Trigger | Payload |
|--------|---------|---------|
| `transaction.created` | INSERT em tabelas de transação | `{id, type}` |
| `transaction.updated` | UPDATE em tabelas de transação | `{id, type}` |
| `transaction.deleted` | DELETE em tabelas de transação | `{id, type}` |

**Valores possíveis para `type`:**
- `income` - Receitas
- `expense` - Despesas
- `transfer` - Transferências
- `card_expense` - Despesas de cartão
- `card_chargeback` - Estornos de cartão
- `card_payment` - Pagamentos de fatura
- `investment_deposit` - Aportes em investimentos
- `investment_withdrawal` - Resgates de investimentos

### Investimentos

| Evento | Trigger | Payload |
|--------|---------|---------|
| `investment.created` | INSERT em investments | `{id}` |
| `investment.updated` | UPDATE em investments | `{id}` |
| `investment.deleted` | DELETE em investments | `{id}` |

### Recorrências

Eventos de recorrência incluem o campo `type` para identificar o tipo.

| Evento | Trigger | Payload |
|--------|---------|---------|
| `recurring.created` | INSERT em recurring_* | `{id, type}` |
| `recurring.updated` | UPDATE em recurring_* | `{id, type}` |
| `recurring.deleted` | DELETE em recurring_* | `{id, type}` |

**Valores possíveis para `type`:**
- `income` - Receita recorrente
- `expense` - Despesa recorrente
- `transfer` - Transferência recorrente
- `card_transaction` - Transação de cartão recorrente

### Import Sessions

| Evento | Trigger | Payload |
|--------|---------|---------|
| `import_session.created` | INSERT em import_sessions | `{id}` |
| `import_session.updated` | UPDATE em import_sessions | `{id}` |
| `staged_tx.status_changed` | UPDATE de status em staged_transactions | `{id, session_id, status}` |

---

## Conectando ao Stream

### JavaScript/TypeScript

```typescript
const workspaceId = 'seu-workspace-id';
const url = `${API_BASE_URL}/v1/notifications/stream`;

const eventSource = new EventSource(url, {
  withCredentials: true  // Envia cookies de autenticação
});

// Evento de conexão estabelecida
eventSource.addEventListener('connected', (e) => {
  const data = JSON.parse(e.data);
  console.log('Conectado ao workspace:', data.workspace_id);
});

// Eventos de entidades
eventSource.addEventListener('account.updated', (e) => {
  const { payload } = JSON.parse(e.data);
  console.log('Conta atualizada:', payload.id);
  // Refetch dos dados da conta
});

eventSource.addEventListener('transaction.created', (e) => {
  const { payload } = JSON.parse(e.data);
  console.log('Nova transação:', payload.id, 'tipo:', payload.type);
  // Atualizar lista de transações
});

// Heartbeat (keep-alive)
eventSource.addEventListener('heartbeat', (e) => {
  const { ts } = JSON.parse(e.data);
  console.log('Heartbeat:', ts);
});

// Tratamento de erros
eventSource.onerror = (err) => {
  console.error('Erro na conexão SSE:', err);
  // O browser tentará reconectar automaticamente
};

// Fechar conexão quando não precisar mais
// eventSource.close();
```

### React Hook

```typescript
import { useEffect, useRef, useCallback } from 'react';

type EventHandler = (payload: Record<string, unknown>) => void;

export function useNotifications() {
  const eventSourceRef = useRef<EventSource | null>(null);
  const handlersRef = useRef<Map<string, EventHandler[]>>(new Map());

  useEffect(() => {
    const url = `${process.env.NEXT_PUBLIC_API_URL}/v1/notifications/stream`;
    const eventSource = new EventSource(url, { withCredentials: true });

    eventSource.onmessage = (e) => {
      try {
        const event = JSON.parse(e.data);
        const handlers = handlersRef.current.get(event.event_type) || [];
        handlers.forEach(handler => handler(event.payload));
      } catch (err) {
        console.error('Erro ao processar notificação:', err);
      }
    };

    eventSourceRef.current = eventSource;
    return () => eventSource.close();
  }, []);

  const subscribe = useCallback((eventType: string, handler: EventHandler) => {
    const handlers = handlersRef.current.get(eventType) || [];
    handlersRef.current.set(eventType, [...handlers, handler]);

    return () => {
      const updated = handlersRef.current.get(eventType)?.filter(h => h !== handler);
      handlersRef.current.set(eventType, updated || []);
    };
  }, []);

  return { subscribe };
}
```

### Uso do Hook

```typescript
import { useEffect } from 'react';
import { useNotifications } from '@/hooks/useNotifications';
import { useAccounts } from '@/hooks/useAccounts';

export default function AccountsPage() {
  const { data: accounts, refetch } = useAccounts();
  const { subscribe } = useNotifications();

  useEffect(() => {
    const unsubscribers = [
      subscribe('account.created', () => refetch()),
      subscribe('account.updated', () => refetch()),
      subscribe('account.deleted', () => refetch()),
    ];

    return () => unsubscribers.forEach(unsub => unsub());
  }, [subscribe, refetch]);

  return <AccountsList accounts={accounts} />;
}
```

---

## Comportamento

### Reconexão Automática

O browser reconecta automaticamente em caso de perda de conexão. O SSE mantém um `Last-Event-ID` para recuperar eventos perdidos (se implementado no servidor).

### Heartbeat

O servidor envia um evento `heartbeat` a cada 10 segundos para manter a conexão ativa e detectar desconexões.

### Filtragem por Workspace

O servidor filtra automaticamente os eventos pelo `workspace_id` do header `X-Workspace-ID`. Você só receberá eventos do workspace ao qual está conectado.

---

## Boas Práticas

### 1. Feche a conexão quando não precisar

```typescript
useEffect(() => {
  const eventSource = new EventSource(url);

  return () => {
    eventSource.close(); // Importante!
  };
}, []);
```

### 2. Evite múltiplas conexões

Mantenha uma única conexão SSE por aplicação. Use um Context ou Provider para compartilhar.

### 3. Refetch seletivo

Ao receber um evento de atualização, faça refetch apenas do item específico quando possível:

```typescript
subscribe('account.updated', (payload) => {
  const { id } = payload;
  queryClient.invalidateQueries(['account', id]);
});
```

### 4. Debounce para múltiplos eventos

Se espera muitos eventos em sequência, considere usar debounce:

```typescript
import { debounce } from 'lodash';

const debouncedRefetch = debounce(() => refetch(), 500);
subscribe('transaction.created', debouncedRefetch);
```

---

## Entidades Monitoradas

| Categoria | Tabelas |
|-----------|---------|
| **Contas** | accounts, cards, invoices |
| **Categorização** | categories, subcategories, tags |
| **Transações** | incomes, expenses, transfers, card_expenses, card_chargebacks, card_payments |
| **Investimentos** | investments, investment_deposits, investment_withdrawals |
| **Recorrências** | recurring_incomes, recurring_expenses, recurring_transfers, recurring_card_transactions |
| **Import** | import_sessions, staged_transactions |

:::note Entidades não monitoradas
As seguintes entidades **não** geram notificações:
- `users` - Dados sensíveis
- `workspace_members` - Raramente alterado
- `currencies` - Dados de referência
- `exchange_rates` - Dados de referência
:::

---

## Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `401 Unauthorized` | Token JWT inválido ou ausente |
| `400 Bad Request` | Header `X-Workspace-ID` ausente |
| `403 Forbidden` | Usuário não pertence ao workspace |
