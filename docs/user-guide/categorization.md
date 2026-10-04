# Categorias, subcategorias e tags

Categorias agrupam receitas, despesas ou metas; subcategorias refinam a classificação e tags são marcadores adicionais. Cores e ícones ajudam a leitura. O arquivamento preserva histórico e restringe novos usos. A exclusão com dependências passa por prévia de impacto e confirmação; nem toda dependência pode ser movida ou eliminada.

A [jornada de taxonomia](../product/access-categories-tools.md) traz validações, arquivamento, bloqueios, ações atômicas e o papel do enriquecimento por embeddings. A [jornada de importação](../product/imports-open-finance.md) explica quando uma sugestão de classificação é processada e como revisá-la. Uma sugestão automática não substitui a confirmação do usuário.

Fontes: backend/internal/controller/http/v1/category.go, sub_category.go, impact_preview.go; backend/internal/infra/dbsetup/setup.go; frontend/src/app/(fintrack)/workspace/categories.
