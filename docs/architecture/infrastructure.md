# Infraestrutura e integrações

O workspace inclui Compose para backend, frontend, banco e serviços opcionais. A topologia efetiva depende do manifesto escolhido e de suas variáveis, não de um diagrama único. A API pode chamar PostgreSQL, serviço HTTP de embeddings, armazenamento de imagens, mailer e Pluggy para Open Finance; o servidor MCP tem processo/configuração próprios. Uma implantação pode não habilitar todos.

A rota GET /api/health confirma apenas o handler HTTP. Backend/internal/infra/dbsetup contém funções e gatilhos de eventos, e notificações podem ser entregues por SSE. Para operar serviços, use os arquivos Compose e READMEs do checkout. Veja [arquitetura](./overview.md) e [operação](../deployment/docker.md). Não há garantia geral de IA local ou de ausência de tráfego externo quando integrações estão configuradas.
