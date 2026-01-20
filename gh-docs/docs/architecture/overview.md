---
sidebar_position: 1
---

# Visão Geral da Arquitetura

O FinTrack adota uma arquitetura moderna, modular e orientada a serviços (mesmo que implantada como monolito modular), focada em manutenibilidade e escalabilidade.

## Diagrama C4 (Contexto)

```mermaid
C4Context
    title Diagrama de Contexto do Sistema FinTrack

    Person(user, "Usuário", "Pessoa que gerencia suas finanças pessoais.")
    System(fintrack, "FinTrack", "Sistema de gestão financeira pessoal auto-hospedado.")
    System_Ext(bank, "Bancos / Instituições", "Fornecem extratos em CSV.")
    System_Ext(llm, "Local LLM", "Modelo de IA local para categorização.")

    Rel(user, fintrack, "Usa", "HTTPS")
    Rel(user, bank, "Baixa extratos CSV", "HTTPS")
    Rel(fintrack, llm, "Envia descrições para categorização", "Internal API")
    Rel(user, fintrack, "Faz upload de CSV", "HTTPS")
```

## Diagrama de Containers

```mermaid
C4Container
    title Diagrama de Containers do FinTrack

    Person(user, "Usuário", "Navegador Web")

    Container_Boundary(c1, "FinTrack System") {
        Container(spa, "Single Page Application", "Next.js, React, Tailwind", "Interface do usuário para gestão financeira.")
        Container(api, "API Backend", "Go (Golang)", "Lógica de negócio, processamento de transações, gestão de sessões.")
        ContainerDb(db, "Banco de Dados", "PostgreSQL", "Armazena usuários, transações, contas e vetores de IA.")
        Container(ai_service, "Embedding Service", "Go / Python (Internal)", "Serviço de geração de embeddings e categorização.")
    }

    Rel(user, spa, "Acessa", "HTTPS")
    Rel(spa, api, "Chamadas API (JSON)", "HTTPS/JSON")
    Rel(api, db, "Leitura/Escrita (SQL)", "TCP/IP")
    Rel(api, ai_service, "Solicita categorização", "In-Process/Internal")
```

## Componentes Chave

### 1. Frontend (SPA)
Construído com **Next.js**, oferece uma experiência reativa e rápida. Utiliza **Shadcn UI** para componentes visuais consistentes e **Axios** para comunicação com a API. O estado da aplicação é gerenciado localmente e via hooks.

### 2. Backend (API)
Desenvolvido em **Go**, seguindo os princípios de **Clean Architecture**.
- **Camadas**:
    - `Handler/Controller`: Recebe requisições HTTP.
    - `UseCase`: Contém a lógica de negócio pura.
    - `Repository`: Abstrai o acesso a dados.
    - `Entity`: Define os objetos de domínio.

### 3. Banco de Dados
**PostgreSQL** é utilizado como fonte de verdade. Ele armazena não apenas dados relacionais (contas, transações), mas também **vetores (embeddings)** para o sistema de recomendação de categorias (via extensão `pgvector` ou simulação de vetores em tabelas convencionais, conforme schema).

### 4. Serviço de IA
Um componente focado em receber textos de transações (ex: "COMPRA STARBUCKS SAO PAULO") e retornar sugestões de categorias normalizadas (ex: "Alimentação > Café"). Ele utiliza embeddings para encontrar similaridades com transações passadas.
