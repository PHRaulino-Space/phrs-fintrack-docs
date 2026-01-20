# Estrutura do Projeto Frontend

Entenda como o código do frontend está organizado.

## `src/app` (Rotas)

O Next.js 14 usa o sistema de arquivos para roteamento.

- `(auth)`: Grupo de rotas de autenticação (sem layout de dashboard).
    - `login/page.tsx` -> `/login`
    - `register/page.tsx` -> `/register`
- `(dashboard)`: Grupo de rotas da área logada (com Sidebar e Header).
    - `layout.tsx`: Define a estrutura comum (Sidebar + Conteúdo).
    - `page.tsx` -> `/` (Home/Dashboard)
    - `import-sessions/page.tsx` -> `/import-sessions`
    - `settings/` -> Configurações.

## `src/components`

- `ui`: Componentes primitivos (Shadcn).
- `layout`: Componentes estruturais globais.
- `dashboard`: Componentes específicos de gráficos e widgets.

## `src/lib`

- `api.ts`: Instância configurada do Axios.
- `utils.ts`: Funções auxiliares (cn para classes Tailwind, formatação de moeda).

## `src/hooks`

Hooks customizados para lógica reutilizável.
- `useAuth`: Estado de autenticação.
- `useToast`: Feedback visual.
