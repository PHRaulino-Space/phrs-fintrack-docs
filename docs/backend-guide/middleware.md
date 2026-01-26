# Middleware

Os middlewares interceptam requisições HTTP antes de chegarem aos controllers.

## AuthMiddleware
Valida o JWT no header `Authorization`. Se válido, injeta o `user_id` no contexto da requisição.

## WorkspaceMiddleware
Verifica o header `X-Workspace-ID`.
1.  O ID é um UUID válido?
2.  O usuário autenticado tem permissão de acesso a este workspace?
Se sim, injeta o `workspace_id` no contexto. Caso contrário, retorna 403 Forbidden.

## LoggerMiddleware
Loga detalhes da requisição (Método, URL, Duração, Status Code) para monitoramento.

## CORS
Configura os headers de Cross-Origin Resource Sharing para permitir que o frontend (em outra porta/domínio) acesse a API.
