// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@docusaurus/module-type-aliases`).
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import {themes as prismThemes} from 'prism-react-renderer';
import {createRequire} from 'module';

const require = createRequire(import.meta.url);

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'FinTrack',
  tagline: 'Gestão Financeira Pessoal com IA e Privacidade',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://phraulino-space.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub Pages deployment, it is often '/<projectName>/'
  baseUrl: '/fintrack-docs/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'PHRaulino-Space', // Usually your GitHub org/user name.
  projectName: 'fintrack-docs', // Usually your repo name.

  onBrokenLinks: 'throw',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'pt-BR',
    locales: ['pt-BR', 'en'],
  },

  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  themes: ['@docusaurus/theme-mermaid'],
  plugins: [
    function webpackPolyfills() {
      return {
        name: 'webpack-polyfills',
        configureWebpack() {
          return {
            resolve: {
              fallback: {
                stream: require.resolve('stream-browserify'),
              },
            },
          };
        },
      };
    },
  ],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/PHRaulino-Space/fintrack-docs/tree/main/gh-docs/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/PHRaulino-Space/fintrack-docs/tree/main/gh-docs/',
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
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      navbar: {
        title: 'FinTrack',
        logo: {
          alt: 'FinTrack Logo',
          src: 'img/logo-dark.svg',
          srcDark: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Documentação',
          },
          {to: '/blog', label: 'Blog', position: 'left'},
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
            title: 'Docs',
            items: [
              {
                label: 'Introdução',
                to: '/docs/intro',
              },
              {
                label: 'Guia do Usuário',
                to: '/docs/user-guide/workspaces',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/PHRaulino-Space/fintrack-docs',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} FinTrack Project. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;
