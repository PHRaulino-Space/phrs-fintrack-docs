---
sidebar_position: 1
---

# FinTrack

FinTrack reúne contas, cartões, transações, recorrências, importações, investimentos, metas e planejamento em workspaces com membros e permissões. A interface atual usa Next.js 16; a API usa Go/Gin e PostgreSQL. Há integrações opcionais de embeddings e Open Finance que dependem de serviços e credenciais configurados pela implantação.

Comece por [Produto e regras atuais](./product/index.md) para acompanhar jornadas e cálculos. A [matriz de cobertura](./product/coverage.md) indica as fontes no código e os testes; a [referência de API](./api-simple/index.md) detalha os endpoints. Consulte as [lacunas conhecidas](./product/known-gaps.md) antes de interpretar projeções e simulações como movimentos financeiros efetivos.

## Para quem usa

1. Entre e selecione um workspace; contas, cartões, categorias e movimentos são ligados a esse contexto.
2. Cadastre contas e cartões; confira saldo inicial, moeda, usuário atribuído, fechamento e vencimento.
3. Registre lançamentos diretamente ou crie uma sessão de importação para revisar dados antes de confirmar. Uma conexão Open Finance pode fornecer transações por um provedor externo configurado.
4. Leia transações, faturas, recorrências e planejamento distinguindo **pago**, **pendente**, **projetado** e **simulado**.
5. Acompanhe investimentos e metas com atenção às moedas e ao fato de que uma ligação entre entidades não movimenta dinheiro por si só.

As páginas de [acesso e configurações](./product/access-categories-tools.md), [contas e cartões](./product/accounts-cards.md), [transações e recorrências](./product/transactions-recurring.md), [importações](./product/imports-open-finance.md), [investimentos e metas](./product/investments-goals.md) e [planejamento](./product/planning-budgets-dashboard.md) explicam o caminho completo e mostram exemplos **fictícios**.

## Para quem desenvolve

Leia o [mapa do domínio](./product/domain-map.md), o [guia de manutenção](./product/maintenance.md) e os `AGENTS.md` de backend e frontend antes de alterar regras. O conteúdo desta seção foi conferido contra checkpoints identificados no índice do produto; não substitui testes nem a implementação atual quando o código evoluir.
