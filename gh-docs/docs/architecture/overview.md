---
sidebar_position: 1
---

# Visao Geral da Arquitetura

O FinTrack segue uma arquitetura moderna em camadas, separando responsabilidades entre frontend, backend e banco de dados.

## Diagrama de Alto Nivel

```mermaid
flowchart TB
    subgraph "Cliente"
        Browser[Browser/PWA]
    end

    subgraph "Frontend - Next.js 15"
        Next[Next.js App Router]
        React[React 19 Components]
        Zustand[Zustand Store]
        Axios[Axios Client]
    end

    subgraph "Backend - Go/Gin"
        Router[Gin Router]
        Middleware[Auth/CORS Middleware]
        Controllers[HTTP Controllers]
        UseCases[Use Cases]
        Repos[Repositories]
    end

    subgraph "Data Layer"
        PG[(PostgreSQL 15)]
        Vector[pgvector Extension]
        Cache[In-Memory Cache]
    end

    subgraph "Servicos Externos"
        GitHub[GitHub OAuth]
        AI[Embedding Service]
    end

    Browser --> Next
    Next --> React
    React --> Zustand
    React --> Axios
    Axios --> Router
    Router --> Middleware
    Middleware --> Controllers
    Controllers --> UseCases
    UseCases --> Repos
    Repos --> PG
    PG --> Vector
    Controllers --> AI
    Middleware --> GitHub
```

## Principios Arquiteturais

### 1. Separacao de Responsabilidades

Cada camada tem uma responsabilidade unica:

| Camada | Responsabilidade |
|--------|------------------|
| **Controllers** | Receber requisicoes HTTP, validar input |
| **Use Cases** | Logica de negocio, orquestracao |
| **Repositories** | Acesso a dados, queries SQL |
| **Entities** | Modelos de dominio |

### 2. Inversao de Dependencias

```mermaid
graph TB
    subgraph "Alto Nivel"
        UC[Use Cases]
    end

    subgraph "Interfaces"
        RI[Repository Interface]
        SI[Service Interface]
    end

    subgraph "Baixo Nivel"
        PR[Postgres Repository]
        ES[Embedding Service]
    end

    UC --> RI
    UC --> SI
    PR -.-> RI
    ES -.-> SI
```

### 3. Multi-tenancy por Workspace

```mermaid
graph TB
    Request[HTTP Request] --> MW[Workspace Middleware]
    MW --> |X-Workspace-ID| Validate[Validar Acesso]
    Validate --> |Permitido| Handler[Handler]
    Validate --> |Negado| Error[403 Forbidden]
    Handler --> Query[Query com workspace_id]
```

## Stack Tecnologica

### Frontend

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| Next.js | 15.1.7 | Framework React com SSR |
| React | 19.0.0 | UI Library |
| TypeScript | 5.7.3 | Type Safety |
| Tailwind CSS | 4.0.7 | Styling |
| shadcn/ui | - | Componentes UI |
| Zustand | 5.0.10 | State Management |
| React Hook Form | 7.53.2 | Forms |
| Zod | 3.23.8 | Validacao |
| Recharts | 2.15.1 | Graficos |

### Backend

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| Go | 1.24.3 | Linguagem |
| Gin | 1.11.0 | Web Framework |
| GORM | 1.31.1 | ORM |
| JWT | 5.3.0 | Autenticacao |
| Zap | 1.27.1 | Logging |
| Viper | 1.21.0 | Configuracao |

### Banco de Dados

| Tecnologia | Versao | Proposito |
|------------|--------|-----------|
| PostgreSQL | 15+ | Database |
| pgvector | 0.3.0 | Vector Search |
| uuid-ossp | - | UUID Generation |

## Fluxo de Dados

### Requisicao HTTP

```mermaid
sequenceDiagram
    participant C as Cliente
    participant R as Router
    participant M as Middleware
    participant H as Handler
    participant U as UseCase
    participant DB as Database

    C->>R: HTTP Request
    R->>M: Auth Middleware
    M->>M: Validar JWT
    M->>M: Workspace Middleware
    M->>M: Validar X-Workspace-ID
    M->>H: Request Validado
    H->>H: Parse/Validate Body
    H->>U: Chamar UseCase
    U->>DB: Query
    DB-->>U: Resultado
    U-->>H: Dados
    H-->>C: JSON Response
```

### Autenticacao OAuth

```mermaid
sequenceDiagram
    participant U as Usuario
    participant F as Frontend
    participant B as Backend
    participant G as GitHub

    U->>F: Clica "Login com GitHub"
    F->>B: GET /auth/github/login
    B->>B: Gerar state token
    B-->>F: Redirect URL
    F->>G: Redirect para GitHub
    U->>G: Autoriza acesso
    G->>B: Callback com code
    B->>G: Exchange code for token
    G-->>B: Access token
    B->>G: Fetch user info
    G-->>B: User data
    B->>B: Create/Update user
    B->>B: Generate JWT
    B-->>F: Set cookie + redirect
    F-->>U: Dashboard
```

## Decisoes Arquiteturais

### Por que Go no Backend?

1. **Performance**: Compilado, baixo consumo de memoria
2. **Concorrencia**: Goroutines para operacoes paralelas
3. **Simplicidade**: Linguagem simples e previsivel
4. **Ecosystem**: Bibliotecas maduras (Gin, GORM)

### Por que Next.js no Frontend?

1. **SSR/SSG**: Melhor SEO e performance inicial
2. **App Router**: Roteamento moderno com layouts
3. **React 19**: Ultimas features do React
4. **Full-stack**: API routes se necessario

### Por que PostgreSQL?

1. **ACID Compliance**: Transacoes confiaveis
2. **pgvector**: Suporte nativo a embeddings
3. **JSON Support**: JSONB para dados flexiveis
4. **Maturity**: Decadas de desenvolvimento

### Por que Zustand?

1. **Lightweight**: < 1KB minified
2. **No boilerplate**: API simples
3. **Persist middleware**: localStorage facil
4. **Outside React**: Acessivel em interceptors

## Escalabilidade

### Horizontal

```mermaid
graph TB
    LB[Load Balancer]
    subgraph "Backend Instances"
        B1[Backend 1]
        B2[Backend 2]
        B3[Backend N]
    end
    subgraph "Database"
        Primary[(Primary)]
        Replica[(Read Replica)]
    end

    LB --> B1
    LB --> B2
    LB --> B3
    B1 --> Primary
    B2 --> Primary
    B3 --> Primary
    B1 --> Replica
    B2 --> Replica
    B3 --> Replica
```

### Vertical

| Componente | Minimo | Recomendado |
|------------|--------|-------------|
| CPU | 1 core | 4 cores |
| RAM | 1 GB | 4 GB |
| Disco | 10 GB | 50 GB SSD |

## Proximos Passos

- [Arquitetura do Frontend](/docs/architecture/frontend)
- [Arquitetura do Backend](/docs/architecture/backend)
- [Modelo de Dados](/docs/architecture/database)
