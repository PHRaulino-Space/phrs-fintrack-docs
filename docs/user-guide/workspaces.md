# Workspaces e membros

Um workspace delimita contas, cartões, categorias, transações e planejamento. Selecione o workspace antes de agir; as chamadas financeiras usam o cabeçalho de contexto e o backend valida a participação. Criar, trocar, convidar, alterar papéis e excluir têm regras próprias.

A jornada atual, incluindo papéis, convite, exclusão e configurações, está em [Acesso, taxonomia e ferramentas](../product/access-categories-tools.md). O [mapa de domínio](../product/domain-map.md) mostra o efeito da troca de workspace nos demais módulos. Exemplo ilustrativo: “Casa” e “Pessoal” são contextos diferentes, mesmo quando a pessoa é membro de ambos.

Fonte: backend/internal/controller/http/v1/router.go, workspace.go e workspace_access.go; frontend/src/hooks/use-auth.ts e frontend/src/components/layout/data/sidebar-data.tsx.
