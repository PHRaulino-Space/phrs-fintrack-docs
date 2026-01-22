// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  tutorialSidebar: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Introdução',
    },
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'getting-started/installation',
        'getting-started/configuration',
        'getting-started/first-steps',
      ],
    },
    {
      type: 'category',
      label: 'Guia do Usuário',
      items: [
        'user-guide/workspaces',
        'user-guide/accounts-and-cards',
        'user-guide/importing-transactions',
        'user-guide/import-session-feature',
        'user-guide/categorization',
        'user-guide/dashboards',
        'user-guide/reports',
      ],
    },
    {
      type: 'category',
      label: 'Arquitetura',
      items: [
        'architecture/overview',
        'architecture/frontend',
        'architecture/backend',
        'architecture/database',
        'architecture/ai-service',
        'architecture/infrastructure',
      ],
    },
    {
      type: 'category',
      label: 'API Reference',
      items: [
        'api-reference/authentication',
        'api-reference/api-keys',
        'api-reference/workspaces',
        'api-reference/accounts',
        'api-reference/cards',
        'api-reference/categories',
        'api-reference/tags',
        'api-reference/investments',
        'api-reference/transactions',
        'api-reference/import-sessions',
        'api-reference/recurring-transactions',
      ],
    },
    {
      type: 'category',
      label: 'Guia Frontend',
      items: [
        'frontend-guide/project-structure',
        'frontend-guide/components',
        'frontend-guide/state-management',
        'frontend-guide/routing',
        'frontend-guide/styling',
        'frontend-guide/testing',
      ],
    },
    {
      type: 'category',
      label: 'Guia Backend',
      items: [
        'backend-guide/project-structure',
        'backend-guide/controllers',
        'backend-guide/services',
        'backend-guide/repositories',
        'backend-guide/models',
        'backend-guide/middleware',
        'backend-guide/testing',
      ],
    },
    {
      type: 'category',
      label: 'Banco de Dados',
      items: [
        'database/schema',
        'database/migrations',
        'database/relationships',
        'database/queries',
      ],
    },
    {
      type: 'category',
      label: 'Desenvolvimento',
      items: [
        'development/setup-environment',
        'development/running-locally',
        'development/code-style',
        'development/git-workflow',
        'development/testing-strategy',
        'development/debugging',
      ],
    },
    {
      type: 'category',
      label: 'Deployment',
      items: [
        'deployment/self-hosting',
        'deployment/docker',
        'deployment/ci-cd',
        'deployment/monitoring',
      ],
    },
    {
      type: 'category',
      label: 'Contribuindo',
      items: [
        'contributing/how-to-contribute',
        'contributing/code-of-conduct',
        'contributing/roadmap',
      ],
    },
  ],
};

export default sidebars;
