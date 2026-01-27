# Seeds e base sintética

## Template default de categorias

O FinTrack oferece um endpoint **administrativo** que aplica o template padrão de categorias e subcategorias em um workspace sem depender de dados reais:

```bash
curl -X POST \
  -H "Authorization: Bearer <admin-token>" \
  https://<host>/api/v1/workspaces/<workspaceId>/seeds/categories-default
```

O handler é protegido pelo middleware de `Admin` e retorna algo como:

```json
{
  "categories_created": 14,
  "sub_categories_created": 40
}
```

Você pode chamar o endpoint quantas vezes quiser: ele é idempotente e não recria registros já existentes.

## Base sintética de treinamento

Para alimentar `category_embeddings` com descrições simuladas, use o endpoint:

```bash
curl -X POST \
  -H "Authorization: Bearer <admin-token>" \
  "https://<host>/api/v1/workspaces/<workspaceId>/seeds/training-synthetic?count=2000&model=default"
```

Parâmetros:
- `count` (opcional): número de exemplos a gerar (default 2000).
- `model` (opcional): nome do modelo de embedding (default `default`).

A resposta informa quantos registros foram criados e quantos já existiam:

```json
{
  "created": 2000,
  "ignored": 0,
  "duration_ms": 3200
}
```

A rotina gera descrições normalizadas (maiusculas, sem acentos, remove códigos longos), assegura equilíbrio entre subcategorias e trata `card_expense` como um `EXPENSE` comum (ou seja, o meio de pagamento muda, mas a classificação permanece na taxonomia padrão). Os vetores são calculados via serviço de embeddings e gravados em `category_embeddings` junto com o nome da categoria e subcategoria.

## Casos de uso

1. Execute o endpoint de categorias antes de qualquer importação para garantir que o workspace tenha o mesmo vocabulário padrão das bases sintéticas.
2. Use o endpoint sintético sempre que quiser reabastecer os embeddings (por exemplo, ao inicializar um ambiente de teste, treinamento local ou container isolado).
3. Ambos os endpoints exigem perfil **admin** e devem ser usados com tokens seguros.
