---
title: Crypto Assets
---
## DELETE `/crypto-assets/{id}`

**Resumo:** Delete unreferenced global crypto asset (global admin)

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Crypto asset ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 204 | No Content |  |

## GET `/crypto-assets`

**Resumo:** List global crypto assets

**Produces:** application/json

### Parâmetros

Sem parâmetros.

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | array&lt;entity.CryptoAsset&gt; |

## GET `/crypto-assets/{id}`

**Resumo:** Get global crypto asset

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Crypto asset ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.CryptoAsset |

## PATCH `/crypto-assets/{id}`

**Resumo:** Update global crypto asset (global admin)

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| id | path | string | sim | Crypto asset ID |
| body | body | v1.CryptoAssetRequest | sim | Crypto asset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.CryptoAsset |

## POST `/crypto-assets`

**Resumo:** Create private workspace or verified global crypto asset

**Consumes:** application/json

**Produces:** application/json

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| body | body | v1.CryptoAssetRequest | sim | Crypto asset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 201 | Created | entity.CryptoAsset |

### Schemas

#### entity.CryptoAsset

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| admin_validated_at | string | não |  |
| admin_validated_by | string | não |  |
| admin_validation_source | string | não |  |
| admin_validation_version | integer | não |  |
| content_version | integer | não |  |
| contract_address | string | não |  |
| created_at | string | não |  |
| creator_user_id | string | não |  |
| id | string | não |  |
| is_verified | boolean | não |  |
| name | string | não |  |
| network | string | não |  |
| owner_workspace_id | string | não |  |
| symbol | string | não |  |
| updated_at | string | não |  |
| user_validated_at | string | não |  |
| user_validated_by | string | não |  |
| user_validation_version | integer | não |  |

#### v1.CryptoAssetRequest

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| contract_address | string | não |  |
| name | string | não |  |
| network | string | não |  |
| symbol | string | não |  |
| validate_globally | boolean | não |  |
