# Arquitetura Frontend

O frontend do FinTrack é construído sobre **Next.js 14+** utilizando o diretório `app` (App Router), proporcionando uma arquitetura moderna, com renderização otimizada e roteamento intuitivo.

## Tecnologias Principais

- **Next.js**: Framework React para produção.
- **React**: Biblioteca para construção de interfaces.
- **Tailwind CSS**: Framework de utilitários CSS para estilização rápida.
- **Shadcn UI**: Coleção de componentes reutilizáveis baseados em Radix UI e Tailwind.
- **Axios**: Cliente HTTP para comunicação com o backend.
- **Zustand** (ou Context API): Para gerenciamento de estado global (auth, workspace ativo).
- **Lucide React**: Biblioteca de ícones.

## Estrutura de Pastas

```mermaid
graph TD
    src[src/] --> app[app/]
    src --> components[components/]
    src --> hooks[hooks/]
    src --> lib[lib/]

    app --> auth[(auth) - Login/Register]
    app --> dash[(dashboard) - Área Logada]
    app --> errors[(errors) - Páginas de Erro]

    components --> ui[ui/ - Shadcn Components]
    components --> layout[layout/ - Sidebar, Header]

    lib --> api[api.ts - Configuração Axios]
    lib --> utils[utils.ts - Helpers]
```

## Fluxo de Autenticação

1.  O usuário insere credenciais no formulário de login (`app/(auth)/login`).
2.  A requisição é enviada para `/api/v1/auth/login`.
3.  Em sucesso, o token JWT (se usado) é armazenado (cookie ou local storage) e o usuário é redirecionado para `/dashboard`.
4.  O hook `useAuth` e o `middleware` do Next.js protegem as rotas privadas.

## Gerenciamento de Workspaces

O FinTrack é multi-tenant por usuário. O frontend intercepta todas as requisições API via `lib/api.ts` para injetar o header `X-Workspace-ID`.

```typescript
// Exemplo simplificado do Interceptor
api.interceptors.request.use((config) => {
    const activeWorkspace = useAuth.getState().activeWorkspace
    if (activeWorkspace) {
        config.headers["X-Workspace-ID"] = activeWorkspace.id
    }
    return config
})
```
