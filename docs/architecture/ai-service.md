# Classificação por embeddings

O backend possui um cliente HTTP para um serviço configurável de embeddings. Uma descrição pode ser transformada em vetor para buscar sugestão de categoria/subcategoria; o processo de enriquecimento de sessão é disparado separadamente e pode falhar ou deixar o item pendente. Jobs de embeddings de taxonomia também têm fila e tentativas. A disponibilidade do provedor e o destino dos textos dependem da implantação: o código não garante execução local nem proíbe um provedor externo.

A jornada de [importação](../product/imports-open-finance.md) explica revisão, estados e confirmação. A jornada de [categorias](../product/access-categories-tools.md) explica como o catálogo e o arquivamento interferem na classificação. Uma sugestão não é um lançamento definitivo.

Fontes: backend/internal/service/embedding_service.go, backend/internal/usecase/transaction_enrichment.go, session_enrichment.go, taxonomy_embedding_worker.go e backend/internal/infra/postgres/repository/category_embedding_postgres.go.
