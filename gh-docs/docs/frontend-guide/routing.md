---
sidebar_position: 4
---

# Routing

O FinTrack usa o Next.js App Router para roteamento baseado em arquivos.

## Estrutura de Rotas

```
app/
├── page.tsx                    # /
├── layout.tsx                  # Layout raiz
│
├── (auth)/                     # Grupo (nao afeta URL)
│   ├── layout.tsx              # Layout compartilhado auth
│   ├── login/page.tsx          # /login
│   ├── register/page.tsx       # /register
│   └── forgot-password/page.tsx # /forgot-password
│
├── (dashboard)/                # Grupo (nao afeta URL)
│   ├── layout.tsx              # Layout compartilhado dashboard
│   ├── page.tsx                # / (dashboard root)
│   ├── users/
│   │   ├── page.tsx            # /users
│   │   └── [id]/page.tsx       # /users/:id
│   └── settings/
│       ├── page.tsx            # /settings
│       └── profile/page.tsx    # /settings/profile
│
└── (errors)/
    ├── 401/page.tsx            # /401
    ├── 403/page.tsx            # /403
    └── 404/page.tsx            # /404
```

## Conceitos

### Route Groups `(nome)`

Agrupam rotas sem afetar a URL:

```
(auth)/login/page.tsx  →  /login     (nao /auth/login)
(dashboard)/users/page.tsx  →  /users (nao /dashboard/users)
```

Uteis para:
- Compartilhar layouts
- Organizar codigo
- Separar contextos (auth vs app)

### Dynamic Routes `[param]`

```typescript
// app/users/[id]/page.tsx
interface Props {
  params: { id: string };
}

export default function UserPage({ params }: Props) {
  const { id } = params;
  // Buscar usuario com id
  return <UserDetail userId={id} />;
}
```

### Layouts

Layouts envolvem paginas e persistem entre navegacoes:

```typescript
// app/(dashboard)/layout.tsx
import { AppSidebar } from '@/components/layout/app-sidebar';
import { ProtectedRoute } from '@/components/protected-route';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ProtectedRoute>
      <div className="flex h-screen">
        <AppSidebar />
        <main className="flex-1 overflow-auto">
          {children}
        </main>
      </div>
    </ProtectedRoute>
  );
}
```

## Navegacao

### Link Component

```typescript
import Link from 'next/link';

function Navigation() {
  return (
    <nav>
      <Link href="/users">Usuarios</Link>
      <Link href="/settings/profile">Perfil</Link>
      <Link href={`/users/${userId}`}>Ver Usuario</Link>
    </nav>
  );
}
```

### useRouter Hook

```typescript
'use client';

import { useRouter } from 'next/navigation';

function LogoutButton() {
  const router = useRouter();

  const handleLogout = async () => {
    await api.post('/auth/logout');
    router.push('/login');
  };

  return <button onClick={handleLogout}>Sair</button>;
}
```

### usePathname Hook

```typescript
'use client';

import { usePathname } from 'next/navigation';

function NavItem({ href, children }) {
  const pathname = usePathname();
  const isActive = pathname === href;

  return (
    <Link
      href={href}
      className={isActive ? 'text-primary' : 'text-muted'}
    >
      {children}
    </Link>
  );
}
```

## Protecao de Rotas

### ProtectedRoute Component

```typescript
// components/protected-route.tsx
'use client';

import { useAuth } from '@/hooks/use-auth';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isLoading, isAuthenticated, router]);

  if (isLoading) {
    return <LoadingSkeleton />;
  }

  if (!isAuthenticated) {
    return null;
  }

  return <>{children}</>;
}
```

### Uso no Layout

```typescript
// app/(dashboard)/layout.tsx
export default function DashboardLayout({ children }) {
  return (
    <ProtectedRoute>
      <SidebarProvider>
        <AppSidebar />
        <main>{children}</main>
      </SidebarProvider>
    </ProtectedRoute>
  );
}
```

## Configuracao do Sidebar

```typescript
// components/layout/data/sidebar-data.tsx
import { Home, Users, Settings, CreditCard } from 'lucide-react';

export const sidebarData = {
  navGroups: [
    {
      title: 'Dashboard',
      items: [
        { title: 'Visao Geral', url: '/', icon: Home },
        { title: 'Transacoes', url: '/transactions', icon: CreditCard },
      ],
    },
    {
      title: 'Gerenciamento',
      items: [
        { title: 'Usuarios', url: '/users', icon: Users },
        {
          title: 'Configuracoes',
          icon: Settings,
          items: [
            { title: 'Perfil', url: '/settings/profile' },
            { title: 'Billing', url: '/settings/billing' },
          ],
        },
      ],
    },
  ],
};
```

## Paginas de Erro

### 404 - Not Found

```typescript
// app/(errors)/404/page.tsx
import { NotFoundError } from '@/components/errors/not-found-error';

export default function NotFound() {
  return <NotFoundError />;
}
```

### Componente de Erro

```typescript
// components/errors/not-found-error.tsx
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export function NotFoundError() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-4xl font-bold">404</h1>
      <p className="text-muted-foreground">Pagina nao encontrada</p>
      <Button asChild className="mt-4">
        <Link href="/">Voltar ao inicio</Link>
      </Button>
    </div>
  );
}
```

## Redirect

### Server-side Redirect

```typescript
// app/page.tsx
import { redirect } from 'next/navigation';

export default function Home() {
  // Redirecionar para dashboard
  redirect('/dashboard');
}
```

### Client-side Redirect

```typescript
'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function OAuthCallback() {
  const router = useRouter();

  useEffect(() => {
    // Processar callback OAuth
    const handleCallback = async () => {
      await processOAuth();
      router.push('/dashboard');
    };
    handleCallback();
  }, [router]);

  return <Loading />;
}
```

## Boas Praticas

1. **Use grupos para organizar**: `(auth)`, `(dashboard)`, `(public)`
2. **Layouts para codigo compartilhado**: Sidebars, headers, providers
3. **Protecao centralizada**: Use ProtectedRoute no layout do dashboard
4. **Prefetch**: Links fazem prefetch automatico em producao
5. **Loading states**: Use loading.tsx para loading UI automatico
6. **Error handling**: Use error.tsx para tratamento de erros
