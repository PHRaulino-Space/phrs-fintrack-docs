---
title: Sessão de Importação
---

# Sessão de importação

A sessão é um contexto persistente de conta ou cartão em um workspace. Upload, inclusão manual ou sincronização criam itens preparados que podem ser classificados, vinculados e revisados. Um commit bem-sucedido registra somente os itens elegíveis/selecionados e conserva histórico; fechar sessão é outra operação.

Leia [Importações e Open Finance](../product/imports-open-finance.md) para o ciclo de vida atual, parser CSV, estados, ações de commit, idempotência, conciliação, fechamento, falhas e limites. A [API de sessões](../api-simple/import-sessions.md) contém parâmetros e respostas. A descrição anterior desta página tratava sessão como descartável por mês e fechamento como exclusão automática; isso não corresponde ao caso de uso atual.

Fontes: backend/internal/usecase/import.go, backend/internal/infra/postgres/repository/import_postgres.go, frontend/src/services/import-sessions.ts e testes correspondentes.
