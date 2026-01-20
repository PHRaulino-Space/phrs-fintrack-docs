---
sidebar_position: 5
---

# Categories (Categorias)

Endpoints para gerenciar categorias e subcategorias de transacoes.

## Endpoints - Categorias

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/categories` | Listar categorias |
| POST | `/categories` | Criar categoria |
| GET | `/categories/:id` | Obter categoria |

## Endpoints - Subcategorias

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/subcategories` | Listar subcategorias |
| POST | `/subcategories` | Criar subcategoria |
| GET | `/subcategories/:id` | Obter subcategoria |

## Endpoints - Tags

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/tags` | Listar tags |
| POST | `/tags` | Criar tag |
| GET | `/tags/:id` | Obter tag |

---

## Listar Categorias

```http
GET /api/v1/categories
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
```

**Response (200 OK):**

```json
[
  {
    "id": "cat-123-456",
    "workspace_id": "ws-123-456",
    "name": "Alimentacao",
    "type": "EXPENSE",
    "color": "#FF5733",
    "icon": "utensils",
    "is_active": true,
    "subcategories": [
      {
        "id": "subcat-001",
        "name": "Supermercado",
        "category_id": "cat-123-456",
        "is_active": true
      },
      {
        "id": "subcat-002",
        "name": "Restaurante",
        "category_id": "cat-123-456",
        "is_active": true
      }
    ],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "cat-789-012",
    "workspace_id": "ws-123-456",
    "name": "Salario",
    "type": "INCOME",
    "color": "#22C55E",
    "icon": "briefcase",
    "is_active": true,
    "subcategories": [],
    "created_at": "2024-01-15T10:35:00Z",
    "updated_at": "2024-01-15T10:35:00Z"
  }
]
```

## Criar Categoria

```http
POST /api/v1/categories
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "name": "Transporte",
  "type": "EXPENSE",
  "color": "#3B82F6",
  "icon": "car",
  "is_active": true
}
```

**Campos:**

| Campo | Tipo | Obrigatorio | Descricao |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome (1-100 chars) |
| `type` | string | Sim | `INCOME` ou `EXPENSE` |
| `color` | string | Sim | Cor hex (#RRGGBB) |
| `icon` | string | Sim | Nome do icone |
| `is_active` | boolean | Nao | Default: true |

**Response (201 Created):**

```json
{
  "id": "cat-345-678",
  "workspace_id": "ws-123-456",
  "name": "Transporte",
  "type": "EXPENSE",
  "color": "#3B82F6",
  "icon": "car",
  "is_active": true,
  "subcategories": [],
  "created_at": "2024-01-25T09:00:00Z",
  "updated_at": "2024-01-25T09:00:00Z"
}
```

**Erros:**

| Status | Descricao |
|--------|-----------|
| 400 | Dados invalidos |
| 409 | Nome ja existe para o tipo no workspace |

---

## Criar Subcategoria

```http
POST /api/v1/subcategories
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "name": "Combustivel",
  "category_id": "cat-345-678",
  "is_active": true
}
```

**Response (201 Created):**

```json
{
  "id": "subcat-003",
  "workspace_id": "ws-123-456",
  "name": "Combustivel",
  "category_id": "cat-345-678",
  "is_active": true,
  "created_at": "2024-01-25T09:05:00Z",
  "updated_at": "2024-01-25T09:05:00Z"
}
```

---

## Criar Tag

```http
POST /api/v1/tags
Authorization: Bearer {token}
X-Workspace-ID: {workspace_id}
Content-Type: application/json
```

**Request Body:**

```json
{
  "name": "Trabalho",
  "color": "#8B5CF6"
}
```

**Response (201 Created):**

```json
{
  "id": "tag-001",
  "workspace_id": "ws-123-456",
  "name": "Trabalho",
  "color": "#8B5CF6",
  "is_active": true,
  "created_at": "2024-01-25T09:10:00Z",
  "updated_at": "2024-01-25T09:10:00Z"
}
```

---

## Modelo de Dados

### Category

```typescript
interface Category {
  id: string;
  workspace_id: string;
  name: string;           // 1-100 caracteres
  type: CategoryType;     // INCOME ou EXPENSE
  color: string;          // Hex (#RRGGBB)
  icon: string;           // Nome do icone
  is_active: boolean;
  subcategories?: Subcategory[];
  created_at: string;
  updated_at: string;
}

type CategoryType = 'INCOME' | 'EXPENSE';
```

### Subcategory

```typescript
interface Subcategory {
  id: string;
  workspace_id: string;
  name: string;
  category_id: string;
  category?: Category;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
```

### Tag

```typescript
interface Tag {
  id: string;
  workspace_id: string;
  name: string;
  color?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
```

## Icones Recomendados

A interface usa [Lucide Icons](https://lucide.dev/icons) e [Tabler Icons](https://tabler.io/icons).

### Despesas

| Categoria | Icone Sugerido |
|-----------|----------------|
| Alimentacao | `utensils` |
| Transporte | `car` |
| Moradia | `home` |
| Saude | `heart` |
| Educacao | `book` |
| Lazer | `gamepad-2` |
| Vestuario | `shirt` |
| Servicos | `wrench` |

### Receitas

| Categoria | Icone Sugerido |
|-----------|----------------|
| Salario | `briefcase` |
| Freelance | `laptop` |
| Investimentos | `trending-up` |
| Vendas | `shopping-cart` |
| Outros | `gift` |

## Exemplos

### cURL - Criar Categoria

```bash
curl -X POST http://localhost:8080/api/v1/categories \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "X-Workspace-ID: ws-123-456" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Lazer",
    "type": "EXPENSE",
    "color": "#EC4899",
    "icon": "gamepad-2"
  }'
```

### JavaScript

```javascript
// Criar categoria
const category = await api.post('/categories', {
  name: 'Saude',
  type: 'EXPENSE',
  color: '#EF4444',
  icon: 'heart'
});

// Criar subcategoria
const subcategory = await api.post('/subcategories', {
  name: 'Farmacia',
  category_id: category.data.id
});

// Listar com subcategorias
const { data: categories } = await api.get('/categories');
categories.forEach(cat => {
  console.log(`${cat.name}: ${cat.subcategories.length} subcategorias`);
});
```

## Hierarquia

```mermaid
graph TB
    subgraph "Workspace"
        C1[Alimentacao]
        C2[Transporte]
        C3[Salario]
    end

    subgraph "Subcategorias"
        S1[Supermercado]
        S2[Restaurante]
        S3[Combustivel]
        S4[Uber]
    end

    subgraph "Tags"
        T1[Trabalho]
        T2[Pessoal]
    end

    C1 --> S1
    C1 --> S2
    C2 --> S3
    C2 --> S4
```

:::info Diferenca Categoria vs Tag
- **Categorias**: Hierarquicas, obrigatorias para transacoes
- **Tags**: Transversais, opcionais, podem ser multiplas por transacao
:::
