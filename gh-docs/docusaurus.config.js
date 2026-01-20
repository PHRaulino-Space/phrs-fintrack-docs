// @ts-check
import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'FinTrack',
  tagline: 'Gestao de Financas Pessoais Auto-Hospedada com IA',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://phraulino-space.github.io',
  baseUrl: '/fintrack-docs/',

  organizationName: 'PHRaulino-Space',
  projectName: 'fintrack-docs',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'pt-BR',
    locales: ['pt-BR', 'en'],
  },

  markdown: {
    mermaid: true,
  },

  themes: ['@docusaurus/theme-mermaid'],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/PHRaulino-Space/fintrack-docs/tree/main/gh-docs/',
        },
        blog: {
          showReadingTime: true,
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          editUrl: 'https://github.com/PHRaulino-Space/fintrack-docs/tree/main/gh-docs/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/fintrack-social-card.png',
      colorMode: {
        defaultMode: 'dark',
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'FinTrack',
        logo: {
          alt: 'FinTrack Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docsSidebar',
            position: 'left',
            label: 'Documentacao',
          },
          {
            to: '/docs/api-reference/authentication',
            label: 'API',
            position: 'left',
          },
          {
            to: '/blog',
            label: 'Blog',
            position: 'left',
          },
          {
            type: 'localeDropdown',
            position: 'right',
          },
          {
            href: 'https://github.com/PHRaulino-Space/fintrack-docs',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Documentacao',
            items: [
              {
                label: 'Introducao',
                to: '/docs/intro',
              },
              {
                label: 'Guia de Inicio',
                to: '/docs/getting-started/installation',
              },
              {
                label: 'API Reference',
                to: '/docs/api-reference/authentication',
              },
            ],
          },
          {
            title: 'Desenvolvimento',
            items: [
              {
                label: 'Frontend',
                to: '/docs/frontend-guide/project-structure',
              },
              {
                label: 'Backend',
                to: '/docs/backend-guide/project-structure',
              },
              {
                label: 'Database',
                to: '/docs/database/schema',
              },
            ],
          },
          {
            title: 'Comunidade',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/PHRaulino-Space/fintrack-docs',
              },
              {
                label: 'Issues',
                href: 'https://github.com/PHRaulino-Space/fintrack-docs/issues',
              },
              {
                label: 'Discussions',
                href: 'https://github.com/PHRaulino-Space/fintrack-docs/discussions',
              },
            ],
          },
        ],
        copyright: `Copyright ${new Date().getFullYear()} FinTrack. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['bash', 'go', 'typescript', 'json', 'yaml', 'sql'],
      },
      mermaid: {
        theme: {light: 'neutral', dark: 'dark'},
      },
    }),
};

export default config;
