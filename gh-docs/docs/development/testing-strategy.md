# Estratégia de Testes

## Backend

- **Testes Unitários**: Testam a lógica de negócio (`usecase`).
    - Mockamos repositórios usando `mockgen` ou interfaces manuais.
    - Ex: Testar se `CreateTransaction` valida saldo negativo.
- **Testes de Integração**: Testam a camada de dados (`repo`).
    - Rodam contra um banco de dados real (frequentemente usando Testcontainers ou um DB de teste efêmero).

Comando:
```bash
go test ./... -v
```

## Frontend

- **Testes de Componente**: Usando Jest + React Testing Library.
    - Testam se o botão clica, se o input aceita texto.
- **Testes E2E** (Futuro): Playwright ou Cypress para testar fluxos completos (Login -> Dashboard).

Comando:
```bash
npm run test
```
