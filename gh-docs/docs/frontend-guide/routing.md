# Roteamento

O roteamento é gerenciado pelo **Next.js App Router**.

## Rotas Públicas vs Privadas

- **Públicas**: Login, Register, Forgot Password.
- **Privadas**: Todas dentro de `(dashboard)`.

## Proteção de Rotas

Utilizamos Middleware ou HOCs (Higher Order Components) para proteger rotas. Se um usuário não autenticado tenta acessar `/settings`, ele é redirecionado para `/login`.

## Navegação

Use o componente `Link` do Next.js para navegação interna sem recarregar a página.

```tsx
import Link from "next/link"

<Link href="/import-sessions">
  Ir para Importações
</Link>
```
