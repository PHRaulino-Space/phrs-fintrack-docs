# Gerenciamento de Estado

O FinTrack equilibra estado local e global.

## Estado Global (Zustand)

Usamos **Zustand** para dados que precisam ser acessados em qualquer lugar da aplicação.

### Auth Store (`useAuth`)
Armazena:
- Usuário logado.
- Token JWT (opcional, pode estar apenas em cookie).
- Workspace Ativo (`activeWorkspace`).
- Métodos: `login`, `logout`, `setWorkspace`.

## Estado de Servidor (React Query / SWR / useEffect)

Para dados vindos da API (lista de transações, saldo), preferimos fetching direto nos componentes ou usando bibliotecas de cache como **TanStack Query** (se instalado) ou `useEffect` simples com estados locais.

O Next.js Server Components (RSC) também é usado para buscar dados no lado do servidor quando possível, passando como props para componentes cliente.

## Estado de Formulário

**React Hook Form** gerencia o estado de inputs, validação e submissão, evitando re-renderizações desnecessárias.
