const fs = require('fs');
const path = require('path');

const specPath = path.join(__dirname, '..', 'static', 'openapi.json');
const outDir = path.join(__dirname, '..', 'docs', 'api-simple');

const spec = JSON.parse(fs.readFileSync(specPath, 'utf8'));

const tagDescriptions = {};
if (Array.isArray(spec.tags)) {
  for (const tag of spec.tags) {
    if (tag && tag.name) {
      tagDescriptions[tag.name] = tag.description || '';
    }
  }
}

const operationsByTag = new Map();
const definitions =
  spec.definitions || (spec.components && spec.components.schemas) || {};
const httpMethods = ['get', 'post', 'put', 'patch', 'delete', 'options', 'head'];

for (const [pathKey, pathItem] of Object.entries(spec.paths || {})) {
  const baseParams = Array.isArray(pathItem.parameters)
    ? pathItem.parameters
    : [];
  for (const method of httpMethods) {
    const op = pathItem[method];
    if (!op) continue;
    const tags = Array.isArray(op.tags) && op.tags.length ? op.tags : ['default'];
    const parameters = baseParams.concat(op.parameters || []);
    const opData = {
      method: method.toUpperCase(),
      path: pathKey,
      summary: op.summary || '',
      description: op.description || '',
      parameters,
      responses: op.responses || {},
      consumes: op.consumes || spec.consumes || [],
      produces: op.produces || spec.produces || [],
    };
    for (const tag of tags) {
      if (!operationsByTag.has(tag)) operationsByTag.set(tag, []);
      operationsByTag.get(tag).push(opData);
    }
  }
}

function slugify(value) {
  const slug = String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return slug || 'default';
}

function titleize(value) {
  return String(value || '')
    .split(/[-_\s]+/g)
    .filter(Boolean)
    .map((part) => part[0].toUpperCase() + part.slice(1))
    .join(' ');
}

function schemaToString(schema) {
  if (!schema) return '';
  if (schema.$ref) {
    return schema.$ref
      .replace('#/definitions/', '')
      .replace('#/components/schemas/', '');
  }
  if (schema.type === 'array' && schema.items) {
    return `array<${schemaToString(schema.items)}>`;
  }
  if (schema.type) return schema.type;
  return 'object';
}

function paramType(param) {
  if (param.schema) return schemaToString(param.schema);
  if (param.type) {
    return param.format ? `${param.type} (${param.format})` : param.type;
  }
  return '';
}

function escapeYaml(value) {
  const text = String(value || '').replace(/\n/g, ' ').trim();
  if (!text) return '';
  return `"${text.replace(/\\/g, '\\\\').replace(/\"/g, '\\"')}"`;
}

function escapeText(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, ' ')
    .trim();
}

function escapeTableCell(value) {
  return escapeText(value).replace(/\|/g, '\\|');
}

function collectRefsFromSchema(schema, refs, visiting, visited) {
  if (!schema || typeof schema !== 'object') return;
  if (schema.$ref) {
    const name = schema.$ref
      .replace('#/definitions/', '')
      .replace('#/components/schemas/', '');
    refs.add(name);
    if (visited.has(name) || visiting.has(name)) return;
    visiting.add(name);
    if (definitions[name]) {
      collectRefsFromSchema(definitions[name], refs, visiting, visited);
    }
    visiting.delete(name);
    visited.add(name);
    return;
  }

  if (schema.allOf) {
    schema.allOf.forEach((item) =>
      collectRefsFromSchema(item, refs, visiting, visited)
    );
  }
  if (schema.oneOf) {
    schema.oneOf.forEach((item) =>
      collectRefsFromSchema(item, refs, visiting, visited)
    );
  }
  if (schema.anyOf) {
    schema.anyOf.forEach((item) =>
      collectRefsFromSchema(item, refs, visiting, visited)
    );
  }

  if (schema.type === 'array' && schema.items) {
    collectRefsFromSchema(schema.items, refs, visiting, visited);
  }

  if (schema.properties && typeof schema.properties === 'object') {
    Object.values(schema.properties).forEach((prop) =>
      collectRefsFromSchema(prop, refs, visiting, visited)
    );
  }

  if (schema.additionalProperties && typeof schema.additionalProperties === 'object') {
    collectRefsFromSchema(
      schema.additionalProperties,
      refs,
      visiting,
      visited
    );
  }
}

function collectRefsFromOperation(op, refs, visiting, visited) {
  const params = Array.isArray(op.parameters) ? op.parameters : [];
  for (const param of params) {
    if (param.schema)
      collectRefsFromSchema(param.schema, refs, visiting, visited);
    if (param.items) collectRefsFromSchema(param.items, refs, visiting, visited);
  }

  const responses = op.responses || {};
  for (const resp of Object.values(responses)) {
    if (resp && resp.schema) {
      collectRefsFromSchema(resp.schema, refs, visiting, visited);
    }
  }
}

// Reset output dir
fs.rmSync(outDir, {recursive: true, force: true});
fs.mkdirSync(outDir, {recursive: true});

// Overview page
const baseUrl = (() => {
  if (spec.host && spec.basePath) return `http://${spec.host}${spec.basePath}`;
  if (spec.host) return `http://${spec.host}`;
  return '';
})();

const overviewLines = [
  '---',
  'title: API Reference',
  '---',
  '',
];
if (spec.info && spec.info.description) {
  overviewLines.push(spec.info.description, '');
}
if (baseUrl) {
  overviewLines.push(`**Base URL:** \`${baseUrl}\``);
}
if (spec.info && spec.info.version) {
  overviewLines.push(`**Version:** ${spec.info.version}`);
}
overviewLines.push('');
fs.writeFileSync(path.join(outDir, 'index.md'), overviewLines.join('\n'));

// Tag pages
const tagEntries = Array.from(operationsByTag.entries()).sort((a, b) =>
  a[0].localeCompare(b[0])
);

for (const [tag, operations] of tagEntries) {
  const fileName = `${slugify(tag)}.md`;
  const title = titleize(tag);
  const description = tagDescriptions[tag] || '';
  const lines = [
    '---',
    `title: ${title}`,
    description ? `description: ${escapeYaml(description)}` : undefined,
    '---',
    '',
  ].filter(Boolean);

  if (description) {
    lines.push(description, '');
  }

  const sortedOps = operations.sort((a, b) =>
    `${a.method} ${a.path}`.localeCompare(`${b.method} ${b.path}`)
  );

  const tagRefs = new Set();
  const visitingRefs = new Set();
  const visitedRefs = new Set();

  for (const op of sortedOps) {
    collectRefsFromOperation(op, tagRefs, visitingRefs, visitedRefs);
    lines.push(`## ${op.method} \`${op.path}\``, '');
    if (op.summary) {
      lines.push(`**Resumo:** ${escapeText(op.summary)}`, '');
    }
    if (op.description && op.description !== op.summary) {
      lines.push(escapeText(op.description), '');
    }

    if (op.consumes.length) {
      lines.push(`**Consumes:** ${op.consumes.join(', ')}`, '');
    }
    if (op.produces.length) {
      lines.push(`**Produces:** ${op.produces.join(', ')}`, '');
    }

    const params = Array.isArray(op.parameters) ? op.parameters : [];
    lines.push('### Parâmetros', '');
    if (!params.length) {
      lines.push('Sem parâmetros.', '');
    } else {
      lines.push('| Nome | Em | Tipo | Obrigatório | Descrição |');
      lines.push('| --- | --- | --- | --- | --- |');
      for (const param of params) {
        const name = escapeTableCell(param.name || '');
        const loc = escapeTableCell(param.in || '');
        const type = escapeTableCell(paramType(param));
        const required = param.required ? 'sim' : 'não';
        const desc = escapeTableCell(param.description || '');
        lines.push(`| ${name} | ${loc} | ${type} | ${required} | ${desc} |`);
      }
      lines.push('');
    }

    const responses = op.responses || {};
    const codes = Object.keys(responses);
    lines.push('### Respostas', '');
    if (!codes.length) {
      lines.push('Sem respostas definidas.', '');
    } else {
      lines.push('| Status | Descrição | Schema |');
      lines.push('| --- | --- | --- |');
      for (const code of codes) {
        const resp = responses[code] || {};
        const desc = escapeTableCell(resp.description || '');
        const schema = escapeTableCell(schemaToString(resp.schema));
        lines.push(`| ${code} | ${desc} | ${schema} |`);
      }
      lines.push('');
    }
  }

  if (tagRefs.size) {
    lines.push('### Schemas', '');
    const refList = Array.from(tagRefs).sort((a, b) => a.localeCompare(b));
    for (const name of refList) {
      const schema = definitions[name];
      lines.push(`#### ${escapeText(name)}`, '');
      if (!schema) {
        lines.push('Schema não encontrado.', '');
        continue;
      }

      if (schema.description) {
        lines.push(escapeText(schema.description), '');
      }

      const props = schema.properties || {};
      const required = Array.isArray(schema.required) ? schema.required : [];
      const propEntries = Object.entries(props);

      if (!propEntries.length) {
        lines.push('Sem propriedades.', '');
        continue;
      }

      lines.push('| Campo | Tipo | Obrigatório | Descrição |');
      lines.push('| --- | --- | --- | --- |');
      for (const [propName, propSchema] of propEntries) {
        const type = escapeTableCell(schemaToString(propSchema));
        const isRequired = required.includes(propName) ? 'sim' : 'não';
        const desc = escapeTableCell(propSchema.description || '');
        lines.push(
          `| ${escapeTableCell(propName)} | ${type} | ${isRequired} | ${desc} |`
        );
      }
      lines.push('');
    }
  }

  fs.writeFileSync(path.join(outDir, fileName), lines.join('\n'));
}

console.log(`Generated ${tagEntries.length} API docs in ${outDir}`);
