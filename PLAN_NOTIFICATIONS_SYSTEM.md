    # Plano: Sistema Centralizado de Notificações

    ## 1. Contexto Atual

    ### O que já existe

    O backend possui uma implementação de SSE (Server-Sent Events) em `internal/controller/http/v1/stream.go` usando PostgreSQL `LISTEN/NOTIFY`:

    ```
    PostgreSQL Trigger → pg_notify('staged_tx_updates') → SSE Handler → Frontend
    ```

    **Limitações atuais:**
    - Canal único: `staged_tx_updates` (apenas para staged transactions)
    - Acoplado à Import Session (requer session_id)
    - Handler não está conectado ao router
    - Frontend não possui client SSE implementado

    ---

    ## 2. Objetivo

    Criar um **endpoint centralizado de notificações** que:

    1. Seja agnóstico ao contexto (não apenas import session)
    2. Notifique sobre mudanças em qualquer entidade relevante
    3. Permita que o frontend faça refresh seletivo dos dados
    4. Seja extensível para futuros casos de uso

    ---

    ## 3. Arquitetura Proposta

    ### 3.1 Por que PostgreSQL LISTEN/NOTIFY?

    - Já existe infraestrutura (triggers, handler SSE)
    - Sem dependências externas
    - Transacional (notificação só dispara se commit for bem-sucedido)
    - Latência muito baixa
    - Suficiente para a escala atual do projeto

    ### 3.2 Por que SSE e não WebSocket?

    | Aspecto | WebSocket | SSE (Proposta) |
    |---------|-----------|----------------|
    | Complexidade | Alta | Média |
    | Bidirecional | Sim | Não |
    | Reconexão | Manual | Automática |
    | Firewall/Proxy | Problemático | OK |

    **Decisão:** SSE - comunicação é unidirecional (server → client), reconexão automática nativa no browser, mais simples para este caso.

    ---

    ## 4. Endpoint Central

    ```
    GET /api/v1/notifications/stream
    ```

    **Headers SSE:**
    ```
    Content-Type: text/event-stream
    Cache-Control: no-cache
    Connection: keep-alive
    ```

    **Autenticação:**
    - JWT via cookie `fintrack_token` ou header `Authorization: Bearer`
    - Workspace via header `X-Workspace-ID`

    ---

    ## 5. Estrutura de Eventos

    ### 5.1 Formato do Evento

    ```json
    {
    "event_type": "account.updated",
    "workspace_id": "uuid",
    "payload": {
        "id": "uuid"
    },
    "timestamp": "2024-01-15T10:30:00Z"
    }
    ```

    ### 5.2 Tipos de Eventos

    | Event Type | Trigger | Payload | Ação no Frontend |
    |------------|---------|---------|------------------|
    | `account.created` | INSERT em accounts | `{id}` | Adicionar à lista |
    | `account.updated` | UPDATE em accounts | `{id}` | Refetch do item |
    | `account.deleted` | DELETE em accounts | `{id}` | Remover da lista |
    | `card.created` | INSERT em cards | `{id}` | Adicionar à lista |
    | `card.updated` | UPDATE em cards | `{id}` | Refetch do item |
    | `card.deleted` | DELETE em cards | `{id}` | Remover da lista |
    | `category.created` | INSERT em categories | `{id}` | Adicionar à lista |
    | `category.updated` | UPDATE em categories | `{id}` | Refetch do item |
    | `transaction.created` | INSERT em expenses/incomes/etc | `{id, type}` | Refetch lista |
    | `transaction.updated` | UPDATE em expenses/incomes/etc | `{id, type}` | Refetch do item |
    | `transaction.deleted` | DELETE em expenses/incomes/etc | `{id, type}` | Remover da lista |
    | `staged_tx.status_changed` | UPDATE em staged_transactions | `{id, session_id, status}` | Atualizar status |
    | `import_session.completed` | Todas staged READY | `{session_id}` | Habilitar commit |

    ### 5.3 Canal PostgreSQL

    ```sql
    -- Canal único com payload tipado
    PERFORM pg_notify('workspace_events', json_build_object(
        'event_type', 'account.updated',
        'workspace_id', NEW.workspace_id,
        'payload', json_build_object('id', NEW.id),
        'timestamp', NOW()
    )::text);
    ```

    **Por que canal único?**
    - Simplifica o handler (um LISTEN apenas)
    - Filtragem por workspace_id no código Go
    - Mais fácil de manter

    ---

    ## 6. Entidades e Triggers

    ### 6.1 Mapa de Entidades

    | Categoria | Tabela | Notificar? | Evento | Observação |
    |-----------|--------|------------|--------|------------|
    | **Contas** | `accounts` | ✅ Sim | `account.*` | CRUD completo |
    | **Cartões** | `cards` | ✅ Sim | `card.*` | CRUD completo |
    | | `invoices` | ✅ Sim | `invoice.*` | Status da fatura |
    | **Categorização** | `categories` | ✅ Sim | `category.*` | CRUD completo |
    | | `subcategories` | ✅ Sim | `subcategory.*` | CRUD completo |
    | | `tags` | ✅ Sim | `tag.*` | CRUD completo |
    | **Transações Conta** | `incomes` | ✅ Sim | `transaction.*` | type: `income` |
    | | `expenses` | ✅ Sim | `transaction.*` | type: `expense` |
    | | `transfers` | ✅ Sim | `transaction.*` | type: `transfer` |
    | **Transações Cartão** | `card_expenses` | ✅ Sim | `transaction.*` | type: `card_expense` |
    | | `card_chargebacks` | ✅ Sim | `transaction.*` | type: `card_chargeback` |
    | | `card_payments` | ✅ Sim | `transaction.*` | type: `card_payment` |
    | **Investimentos** | `investments` | ✅ Sim | `investment.*` | CRUD completo |
    | | `investment_deposits` | ✅ Sim | `transaction.*` | type: `investment_deposit` |
    | | `investment_withdrawals` | ✅ Sim | `transaction.*` | type: `investment_withdrawal` |
    | **Recorrências** | `recurring_incomes` | ✅ Sim | `recurring.*` | type: `income` |
    | | `recurring_expenses` | ✅ Sim | `recurring.*` | type: `expense` |
    | | `recurring_transfers` | ✅ Sim | `recurring.*` | type: `transfer` |
    | | `recurring_card_transactions` | ✅ Sim | `recurring.*` | type: `card_transaction` |
    | **Import** | `import_sessions` | ✅ Sim | `import_session.*` | Status da sessão |
    | | `staged_transactions` | ✅ Sim | `staged_tx.*` | Status da transação |
    | **Não Notificar** | `users` | ❌ Não | - | Dados sensíveis |
    | | `workspace_members` | ❌ Não | - | Raramente muda |
    | | `currencies` | ❌ Não | - | Dados de referência |
    | | `exchange_rates` | ❌ Não | - | Dados de referência |
    | | `category_embeddings` | ❌ Não | - | Interno do sistema |
    | | `*_tags` (junções) | ❌ Não | - | Atualiza com entidade pai |

    ### 6.2 Tipos de Eventos por Entidade

    ```
    account.created    account.updated    account.deleted
    card.created       card.updated       card.deleted
    invoice.created    invoice.updated    invoice.deleted
    category.created   category.updated   category.deleted
    subcategory.created subcategory.updated subcategory.deleted
    tag.created        tag.updated        tag.deleted
    investment.created investment.updated investment.deleted
    recurring.created  recurring.updated  recurring.deleted
    import_session.created import_session.updated import_session.deleted

    transaction.created    transaction.updated    transaction.deleted
    → payload inclui { id, type }
    → type: income | expense | transfer | card_expense | card_chargeback |
            card_payment | investment_deposit | investment_withdrawal

    staged_tx.status_changed
    → payload inclui { id, session_id, status }
    ```

    ### 6.3 Lista de Triggers Necessários

    #### Função Genérica (entidades com workspace_id)

    ```sql
    CREATE OR REPLACE FUNCTION notify_workspace_event() RETURNS TRIGGER AS $$
    DECLARE
        event_type TEXT;
        payload JSON;
        ws_id UUID;
    BEGIN
        ws_id := COALESCE(NEW.workspace_id, OLD.workspace_id);

        IF TG_OP = 'INSERT' THEN
            event_type := TG_TABLE_NAME || '.created';
            payload := json_build_object('id', NEW.id);
        ELSIF TG_OP = 'UPDATE' THEN
            event_type := TG_TABLE_NAME || '.updated';
            payload := json_build_object('id', NEW.id);
        ELSIF TG_OP = 'DELETE' THEN
            event_type := TG_TABLE_NAME || '.deleted';
            payload := json_build_object('id', OLD.id);
            ws_id := OLD.workspace_id;
        END IF;

        PERFORM pg_notify('workspace_events', json_build_object(
            'event_type', event_type,
            'workspace_id', ws_id,
            'payload', payload,
            'timestamp', NOW()
        )::text);

        RETURN COALESCE(NEW, OLD);
    END;
    $$ LANGUAGE plpgsql;
    ```

    #### Triggers para Entidades Simples (17 triggers)

    ```sql
    -- Contas e Cartões
    CREATE TRIGGER accounts_notify AFTER INSERT OR UPDATE OR DELETE ON accounts
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER cards_notify AFTER INSERT OR UPDATE OR DELETE ON cards
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER invoices_notify AFTER INSERT OR UPDATE OR DELETE ON invoices
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    -- Categorização
    CREATE TRIGGER categories_notify AFTER INSERT OR UPDATE OR DELETE ON categories
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER subcategories_notify AFTER INSERT OR UPDATE OR DELETE ON subcategories
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER tags_notify AFTER INSERT OR UPDATE OR DELETE ON tags
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    -- Investimentos
    CREATE TRIGGER investments_notify AFTER INSERT OR UPDATE OR DELETE ON investments
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    -- Recorrências
    CREATE TRIGGER recurring_incomes_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_incomes
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER recurring_expenses_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_expenses
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER recurring_transfers_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_transfers
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    CREATE TRIGGER recurring_card_transactions_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_card_transactions
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();

    -- Import Sessions
    CREATE TRIGGER import_sessions_notify AFTER INSERT OR UPDATE OR DELETE ON import_sessions
        FOR EACH ROW EXECUTE FUNCTION notify_workspace_event();
    ```

    #### Função para Transações (com tipo)

    ```sql
    CREATE OR REPLACE FUNCTION notify_transaction_event() RETURNS TRIGGER AS $$
    DECLARE
        event_type TEXT;
        payload JSON;
        ws_id UUID;
        tx_type TEXT;
    BEGIN
        tx_type := CASE TG_TABLE_NAME
            WHEN 'incomes' THEN 'income'
            WHEN 'expenses' THEN 'expense'
            WHEN 'transfers' THEN 'transfer'
            WHEN 'card_expenses' THEN 'card_expense'
            WHEN 'card_payments' THEN 'card_payment'
            WHEN 'card_chargebacks' THEN 'card_chargeback'
            WHEN 'investment_deposits' THEN 'investment_deposit'
            WHEN 'investment_withdrawals' THEN 'investment_withdrawal'
            ELSE TG_TABLE_NAME
        END;

        ws_id := COALESCE(NEW.workspace_id, OLD.workspace_id);

        IF TG_OP = 'INSERT' THEN
            event_type := 'transaction.created';
            payload := json_build_object('id', NEW.id, 'type', tx_type);
        ELSIF TG_OP = 'UPDATE' THEN
            event_type := 'transaction.updated';
            payload := json_build_object('id', NEW.id, 'type', tx_type);
        ELSIF TG_OP = 'DELETE' THEN
            event_type := 'transaction.deleted';
            payload := json_build_object('id', OLD.id, 'type', tx_type);
            ws_id := OLD.workspace_id;
        END IF;

        PERFORM pg_notify('workspace_events', json_build_object(
            'event_type', event_type,
            'workspace_id', ws_id,
            'payload', payload,
            'timestamp', NOW()
        )::text);

        RETURN COALESCE(NEW, OLD);
    END;
    $$ LANGUAGE plpgsql;
    ```

    #### Triggers para Transações (8 triggers)

    ```sql
    -- Transações de Conta
    CREATE TRIGGER incomes_notify AFTER INSERT OR UPDATE OR DELETE ON incomes
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    CREATE TRIGGER expenses_notify AFTER INSERT OR UPDATE OR DELETE ON expenses
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    CREATE TRIGGER transfers_notify AFTER INSERT OR UPDATE OR DELETE ON transfers
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    -- Transações de Cartão
    CREATE TRIGGER card_expenses_notify AFTER INSERT OR UPDATE OR DELETE ON card_expenses
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    CREATE TRIGGER card_chargebacks_notify AFTER INSERT OR UPDATE OR DELETE ON card_chargebacks
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    CREATE TRIGGER card_payments_notify AFTER INSERT OR UPDATE OR DELETE ON card_payments
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    -- Transações de Investimento
    CREATE TRIGGER investment_deposits_notify AFTER INSERT OR UPDATE OR DELETE ON investment_deposits
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();

    CREATE TRIGGER investment_withdrawals_notify AFTER INSERT OR UPDATE OR DELETE ON investment_withdrawals
        FOR EACH ROW EXECUTE FUNCTION notify_transaction_event();
    ```

    #### Função para Staged Transactions (com status)

    ```sql
    CREATE OR REPLACE FUNCTION notify_staged_tx_event() RETURNS TRIGGER AS $$
    DECLARE
        payload JSON;
        ws_id UUID;
        session_record RECORD;
    BEGIN
        -- Buscar workspace_id via import_session
        SELECT workspace_id INTO session_record
        FROM import_sessions
        WHERE id = COALESCE(NEW.session_id, OLD.session_id);

        ws_id := session_record.workspace_id;

        -- Só notificar em mudanças de status
        IF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
            payload := json_build_object(
                'id', NEW.id,
                'session_id', NEW.session_id,
                'status', NEW.status
            );

            PERFORM pg_notify('workspace_events', json_build_object(
                'event_type', 'staged_tx.status_changed',
                'workspace_id', ws_id,
                'payload', payload,
                'timestamp', NOW()
            )::text);
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    ```

    #### Trigger para Staged Transactions (1 trigger)

    ```sql
    CREATE TRIGGER staged_transactions_notify AFTER UPDATE ON staged_transactions
        FOR EACH ROW EXECUTE FUNCTION notify_staged_tx_event();
    ```

    #### Função para Recorrências (com tipo)

    ```sql
    CREATE OR REPLACE FUNCTION notify_recurring_event() RETURNS TRIGGER AS $$
    DECLARE
        event_type TEXT;
        payload JSON;
        ws_id UUID;
        rec_type TEXT;
    BEGIN
        rec_type := CASE TG_TABLE_NAME
            WHEN 'recurring_incomes' THEN 'income'
            WHEN 'recurring_expenses' THEN 'expense'
            WHEN 'recurring_transfers' THEN 'transfer'
            WHEN 'recurring_card_transactions' THEN 'card_transaction'
            ELSE TG_TABLE_NAME
        END;

        ws_id := COALESCE(NEW.workspace_id, OLD.workspace_id);

        IF TG_OP = 'INSERT' THEN
            event_type := 'recurring.created';
            payload := json_build_object('id', NEW.id, 'type', rec_type);
        ELSIF TG_OP = 'UPDATE' THEN
            event_type := 'recurring.updated';
            payload := json_build_object('id', NEW.id, 'type', rec_type);
        ELSIF TG_OP = 'DELETE' THEN
            event_type := 'recurring.deleted';
            payload := json_build_object('id', OLD.id, 'type', rec_type);
            ws_id := OLD.workspace_id;
        END IF;

        PERFORM pg_notify('workspace_events', json_build_object(
            'event_type', event_type,
            'workspace_id', ws_id,
            'payload', payload,
            'timestamp', NOW()
        )::text);

        RETURN COALESCE(NEW, OLD);
    END;
    $$ LANGUAGE plpgsql;
    ```

    #### Triggers para Recorrências (usar função específica)

    ```sql
    -- Substituir os triggers de recorrências para usar a função com tipo
    DROP TRIGGER IF EXISTS recurring_incomes_notify ON recurring_incomes;
    DROP TRIGGER IF EXISTS recurring_expenses_notify ON recurring_expenses;
    DROP TRIGGER IF EXISTS recurring_transfers_notify ON recurring_transfers;
    DROP TRIGGER IF EXISTS recurring_card_transactions_notify ON recurring_card_transactions;

    CREATE TRIGGER recurring_incomes_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_incomes
        FOR EACH ROW EXECUTE FUNCTION notify_recurring_event();

    CREATE TRIGGER recurring_expenses_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_expenses
        FOR EACH ROW EXECUTE FUNCTION notify_recurring_event();

    CREATE TRIGGER recurring_transfers_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_transfers
        FOR EACH ROW EXECUTE FUNCTION notify_recurring_event();

    CREATE TRIGGER recurring_card_transactions_notify AFTER INSERT OR UPDATE OR DELETE ON recurring_card_transactions
        FOR EACH ROW EXECUTE FUNCTION notify_recurring_event();
    ```

    ### 6.4 Resumo de Triggers

    | Função | Tabelas | Total Triggers |
    |--------|---------|----------------|
    | `notify_workspace_event()` | accounts, cards, invoices, categories, subcategories, tags, investments, import_sessions | 8 |
    | `notify_transaction_event()` | incomes, expenses, transfers, card_expenses, card_chargebacks, card_payments, investment_deposits, investment_withdrawals | 8 |
    | `notify_recurring_event()` | recurring_incomes, recurring_expenses, recurring_transfers, recurring_card_transactions | 4 |
    | `notify_staged_tx_event()` | staged_transactions | 1 |
    | **Total** | | **21 triggers** |

    ---

    ## 7. Implementação Backend

    ### 7.1 Estrutura de Arquivos

    ```
    internal/
    ├── controller/http/v1/
    │   └── notifications.go          # Handler SSE centralizado
    ├── usecase/
    │   └── notification_triggers.go  # Setup de triggers
    └── entity/
        └── notification.go           # Tipos de eventos
    ```

    ### 7.2 Entity: Notification Event

    ```go
    // internal/entity/notification.go

    type EventType string

    const (
        EventAccountCreated     EventType = "account.created"
        EventAccountUpdated     EventType = "account.updated"
        EventAccountDeleted     EventType = "account.deleted"
        EventCardCreated        EventType = "card.created"
        EventCardUpdated        EventType = "card.updated"
        EventCardDeleted        EventType = "card.deleted"
        EventCategoryCreated    EventType = "category.created"
        EventCategoryUpdated    EventType = "category.updated"
        EventTransactionCreated EventType = "transaction.created"
        EventTransactionUpdated EventType = "transaction.updated"
        EventTransactionDeleted EventType = "transaction.deleted"
        EventStagedTxChanged    EventType = "staged_tx.status_changed"
        EventSessionCompleted   EventType = "import_session.completed"
    )

    type NotificationEvent struct {
        EventType   EventType              `json:"event_type"`
        WorkspaceID uuid.UUID              `json:"workspace_id"`
        Payload     map[string]interface{} `json:"payload"`
        Timestamp   time.Time              `json:"timestamp"`
    }
    ```

    ### 7.3 Handler: Notifications Stream

    ```go
    // internal/controller/http/v1/notifications.go

    type NotificationsHandler struct {
        dbURL string
    }

    func NewNotificationsHandler(dbURL string) *NotificationsHandler {
        return &NotificationsHandler{dbURL: dbURL}
    }

    func (h *NotificationsHandler) HandleStream(c *gin.Context) {
        // 1. Extrair user_id e workspace_id do contexto
        userID := contextutil.GetUserID(c.Request.Context())
        if userID == uuid.Nil {
            c.JSON(401, gin.H{"error": "Unauthorized"})
            return
        }

        workspaceID := contextutil.GetWorkspaceID(c.Request.Context())
        if workspaceID == uuid.Nil {
            c.JSON(400, gin.H{"error": "X-Workspace-ID header required"})
            return
        }

        // 2. Configurar headers SSE
        c.Writer.Header().Set("Content-Type", "text/event-stream")
        c.Writer.Header().Set("Cache-Control", "no-cache")
        c.Writer.Header().Set("Connection", "keep-alive")
        c.Writer.Flush()

        // 3. Conectar ao PostgreSQL e LISTEN
        ctx := c.Request.Context()
        conn, err := pgx.Connect(ctx, h.dbURL)
        if err != nil {
            return
        }
        defer conn.Close(ctx)

        _, err = conn.Exec(ctx, "LISTEN workspace_events")
        if err != nil {
            return
        }

        // 4. Canal para notificações
        notifCh := make(chan *pgconn.Notification)
        go func() {
            for {
                notification, err := conn.WaitForNotification(ctx)
                if err != nil {
                    close(notifCh)
                    return
                }
                notifCh <- notification
            }
        }()

        // 5. Enviar evento de conexão
        sendEvent(c.Writer, "connected", map[string]string{
            "workspace_id": workspaceID.String(),
        })

        // 6. Loop de eventos
        for {
            select {
            case <-ctx.Done():
                return
            case notification, ok := <-notifCh:
                if !ok {
                    return
                }

                var event entity.NotificationEvent
                if err := json.Unmarshal([]byte(notification.Payload), &event); err != nil {
                    continue
                }

                // Filtrar por workspace
                if event.WorkspaceID == workspaceID {
                    sendEvent(c.Writer, string(event.EventType), event)
                }
            case <-time.After(10 * time.Second):
                // Heartbeat
                sendEvent(c.Writer, "heartbeat", map[string]string{
                    "ts": time.Now().Format(time.RFC3339),
                })
            }
        }
    }

    func sendEvent(w http.ResponseWriter, eventType string, data interface{}) {
        payload, _ := json.Marshal(data)
        fmt.Fprintf(w, "event: %s\n", eventType)
        fmt.Fprintf(w, "data: %s\n\n", payload)
        if f, ok := w.(http.Flusher); ok {
            f.Flush()
        }
    }
    ```

    ### 7.4 Router

    ```go
    // internal/controller/http/v1/router.go

    // Dentro do grupo protegido (com AuthMiddleware e WorkspaceMiddleware)
    notificationsHandler := NewNotificationsHandler(cfg.Postgres.URL)
    protectedGroup.GET("/notifications/stream", notificationsHandler.HandleStream)
    ```

    ---

    ## 8. Implementação Frontend

    ### 8.1 Hook useNotifications

    ```typescript
    // src/hooks/useNotifications.ts

    import { useEffect, useRef, useCallback } from 'react';
    import { useWorkspace } from '@/contexts/WorkspaceContext';

    interface NotificationEvent {
    event_type: string;
    workspace_id: string;
    payload: Record<string, unknown>;
    timestamp: string;
    }

    type EventHandler = (payload: Record<string, unknown>) => void;

    export function useNotifications() {
    const eventSourceRef = useRef<EventSource | null>(null);
    const handlersRef = useRef<Map<string, EventHandler[]>>(new Map());
    const { currentWorkspace } = useWorkspace();

    useEffect(() => {
        if (!currentWorkspace?.id) return;

        const url = `${process.env.NEXT_PUBLIC_API_URL}/v1/notifications/stream`;
        const eventSource = new EventSource(url, { withCredentials: true });

        eventSource.addEventListener('connected', (e) => {
        console.log('Notifications connected:', JSON.parse(e.data));
        });

        eventSource.onmessage = (e) => {
        try {
            const event: NotificationEvent = JSON.parse(e.data);
            const handlers = handlersRef.current.get(event.event_type) || [];
            handlers.forEach(handler => handler(event.payload));
        } catch (err) {
            console.error('Failed to parse notification:', err);
        }
        };

        eventSource.onerror = (err) => {
        console.error('SSE error:', err);
        // Reconexão automática pelo browser
        };

        eventSourceRef.current = eventSource;

        return () => {
        eventSource.close();
        };
    }, [currentWorkspace?.id]);

    const subscribe = useCallback((eventType: string, handler: EventHandler) => {
        const handlers = handlersRef.current.get(eventType) || [];
        handlersRef.current.set(eventType, [...handlers, handler]);

        // Retorna função de unsubscribe
        return () => {
        const updated = handlersRef.current.get(eventType)?.filter(h => h !== handler);
        handlersRef.current.set(eventType, updated || []);
        };
    }, []);

    return { subscribe };
    }
    ```

    ### 8.2 Provider (Opcional)

    ```typescript
    // src/contexts/NotificationContext.tsx

    import { createContext, useContext, ReactNode } from 'react';
    import { useNotifications } from '@/hooks/useNotifications';

    type SubscribeFn = (eventType: string, handler: (payload: Record<string, unknown>) => void) => () => void;

    const NotificationContext = createContext<{ subscribe: SubscribeFn } | null>(null);

    export function NotificationProvider({ children }: { children: ReactNode }) {
    const notifications = useNotifications();

    return (
        <NotificationContext.Provider value={notifications}>
        {children}
        </NotificationContext.Provider>
    );
    }

    export function useNotificationSubscription() {
    const context = useContext(NotificationContext);
    if (!context) {
        throw new Error('useNotificationSubscription must be used within NotificationProvider');
    }
    return context;
    }
    ```

    ### 8.3 Uso em Componentes

    ```typescript
    // src/app/(dashboard)/accounts/page.tsx

    import { useEffect } from 'react';
    import { useNotificationSubscription } from '@/contexts/NotificationContext';
    import { useAccounts } from '@/hooks/useAccounts';

    export default function AccountsPage() {
    const { data: accounts, refetch } = useAccounts();
    const { subscribe } = useNotificationSubscription();

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

    ### 8.4 Refetch Seletivo (Otimização)

    ```typescript
    // Para atualizar apenas um item específico
    useEffect(() => {
    const unsub = subscribe('account.updated', (payload) => {
        const { id } = payload as { id: string };
        // Invalida apenas o cache do item específico
        queryClient.invalidateQueries(['account', id]);
    });

    return unsub;
    }, [subscribe]);
    ```

    ---

    ## 9. Migração do Stream Atual

    ### Fase 1: Implementar novo endpoint
    1. Criar `/notifications/stream` com suporte a todos os eventos
    2. Manter `/import-sessions/:id/stream` funcionando (retrocompatibilidade)

    ### Fase 2: Migrar staged_transactions
    1. Atualizar trigger de staged_transactions para publicar em `workspace_events`
    2. Frontend passa a usar o endpoint centralizado para import session também

    ### Fase 3: Remover endpoint antigo
    1. Deprecar `/import-sessions/:id/stream`
    2. Remover após confirmar que tudo funciona

    ---

    ## 10. Tarefas de Implementação

    ### Backend
    - [ ] Criar `internal/entity/notification.go`
    - [ ] Criar `internal/controller/http/v1/notifications.go`
    - [ ] Criar função SQL `notify_workspace_event()`
    - [ ] Criar função SQL `notify_transaction_event()`
    - [ ] Criar triggers: accounts, cards, categories, subcategories, tags
    - [ ] Criar triggers: incomes, expenses, transfers
    - [ ] Atualizar trigger de staged_transactions
    - [ ] Registrar rota no router
    - [ ] Testes unitários

    ### Frontend
    - [ ] Criar hook `useNotifications`
    - [ ] Criar `NotificationProvider`
    - [ ] Integrar em AccountsPage
    - [ ] Integrar em CardsPage
    - [ ] Integrar em CategoriesPage
    - [ ] Integrar em ImportSessionPage
    - [ ] Indicador visual de conexão (opcional)

    ---

    ## 11. Exemplo de Fluxo Completo

    ```
    1. Usuário A atualiza uma conta no frontend
    2. Frontend faz PUT /accounts/:id
    3. Backend atualiza registro no PostgreSQL
    4. Trigger dispara pg_notify('workspace_events', {...})
    5. Handler SSE recebe notificação
    6. Handler filtra por workspace_id
    7. Envia evento SSE para Usuário A e Usuário B (mesmo workspace)
    8. Frontend recebe evento 'account.updated'
    9. Handler do useNotifications chama refetch()
    10. UI atualiza automaticamente
    ```
