# Estilo de Código

Mantemos padrões estritos para garantir a legibilidade.

## Backend (Go)

- Use `gofmt` ou `goimports` para formatar o código automaticamente.
- Siga o [Effective Go](https://go.dev/doc/effective_go).
- Variáveis: `camelCase`.
- Exportados: `PascalCase`.
- **Linting**: Rodamos `golangci-lint` no CI.

## Frontend (TypeScript/React)

- Use **ESLint** e **Prettier**.
- Componentes: `PascalCase` (ex: `Button.tsx`).
- Hooks: `useCamelCase` (ex: `useAuth.ts`).
- Pastas no Next.js App Router: `kebab-case` (ex: `import-sessions/`).
- Importações absolutas: use `@/components/...` em vez de `../../components`.

## Commits

Siga o padrão **Conventional Commits**:
- `feat: adiciona login`
- `fix: corrige erro no dashboard`
- `docs: atualiza readme`
- `refactor: melhora estrutura de pastas`
