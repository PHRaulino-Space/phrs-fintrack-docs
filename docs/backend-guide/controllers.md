# Handlers HTTP

backend/internal/controller/http/v1/router.go registra handlers por domínio e compõe os grupos de middleware. Arquivos como account.go, import.go, planning.go e transactions.go validam parâmetros, chamam casos de uso e traduzem erros em resposta HTTP. Cada arquivo new*Routes define o caminho e o verbo; os contratos gerados estão em [API](../api-simple/index.md).

Ao alterar rota ou anotação Swagger em tarefa de código, siga backend/AGENTS.md para atualizar OpenAPI. Para entender autorização, confira o grupo real em router.go e o [guia de acesso](../product/access-categories-tools.md). Exemplos antigos de CreateAccount com campos/assinaturas inventados foram removidos.

Fontes: backend/internal/controller/http/v1/router.go, account.go, import.go e backend/AGENTS.md.
