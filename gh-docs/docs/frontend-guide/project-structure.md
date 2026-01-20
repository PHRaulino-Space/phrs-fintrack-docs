---
sidebar_position: 1
---

# Estrutura do Projeto Frontend

O frontend do FinTrack e construido com Next.js 15 usando o App Router e React 19.

## Visao Geral

```
frontend/
├── src/
│   ├── app/                    # Next.js App Router
│   ├── components/             # Componentes reutilizaveis
│   ├── hooks/                  # Custom React hooks
│   └── lib/                    # Utilitarios e configuracoes
├── public/                     # Assets estaticos
└── configuracoes               # package.json, tsconfig, etc.
```

## Estrutura Detalhada

### `/src/app` - App Router

```
app/
├── layout.tsx              # Root layout (HTML, providers)
├── providers.tsx           # ThemeProvider, SearchProvider
├── globals.css             # Estilos globais + Tailwind
│
├── (auth)/                 # Grupo de rotas de autenticacao
│   ├── layout.tsx          # Layout centrado para auth
│   ├── login/
│   │   ├── page.tsx
│   │   └── components/
│   │       └── user-auth-form.tsx
│   ├── register/
│   │   ├── page.tsx
│   │   └── components/
│   │       └── register-form.tsx
│   └── forgot-password/
│       └── page.tsx
│
├── (dashboard)/            # Grupo de rotas do dashboard
│   ├── layout.tsx          # Layout com sidebar + ProtectedRoute
│   ├── (dashboard-1)/      # Variante de dashboard
│   │   ├── page.tsx
│   │   └── boards/
│   │       ├── overview/
│   │       └── analytics/
│   ├── dashboard-2/
│   ├── dashboard-3/
│   ├── users/
│   │   ├── page.tsx
│   │   ├── [id]/           # Rota dinamica
│   │   ├── data/
│   │   └── components/
│   ├── developers/
│   │   ├── api-keys/
│   │   ├── webhooks/
│   │   └── events-&-logs/
│   ├── import-sessions/
│   └── settings/
│       ├── profile/
│       ├── billing/
│       └── notifications/
│
└── (errors)/               # Paginas de erro
    ├── 401/
    ├── 403/
    ├── 404/
    └── 503/
```

### `/src/components` - Componentes

```
components/
├── ui/                     # shadcn/ui (40+ componentes)
│   ├── button.tsx
│   ├── card.tsx
│   ├── dialog.tsx
│   ├── form.tsx
│   ├── input.tsx
│   ├── select.tsx
│   ├── sidebar.tsx
│   ├── table.tsx
│   ├── toast.tsx
│   └── ...
│
├── layout/                 # Componentes de layout
│   ├── app-sidebar.tsx     # Sidebar principal
│   ├── header.tsx
│   ├── nav-user.tsx
│   ├── nav-group.tsx
│   ├── team-switcher.tsx
│   ├── types.ts
│   └── data/
│       └── sidebar-data.tsx
│
├── errors/                 # Componentes de erro
│   ├── not-found-error.tsx
│   ├── unauthorized-error.tsx
│   └── ...
│
├── protected-route.tsx     # HOC de autenticacao
├── theme-provider.tsx
├── theme-switch.tsx
├── search-provider.tsx
├── date-picker.tsx
├── date-range-picker.tsx
└── confirm-dialog.tsx
```

### `/src/hooks` - Custom Hooks

```
hooks/
├── use-auth.ts            # Zustand store de autenticacao
├── use-auth-check.ts      # Validacao de sessao
├── use-dialog-state.tsx   # Gerenciamento de dialogs
├── use-mobile.tsx         # Deteccao de viewport
└── use-toast.ts           # Sistema de notificacoes
```

### `/src/lib` - Utilitarios

```
lib/
├── api.ts                 # Axios instance configurado
├── utils.ts               # Funcao cn() para classes
├── notify-submitted-values.tsx
└── filter-countries.ts
```

## Convencoes de Nomenclatura

### Arquivos

| Tipo | Padrao | Exemplo |
|------|--------|---------|
| Componente | kebab-case | `user-auth-form.tsx` |
| Hook | use-*.ts | `use-auth.ts` |
| Utilitario | kebab-case | `filter-countries.ts` |
| Tipos | types.ts | `types.ts` |
| Schema | schema.ts | `schema.ts` |
| Dados | data.ts | `data.ts` |

### Pastas

| Tipo | Padrao | Exemplo |
|------|--------|---------|
| Rota | kebab-case | `forgot-password/` |
| Grupo de rota | (nome) | `(dashboard)/` |
| Rota dinamica | [param] | `[id]/` |
| Componentes | components/ | `components/` |

## Organizacao de Paginas

Cada pagina segue uma estrutura consistente:

```
users/
├── page.tsx           # Componente da pagina
├── layout.tsx         # Layout especifico (opcional)
├── data/
│   ├── schema.ts      # Schemas Zod
│   ├── data.ts        # Dados estaticos/mock
│   └── users.ts       # Tipos especificos
└── components/
    ├── users-table.tsx
    ├── users-columns.tsx
    ├── users-stats.tsx
    └── dialogs/
        ├── invite-dialog.tsx
        └── delete-dialog.tsx
```

## Imports e Aliases

O projeto usa aliases para imports limpos:

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}

// Uso
import { Button } from '@/components/ui/button';
import { useAuth } from '@/hooks/use-auth';
import api from '@/lib/api';
```

## Arquivos de Configuracao

```
frontend/
├── package.json           # Dependencias e scripts
├── tsconfig.json          # Configuracao TypeScript
├── next.config.ts         # Configuracao Next.js
├── postcss.config.mjs     # PostCSS + Tailwind
├── eslint.config.mjs      # Regras ESLint
├── .prettierrc            # Formatacao Prettier
├── components.json        # Configuracao shadcn/ui
└── .env.local            # Variaveis de ambiente
```

## Boas Praticas

1. **Colocacao**: Mantenha componentes especificos de pagina na pasta da pagina
2. **Reutilizacao**: Componentes usados em 2+ lugares vao para `/components`
3. **Separacao**: Separe logica (hooks) de apresentacao (componentes)
4. **Tipagem**: Defina tipos em arquivos `types.ts` ou `schema.ts`
5. **Schemas**: Use Zod para validacao e inferencia de tipos
