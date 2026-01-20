---
sidebar_position: 3
---

# State Management

O FinTrack usa Zustand para estado global e React Hook Form para estado de formularios.

## Zustand

Biblioteca leve para gerenciamento de estado global.

### useAuth Store

```typescript
// hooks/use-auth.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface User {
  id: string;
  name: string;
  email: string;
  avatar_url?: string;
}

export interface Workspace {
  id: string;
  name: string;
  slug: string;
  role: 'ADMIN' | 'MEMBER';
}

interface AuthState {
  user: User | null;
  workspaces: Workspace[];
  activeWorkspace: Workspace | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setWorkspaces: (workspaces: Workspace[]) => void;
  setActiveWorkspace: (workspace: Workspace | null) => void;
  setLoading: (loading: boolean) => void;
  logout: () => void;
}

export const useAuth = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      workspaces: [],
      activeWorkspace: null,
      isAuthenticated: false,
      isLoading: true,

      setUser: (user) =>
        set({
          user,
          isAuthenticated: !!user,
        }),

      setWorkspaces: (workspaces) => {
        set({ workspaces });
        // Auto-selecionar primeiro workspace se nenhum ativo
        if (workspaces.length > 0) {
          set((state) => ({
            activeWorkspace: state.activeWorkspace || workspaces[0],
          }));
        }
      },

      setActiveWorkspace: (workspace) =>
        set({ activeWorkspace: workspace }),

      setLoading: (loading) =>
        set({ isLoading: loading }),

      logout: () =>
        set({
          user: null,
          workspaces: [],
          activeWorkspace: null,
          isAuthenticated: false,
        }),
    }),
    {
      name: 'fintrack-auth',
      // Persistir apenas activeWorkspace
      partialize: (state) => ({
        activeWorkspace: state.activeWorkspace,
      }),
    }
  )
);
```

### Uso em Componentes

```typescript
import { useAuth } from '@/hooks/use-auth';

function Header() {
  const { user, activeWorkspace, logout } = useAuth();

  return (
    <header>
      <span>Ola, {user?.name}</span>
      <span>Workspace: {activeWorkspace?.name}</span>
      <button onClick={logout}>Sair</button>
    </header>
  );
}
```

### Acesso Fora do React

Zustand permite acessar o estado fora de componentes React:

```typescript
// lib/api.ts
import { useAuth } from '@/hooks/use-auth';

// Request interceptor
api.interceptors.request.use((config) => {
  const workspace = useAuth.getState().activeWorkspace;
  if (workspace) {
    config.headers['X-Workspace-ID'] = workspace.id;
  }
  return config;
});

// Response interceptor - handle 401
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuth.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

## React Context

Para estados mais simples ou especificos de uma arvore de componentes.

### ThemeProvider

```typescript
// components/theme-provider.tsx
'use client';

import { ThemeProvider as NextThemesProvider } from 'next-themes';

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return (
    <NextThemesProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      {children}
    </NextThemesProvider>
  );
}
```

### SearchProvider

```typescript
// components/search-provider.tsx
'use client';

import { createContext, useContext, useState } from 'react';

interface SearchContextType {
  open: boolean;
  setOpen: (open: boolean) => void;
}

const SearchContext = createContext<SearchContextType | undefined>(undefined);

export function SearchProvider({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);

  return (
    <SearchContext.Provider value={{ open, setOpen }}>
      {children}
    </SearchContext.Provider>
  );
}

export function useSearch() {
  const context = useContext(SearchContext);
  if (!context) {
    throw new Error('useSearch must be used within SearchProvider');
  }
  return context;
}
```

## React Hook Form

Para gerenciamento de estado de formularios.

### Configuracao Basica

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  name: z.string().min(1, 'Nome obrigatorio'),
  email: z.string().email('Email invalido'),
  amount: z.number().positive('Valor deve ser positivo'),
});

type FormData = z.infer<typeof schema>;

function MyForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: '',
      email: '',
      amount: 0,
    },
  });

  const onSubmit = (data: FormData) => {
    console.log(data);
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input {...form.register('name')} />
      {form.formState.errors.name && (
        <span>{form.formState.errors.name.message}</span>
      )}
      <button type="submit">Enviar</button>
    </form>
  );
}
```

### Integracao com shadcn/ui

```typescript
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

function TransactionForm() {
  const form = useForm<TransactionData>({
    resolver: zodResolver(transactionSchema),
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Descricao</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="category_id"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Categoria</FormLabel>
              <Select onValueChange={field.onChange} value={field.value}>
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione..." />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {categories.map((cat) => (
                    <SelectItem key={cat.id} value={cat.id}>
                      {cat.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />
      </form>
    </Form>
  );
}
```

## Custom Hooks

### useDialogState

```typescript
// hooks/use-dialog-state.tsx
import { useState } from 'react';

export default function useDialogState<T extends string | boolean>(
  initialState: T | null = null
) {
  const [open, _setOpen] = useState<T | null>(initialState);

  const setOpen = (str: T | null) =>
    _setOpen((prev) => (prev === str ? null : str));

  return [open, setOpen] as const;
}

// Uso
const [dialog, setDialog] = useDialogState<'edit' | 'delete'>();

// Abrir dialog de edicao
setDialog('edit');

// Fechar (chamar com mesmo valor ou null)
setDialog('edit'); // fecha
setDialog(null);   // fecha
```

### useAuthCheck

```typescript
// hooks/use-auth-check.ts
import { useEffect } from 'react';
import { useAuth } from './use-auth';
import api from '@/lib/api';

export function useAuthCheck() {
  const { setUser, setWorkspaces, setLoading, logout } = useAuth();

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const { data } = await api.get('/auth/validate');
        setUser(data.user);
        setWorkspaces(data.workspaces);
      } catch {
        logout();
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, [setUser, setWorkspaces, setLoading, logout]);
}
```

## Patterns

### Loading States

```typescript
function UsersList() {
  const [isLoading, setIsLoading] = useState(true);
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    api.get('/users')
      .then(({ data }) => setUsers(data))
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) {
    return <Skeleton />;
  }

  return <DataTable data={users} />;
}
```

### Optimistic Updates

```typescript
function TodoItem({ todo }: { todo: Todo }) {
  const [isComplete, setIsComplete] = useState(todo.completed);

  const toggle = async () => {
    const previousValue = isComplete;
    setIsComplete(!isComplete); // Optimistic

    try {
      await api.patch(`/todos/${todo.id}`, { completed: !isComplete });
    } catch {
      setIsComplete(previousValue); // Rollback
      toast({ title: 'Erro ao atualizar', variant: 'destructive' });
    }
  };

  return <Checkbox checked={isComplete} onCheckedChange={toggle} />;
}
```

## Boas Praticas

1. **Zustand para estado global**: Autenticacao, workspace ativo
2. **Context para estado de arvore**: Temas, busca, sidebars
3. **React Hook Form para forms**: Validacao, performance
4. **useState para estado local**: Loading, UI temporaria
5. **Evite prop drilling**: Use Zustand ou Context
6. **Persistencia seletiva**: Persista apenas o necessario
