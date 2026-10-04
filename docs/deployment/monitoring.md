# Saúde e observabilidade

A rota de saúde atual é GET /api/health com API_PREFIX padrão /api; é registrada em backend/internal/controller/http/v1/router.go antes das rotas v1. O middleware RequestObservability inclui correlação de requisição; logs e eventos de notificação/SSE são implementados no backend. Uma resposta de health confirma o handler HTTP, não a saúde de PostgreSQL, Pluggy, serviço de embeddings ou consumidores de eventos.

Para configurar monitoramento da implantação, consulte backend/README.md, backend/internal/controller/http/v1/router.go e backend/internal/infra/dbsetup/setup.go. Métricas Prometheus ou uma rota /live não devem ser anunciadas sem implementação. Nenhum serviço foi iniciado para esta revisão.
