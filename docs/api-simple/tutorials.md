---
title: Tutorials
---
## GET `/tutorial-videos`

**Resumo:** List global tutorials available to workspace members

### Parâmetros

| Nome | Em | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- | --- |
| q | query | string | não | Literal title search, case/accent insensitive, max 200 characters |
| X-Workspace-ID | header | string | sim | Workspace ID |
| limit | query | integer | não | Limit up to 100 |
| offset | query | integer | não | Offset |

### Respostas

| Status | Descrição | Schema |
| --- | --- | --- |
| 200 | OK | v1.TutorialVideoList |

### Schemas

#### entity.TutorialVideo

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| context | string | não |  |
| created_at | string | não |  |
| description | string | não |  |
| id | string | não |  |
| title | string | não |  |
| updated_at | string | não |  |
| version | integer | não |  |
| youtube_url | string | não |  |
| youtube_video_id | string | não |  |

#### v1.TutorialVideoList

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| items | array&lt;entity.TutorialVideo&gt; | não |  |
| total | integer | não |  |
