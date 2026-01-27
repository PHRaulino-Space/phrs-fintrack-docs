const path = require('path');
const {writeFileSync} = require('fs');

const jiti = require('jiti')(__filename);

const siteRoot = path.resolve(__dirname, '..');
const sidebarPath = path.join(siteRoot, 'docs', 'api-reference', 'sidebar.ts');
const outputPath = path.join(siteRoot, 'docs', 'api-reference', 'sidebar.json');

const sidebarModule = jiti(sidebarPath);
const sidebar = sidebarModule.default ?? sidebarModule;
const items = Array.isArray(sidebar) ? sidebar : sidebar.apisidebar;

if (!items) {
  throw new Error('Failed to read apisidebar from generated sidebar.');
}

writeFileSync(outputPath, JSON.stringify(items, null, 2));
