# Prompt: Geração de Documentação Completa com Docusaurus

## Objetivo

Criar uma documentação técnica completa e profissional para o projeto FinTrack utilizando Docusaurus, que será hospedada via GitHub Pages na pasta `gh-docs`.

---

## Contexto do Projeto

Leia atentamente o arquivo `CONTEXT.md` neste repositório que contém toda a visão de negócio, casos de uso, arquitetura conceitual e roadmap do FinTrack.

---

## Estrutura de Código Fonte

Este repositório possui dois submódulos git que contêm o código fonte do projeto:

- **Frontend**: `./frontend/` - Aplicação web React
- **Backend**: `./backend/` - API e servidor de aplicação

Você deve explorar profundamente esses submódulos para extrair:

1. **Tecnologias utilizadas** (frameworks, bibliotecas, ferramentas)
2. **Estrutura de arquivos e pastas**
3. **Padrões arquiteturais** (MVC, Clean Architecture, etc.)
4. **Modelos de dados** (schemas, tipos, interfaces)
5. **Endpoints da API** (rotas, métodos, payloads)
6. **Componentes do frontend** (páginas, componentes reutilizáveis, hooks)
7. **Fluxos de dados** (state management, comunicação com API)
8. **Configurações** (variáveis de ambiente, builds, deploys)
9. **Testes** (unitários, integração, E2E)
10. **Scripts e automações**

---

## Requisitos da Documentação

### 1. Estrutura do Docusaurus

Crie um site Docusaurus completo na pasta `gh-docs/` com a seguinte estrutura:

```
gh-docs/
├── docs/
│   ├── intro.md
│   ├── getting-started/
│   │   ├── installation.md
│   │   ├── configuration.md
│   │   └── first-steps.md
│   ├── user-guide/
│   │   ├── workspaces.md
│   │   ├── accounts-and-cards.md
│   │   ├── importing-transactions.md
│   │   ├── categorization.md
│   │   ├── dashboards.md
│   │   └── reports.md
│   ├── architecture/
│   │   ├── overview.md
│   │   ├── frontend.md
│   │   ├── backend.md
│   │   ├── database.md
│   │   ├── ai-service.md
│   │   └── infrastructure.md
│   ├── api-reference/
│   │   ├── authentication.md
│   │   ├── workspaces.md
│   │   ├── accounts.md
│   │   ├── cards.md
│   │   ├── categories.md
│   │   ├── transactions.md
│   │   ├── import-sessions.md
│   │   └── reports.md
│   ├── frontend-guide/
│   │   ├── project-structure.md
│   │   ├── components.md
│   │   ├── state-management.md
│   │   ├── routing.md
│   │   ├── styling.md
│   │   └── testing.md
│   ├── backend-guide/
│   │   ├── project-structure.md
│   │   ├── controllers.md
│   │   ├── services.md
│   │   ├── repositories.md
│   │   ├── models.md
│   │   ├── middleware.md
│   │   └── testing.md
│   ├── database/
│   │   ├── schema.md
│   │   ├── migrations.md
│   │   ├── relationships.md
│   │   └── queries.md
│   ├── development/
│   │   ├── setup-environment.md
│   │   ├── running-locally.md
│   │   ├── code-style.md
│   │   ├── git-workflow.md
│   │   ├── testing-strategy.md
│   │   └── debugging.md
│   ├── deployment/
│   │   ├── self-hosting.md
│   │   ├── docker.md
│   │   ├── ci-cd.md
│   │   └── monitoring.md
│   └── contributing/
│       ├── how-to-contribute.md
│       ├── code-of-conduct.md
│       └── roadmap.md
├── blog/
│   └── (posts sobre releases, features, etc.)
├── src/
│   ├── components/
│   ├── css/
│   └── pages/
├── static/
│   └── img/
├── docusaurus.config.js
├── sidebars.js
└── package.json
```

### 2. Conteúdo Esperado por Seção

#### **Introdução (intro.md)**
- Visão geral do projeto
- Principais funcionalidades
- Diferenciais competitivos
- Público-alvo

#### **Getting Started**
- Pré-requisitos de instalação
- Passo a passo de instalação (desenvolvimento e produção)
- Configuração inicial (variáveis de ambiente, banco de dados)
- Primeiros passos após instalação

#### **User Guide**
- Guias práticos para cada funcionalidade principal
- Screenshots e diagramas de fluxo
- Boas práticas de uso
- Troubleshooting comum

#### **Architecture**
- Visão geral da arquitetura (diagrama C4, se possível)
- Detalhamento de cada camada/componente
- Decisões arquiteturais e trade-offs
- Fluxo de dados end-to-end
- Padrões de design utilizados

#### **API Reference**
- Documentação completa de TODOS os endpoints
- Formato: método HTTP, URL, parâmetros, body, responses
- Exemplos de requisições (curl, JavaScript, Python)
- Códigos de status e mensagens de erro
- Autenticação e autorização

#### **Frontend Guide**
- Tecnologias utilizadas (React, Redux, etc.)
- Estrutura de pastas detalhada
- Principais componentes e suas responsabilidades
- Estado global vs estado local
- Roteamento e navegação
- Sistema de estilos (CSS-in-JS, Tailwind, etc.)
- Formulários e validação
- Integração com API
- Testes de componentes

#### **Backend Guide**
- Tecnologias utilizadas (Node.js, Express, NestJS, etc.)
- Estrutura de pastas detalhada
- Padrão arquitetural (camadas, responsabilidades)
- Modelos de domínio
- Lógica de negócio
- Acesso a dados (ORM, queries)
- Middleware e interceptors
- Tratamento de erros
- Logging e monitoramento
- Testes unitários e de integração

#### **Database**
- Diagrama ER completo
- Descrição de todas as tabelas e colunas
- Relacionamentos e constraints
- Índices e otimizações
- Migrações (histórico e processo)
- Procedimentos armazenados (se houver)
- Políticas de backup e recuperação

#### **Development**
- Setup do ambiente de desenvolvimento
- Como rodar localmente (frontend, backend, banco)
- Convenções de código
- Padrões de commit (Conventional Commits)
- Fluxo de branches (GitFlow, trunk-based, etc.)
- Como escrever testes
- Como fazer debug

#### **Deployment**
- Requisitos de infraestrutura
- Instruções de deploy (Docker, VM, bare-metal)
- Configuração de CI/CD
- Variáveis de ambiente por ambiente
- Monitoramento e logs em produção
- Estratégias de rollback

#### **Contributing**
- Como contribuir com o projeto
- Processo de code review
- Código de conduta
- Roadmap de features futuras

### 3. Requisitos de Qualidade

- **Clareza**: Documentação clara e objetiva, sem jargões desnecessários
- **Completude**: Cobrir TODOS os aspectos técnicos do projeto
- **Exemplos Práticos**: Incluir código de exemplo sempre que possível
- **Diagramas**: Utilizar Mermaid para criar diagramas de arquitetura, sequência, fluxo de dados, ER
- **Navegação**: Sidebar bem estruturado com categorias lógicas
- **Busca**: Configurar busca por toda a documentação
- **Versionamento**: Preparar para múltiplas versões (future-proof)
- **Responsividade**: Design mobile-friendly
- **SEO**: Meta tags apropriadas
- **Acessibilidade**: Seguir padrões WCAG

### 4. Customizações do Docusaurus

- **Logo**: Criar/usar logo do FinTrack
- **Tema**: Customizar cores para identidade visual do projeto
- **Footer**: Links úteis (GitHub, issues, discussões)
- **Navbar**: Links para Docs, API, Blog, GitHub
- **Homepage**: Página inicial atrativa com CTAs claros
- **Syntax Highlighting**: Configurar para todas as linguagens usadas no projeto

### 5. Análise do Código Fonte

Para criar a documentação técnica detalhada, você DEVE:

1. **Explorar o submódulo frontend**:
   - Identificar framework (React, Vue, Angular, etc.)
   - Mapear estrutura de componentes
   - Listar principais bibliotecas (estado, roteamento, UI)
   - Documentar padrões de código encontrados
   - Extrair exemplos reais de uso

2. **Explorar o submódulo backend**:
   - Identificar framework (Express, NestJS, FastAPI, etc.)
   - Mapear todos os endpoints da API
   - Documentar modelos de dados (TypeScript interfaces, Prisma schemas, etc.)
   - Identificar padrões arquiteturais
   - Documentar configurações e middlewares

3. **Analisar o banco de dados**:
   - Extrair schema completo (pode estar em migrations, ORM configs, etc.)
   - Gerar diagrama ER baseado no schema
   - Documentar relacionamentos e constraints

4. **Integração com IA**:
   - Documentar como o serviço de IA é integrado
   - Endpoints/funções que consomem IA
   - Formato de entrada/saída
   - Configurações do modelo

### 6. Entregáveis

Ao final, você deve ter criado:

- [ ] Estrutura completa do Docusaurus configurada
- [ ] Todos os arquivos markdown listados acima preenchidos
- [ ] Diagramas de arquitetura (Mermaid)
- [ ] Diagrama de banco de dados (Mermaid ER)
- [ ] Documentação completa da API (todos os endpoints)
- [ ] Guias de desenvolvimento detalhados
- [ ] Exemplos de código funcionais
- [ ] Configuração de build para GitHub Pages
- [ ] README.md no gh-docs explicando como contribuir com a documentação

---

## Instruções de Execução

1. **Inicialização**: Crie o projeto Docusaurus na pasta `gh-docs/`
2. **Exploração**: Analise profundamente os submódulos `frontend/` e `backend/`
3. **Extração**: Extraia informações técnicas reais do código
4. **Criação**: Crie todos os arquivos de documentação listados
5. **Diagramas**: Gere diagramas Mermaid para visualizações
6. **Configuração**: Configure tema, plugins, navbar, sidebar
7. **Build**: Configure build para GitHub Pages
8. **Validação**: Teste localmente antes de finalizar

---

## Observações Importantes

- **Precisão Técnica**: Baseie-se no código real, não em suposições
- **Atualização**: A documentação deve refletir o estado atual do código
- **Manutenibilidade**: Estruture de forma que seja fácil manter atualizado
- **Profissionalismo**: Mantenha tom profissional mas acessível
- **Multilíngue** (opcional): Considere suporte a PT-BR e EN

---

## Resultado Esperado

Uma documentação técnica de nível profissional que permita:

- **Novos desenvolvedores** entenderem o projeto em poucas horas
- **Usuários técnicos** auto-hospedarem o sistema com sucesso
- **Contribuidores** saberem exatamente como e onde contribuir
- **Arquitetos** entenderem decisões técnicas e trade-offs
- **Stakeholders** terem visão clara do estado e roadmap do projeto

A documentação deve ser tão completa que mesmo alguém sem acesso ao código fonte consiga entender profundamente como o sistema funciona.

---

## Comando para Iniciar

Para começar, execute:

```bash
cd gh-docs
npx create-docusaurus@latest . classic
```

Depois disso, analise os submódulos e comece a criar o conteúdo baseado na estrutura definida acima.

**Boa sorte! Crie uma documentação que faria você mesmo se orgulhar.**
