---
title: Sessão de Importação
---

# Sessão de importação

A sessão é um contexto persistente de conta ou cartão em um workspace. Upload, inclusão manual ou sincronização criam itens preparados que podem ser classificados, vinculados e revisados. Um commit bem-sucedido registra somente os itens elegíveis/selecionados e conserva histórico; fechar sessão é outra operação.

Leia [Importações e Open Finance](../product/imports-open-finance.md) para o ciclo de vida atual, parser CSV, estados, ações de commit, idempotência, conciliação, fechamento, falhas e limites. A [API de sessões](../api-simple/import-sessions.md) contém parâmetros e respostas. A descrição anterior desta página tratava sessão como descartável por mês e fechamento como exclusão automática; isso não corresponde ao caso de uso atual.

Fontes: backend/internal/usecase/import.go, backend/internal/infra/postgres/repository/import_postgres.go, frontend/src/services/import-sessions.ts e testes correspondentes.

## Memória do workspace

Abra **Memória** no menu principal para registrar preferências, regras e rotinas que os membros e agentes autorizados do workspace podem consultar em novas conversas, como a forma de atualizar uma parcela de financiamento ou as regras para marcar despesas com o carro. Os detalhes aceitam listas, negrito e links. Ao criar ou editar uma orientação, escolha as tags do workspace. A biblioteca permite filtrar as orientações por tag.

Em **Workspace → Contas** ou **Cartões**, abra o menu do item e escolha **Tags e memória**. As sessões de importação desse recurso exibem as orientações com uma tag ativa em comum.

Para adicionar uma orientação ao checklist, abra a aba **Memória** e escolha **Vincular memória**. Cada sessão tem sua própria ordem e marcações. Para editar uma orientação compartilhada, abra a biblioteca. **Desvincular** remove o item do checklist da sessão e mantém a orientação na biblioteca.

Ao trabalhar em uma importação, o agente recebe automaticamente as memórias pelas
tags da conta ou do cartão e pelos vínculos da sessão. Você pode corrigir ou
estabelecer uma preferência durante o trabalho. O agente pode atualizar a memória
para que a próxima importação use a versão mais recente. No chat do Fintrack,
revise a gravação no painel de confirmação.

A migração leva os conhecimentos já cadastrados nas sessões para a biblioteca e preserva os vínculos, a ordem e as marcações existentes.

## Fechamento mensal

Em **Importações**, abra **Configurar fechamento**. Selecione as contas e os cartões e use a aba **Tarefas** para cadastrar outras etapas do mês. Adicione tags aos itens ou escolha orientações diretamente da biblioteca. Contas e cartões também trazem as orientações das tags cadastradas no workspace. Uma orientação aparece uma única vez por item, mesmo com várias tags em comum ou com um vínculo direto.

Abra **Fechamento mensal** no cabeçalho para consultar as orientações, acompanhar o progresso e marcar os itens concluídos. A lista é pessoal e as marcações são guardadas por mês de referência. A [API da memória](../api-simple/knowledge.md) documenta as operações da biblioteca e do fechamento.
