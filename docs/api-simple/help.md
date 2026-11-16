---
title: Help
---
## GET `/help/article-images/{file}`

**Resumo:** Open a private help article image

Redirects an authenticated browser to a short-lived S3 URL for a PNG in the help article media prefix.

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| file | path | string | sim | SHA-256 filename ending in .png |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 307 | Temporary Redirect |  |
| 400 | Bad Request | v1.ErrorResponse |
| 401 | Unauthorized | v1.ErrorResponse |
| 503 | Service Unavailable | v1.ErrorResponse |

## GET `/help/resources`

**Resumo:** Browse or search published videos, articles and guided tours

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| kind | query | string | não | Resource kind |
| q | query | string | não | Search titles, descriptions, video context, article text and tour instructions |
| limit | query | integer | não | Limit up to 100 |
| offset | query | integer | não | Offset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.HelpResourceList |

## GET `/help/resources/{id}`

**Resumo:** Read a published help article or guided tour

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| X-Workspace-ID | header | string | sim | Workspace ID |
| id | path | string | sim | Resource ID |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | entity.HelpResource |

### Schemas

#### entity.HelpResource

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| body | string | não |  |
| description | string | não |  |
| id | string | não |  |
| kind | string | não |  |
| steps | array&lt;entity.HelpTourStep&gt; | não |  |
| title | string | não |  |
| version | integer | não |  |

#### entity.HelpSearchResult

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| context | string | não |  |
| description | string | não |  |
| id | string | não |  |
| kind | string | não |  |
| title | string | não |  |
| youtube_url | string | não |  |
| youtube_video_id | string | não |  |

#### entity.HelpTourStep

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| advance | string | não |  |
| instruction | string | não |  |
| path | string | não |  |
| target | string | não |  |
| title | string | não |  |

#### v1.ErrorResponse

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| error | string | não |  |

#### v1.HelpResourceList

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.HelpSearchResult&gt; | não |  |
| total | integer | não |  |
