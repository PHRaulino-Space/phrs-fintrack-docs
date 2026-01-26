# Debugging

Dicas para resolver problemas comuns.

## Backend

- **Logs**: O backend usa logs estruturados. Procure por `"level":"error"` na saída do terminal.
- **Delve**: Você pode usar o debugger do Go (`dlv`) ou a integração do VS Code ("Run and Debug").

## Frontend

- **React Developer Tools**: Extensão do navegador para inspecionar a árvore de componentes e estado.
- **Network Tab**: Use a aba Rede do navegador para ver se as requisições para a API estão indo para a URL certa e se o payload está correto.
    - Erro 401: Token expirado ou não enviado.
    - Erro CORS: Falta de configuração no backend ou proxy.

## Banco de Dados

- Use um cliente como **DBeaver** ou **SQLTools** para inspecionar as tabelas diretamente.
- Verifique se as migrações foram aplicadas corretamente comparando com o `schema.sql`.
