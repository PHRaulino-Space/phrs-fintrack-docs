import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';
import apiSidebar from './docs/api-reference/sidebar.json';

const apiSidebarItems = Array.isArray(apiSidebar)
  ? apiSidebar
  : apiSidebar.apisidebar ?? [];

const apiItems = apiSidebarItems.map((item: any) => {
  if (item.type !== 'category' || typeof item.label !== 'string') {
    return item;
  }

  return {
    ...item,
    link: {type: 'doc', id: `api-reference/${item.label}`},
  };
});

const sidebars: SidebarsConfig = {
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
      items: apiItems,
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
        'development/test-scenarios',
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
