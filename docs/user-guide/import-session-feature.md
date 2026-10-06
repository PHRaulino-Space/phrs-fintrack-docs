---
title: Sessão de Importação
---

# Sessão de importação

A sessão é um contexto persistente de conta ou cartão em um workspace. Upload, inclusão manual ou sincronização criam itens preparados que podem ser classificados, vinculados e revisados. Um commit bem-sucedido registra somente os itens elegíveis/selecionados e conserva histórico; fechar sessão é outra operação.

Leia [Importações e Open Finance](../product/imports-open-finance.md) para o ciclo de vida atual, parser CSV, estados, ações de commit, idempotência, conciliação, fechamento, falhas e limites. A [API de sessões](../api-simple/import-sessions.md) contém parâmetros e respostas. A descrição anterior desta página tratava sessão como descartável por mês e fechamento como exclusão automática; isso não corresponde ao caso de uso atual.

Fontes: backend/internal/usecase/import.go, backend/internal/infra/postgres/repository/import_postgres.go, frontend/src/services/import-sessions.ts e testes correspondentes.

## Conhecimentos da sessão

A terceira aba **Conhecimentos** é um checklist de orientações exclusivo da sessão. Cada item tem título, detalhes com listas, negrito e links, marcação e posição manual. Clicar no título abre os detalhes e a edição. **Limpar marcações** desmarca todos os itens da sessão, preservando texto e ordem. Nenhuma ação do checklist cria ou altera transações, saldo, conta ou cartão.

Os itens são vinculados ao ID da sessão e ao workspace. Outra sessão da mesma conta não recebe cópia nem herda os itens. Excluir a sessão exclui seus conhecimentos. A API remove HTML ativo e atributos não permitidos; links aceitam apenas `http`, `https` e `mailto` e abrem com `noopener noreferrer`.

Rotas sob `/import-sessions/{id}/knowledge`: `GET` lista; `POST` cria; `PUT /{item_id}` edita; `PATCH /{item_id}/check` define a marcação; `DELETE /{item_id}` exclui; `PUT /order` envia todos os IDs na ordem desejada; `POST /clear-checks` desmarca tudo. Todas exigem autenticação, CSRF nas mutações e `X-Workspace-ID`. O corpo de criação/edição é `{ "title": "...", "content_html": "...", "checked": false }`; a criação inicia desmarcada. Para ordem use `{ "ids": ["uuid", "..."] }` com cada item da sessão exatamente uma vez. Para marcação use `{ "checked": true }` ou `false`. A resposta de item inclui `id`, `session_id`, `workspace_id`, `title`, `content_html`, `checked`, `position`, `created_at` e `updated_at`.
