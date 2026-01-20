---
sidebar_position: 6
---

# Testing

O frontend do FinTrack usa Jest e React Testing Library para testes.

## Configuracao

### Jest

```javascript
// jest.config.js
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};

module.exports = createJestConfig(customJestConfig);
```

### Setup

```javascript
// jest.setup.js
import '@testing-library/jest-dom';

// Mock next/navigation
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    prefetch: jest.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => new URLSearchParams(),
}));
```

## Estrutura de Testes

```
src/
├── components/
│   ├── ui/
│   │   └── button.tsx
│   │   └── button.test.tsx
│   └── protected-route.tsx
│   └── protected-route.test.tsx
├── hooks/
│   └── use-auth.ts
│   └── use-auth.test.ts
└── __tests__/
    └── integration/
        └── login.test.tsx
```

## Testes de Componentes

### Componente Simples

```typescript
// components/ui/button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './button';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('handles click events', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click</Button>);

    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('applies variant classes', () => {
    render(<Button variant="destructive">Delete</Button>);
    expect(screen.getByRole('button')).toHaveClass('bg-destructive');
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### Componente com Estado

```typescript
// components/counter.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Counter } from './counter';

describe('Counter', () => {
  it('increments count when button is clicked', () => {
    render(<Counter />);

    expect(screen.getByText('Count: 0')).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: /increment/i }));

    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });
});
```

## Testes de Hooks

### Hook Customizado

```typescript
// hooks/use-auth.test.ts
import { renderHook, act } from '@testing-library/react';
import { useAuth } from './use-auth';

describe('useAuth', () => {
  beforeEach(() => {
    // Limpar estado entre testes
    useAuth.setState({
      user: null,
      workspaces: [],
      activeWorkspace: null,
      isAuthenticated: false,
      isLoading: true,
    });
  });

  it('starts with unauthenticated state', () => {
    const { result } = renderHook(() => useAuth());

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('sets user and isAuthenticated when setUser is called', () => {
    const { result } = renderHook(() => useAuth());

    act(() => {
      result.current.setUser({
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
      });
    });

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user?.name).toBe('Test User');
  });

  it('clears state on logout', () => {
    const { result } = renderHook(() => useAuth());

    act(() => {
      result.current.setUser({ id: '1', name: 'Test', email: 'test@test.com' });
    });

    act(() => {
      result.current.logout();
    });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });
});
```

## Testes de Formularios

```typescript
// components/login-form.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './login-form';

describe('LoginForm', () => {
  it('shows validation errors for empty fields', async () => {
    render(<LoginForm />);

    fireEvent.click(screen.getByRole('button', { name: /entrar/i }));

    await waitFor(() => {
      expect(screen.getByText(/email obrigatório/i)).toBeInTheDocument();
    });
  });

  it('shows error for invalid email', async () => {
    render(<LoginForm />);

    await userEvent.type(screen.getByLabelText(/email/i), 'invalid-email');
    fireEvent.click(screen.getByRole('button', { name: /entrar/i }));

    await waitFor(() => {
      expect(screen.getByText(/email inválido/i)).toBeInTheDocument();
    });
  });

  it('submits form with valid data', async () => {
    const handleSubmit = jest.fn();
    render(<LoginForm onSubmit={handleSubmit} />);

    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
    await userEvent.type(screen.getByLabelText(/senha/i), 'password123');

    fireEvent.click(screen.getByRole('button', { name: /entrar/i }));

    await waitFor(() => {
      expect(handleSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

## Mocking

### Mock de API

```typescript
// __mocks__/api.ts
import { jest } from '@jest/globals';

const api = {
  get: jest.fn(),
  post: jest.fn(),
  put: jest.fn(),
  delete: jest.fn(),
};

export default api;

// Em testes
import api from '@/lib/api';
jest.mock('@/lib/api');

describe('UsersList', () => {
  beforeEach(() => {
    (api.get as jest.Mock).mockResolvedValue({
      data: [
        { id: '1', name: 'User 1' },
        { id: '2', name: 'User 2' },
      ],
    });
  });

  it('loads and displays users', async () => {
    render(<UsersList />);

    await waitFor(() => {
      expect(screen.getByText('User 1')).toBeInTheDocument();
      expect(screen.getByText('User 2')).toBeInTheDocument();
    });
  });
});
```

### Mock de Router

```typescript
const mockPush = jest.fn();
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: mockPush,
  }),
}));

describe('LogoutButton', () => {
  it('redirects to login after logout', async () => {
    render(<LogoutButton />);

    fireEvent.click(screen.getByRole('button', { name: /sair/i }));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/login');
    });
  });
});
```

## Scripts

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

## Executar Testes

```bash
# Todos os testes
pnpm test

# Watch mode
pnpm test:watch

# Com coverage
pnpm test:coverage

# Arquivo especifico
pnpm test button.test.tsx
```

## Boas Praticas

1. **Teste comportamento, nao implementacao**: Foque no que o usuario ve
2. **Use getByRole quando possivel**: Mais acessivel e resiliente
3. **Evite testes de snapshot**: Preferir assertions explicitas
4. **Mock apenas o necessario**: Nao mock demais
5. **Testes independentes**: Cada teste deve funcionar isoladamente
6. **Nomenclatura clara**: Descreva o que esta sendo testado
