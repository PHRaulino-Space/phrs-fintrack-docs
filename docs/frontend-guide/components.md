# Componentes de interface

Os componentes em `frontend/src/components` formam a base compartilhada. Os módulos em `frontend/src/app/(fintrack)` conservam regras financeiras, consultas, permissões e validação. Priorize blocos shadcnblocks Pro quando um bloco existente satisfizer o contrato e preservar o design; consulte discovery conforme `frontend/AGENTS.md` antes de adicionar UI. Não substitua DataTable, ZoomDatePicker ou TagSelector apenas pela origem de um bloco.

## Catálogo canônico

| Necessidade | Componente / fonte | Contrato e consumidores |
| --- | --- | --- |
| Coleção desktop/mobile | `data-table/data-table.tsx`, `data-table-column-header.tsx`, `data-table-pagination.tsx` | Uma coleção TanStack: ordenação tri-state e `aria-sort`, controle Ordenar no mobile, seleção por ID estável, resumo distinguindo total remoto e carregados. Transações, importação, Patrimônio e tabelas de Workspace compartilham esse contrato. |
| Paginação | `lib/table-config.ts`, `table-pagination.tsx` | Default compartilhado 20 (configurável por `NEXT_PUBLIC_TABLE_PAGE_SIZE`), opções transacionais maiores e escolhas persistidas preservadas. Total servidor não é quantidade carregada. |
| Dia civil / competência | `zoom-date-picker-input.tsx`, `lib/date-utils.ts`, `lib/timezone.ts` | Data completa e seleção acessíveis, foco roving e setas/Home/End/PageUp/PageDown; dia civil não muda com fuso. Instantes usam helper próprio. Preservar MonthInvoicePicker, pois apresenta faturas/status por competência. |
| Busca por termos | `multi-term-search.tsx`, `lib/search-terms.ts` | Enter/vírgula/blur, remoção, Backspace e deduplicação. Modo local ou `inputValue/onInputValueChange`; importação controla e persiste o rascunho por sessão. `ariaLabel` identifica a busca. Sem regras de importação no componente. |
| Painel de filtros | `filter-sheet.tsx` | Header/footer fixos, corpo rolável, `applyMode` explícito. Contas/Importação são imediatos; Editor usa rascunho/validação e Aplicar filtros. A shell não aplica nem limpa filtros por conta própria. |
| Seleção de tags | `financial/tag-selector.tsx` | UI pura: busca, múltipla seleção, criação opcional; tags inativas associadas continuam removíveis. Filtros não criam tags. |
| Dados/criação de tags | `financial/use-transaction-tags.ts`, `transaction-tag-field.tsx` | Adapter do cache compartilhado para formulários de transação, recorrência e staged; captura contexto antes do await e rejeita publicação tardia após trocar workspace/sessão. Não manter cópia local snake_case. |
| Indicadores | `metric-card.tsx`; `stats-card6.tsx` para breakdown | `title/value` obrigatórios, apresentação sem cálculo, densidade e tom explícitos, indisponível distinto de zero. Dashboard, metas, orçamento, carteira, importação e transações usam MetricCard. Valor e sinal permanecem juntos e acessíveis com quantias longas. |
| Série vazia | `app/(fintrack)/dashboard/components/chart-empty-state.tsx` | Série de comprimento zero explica período/condição; série válida com valor zero continua gráfico. Loading e erro pertencem à consulta. |
| Confirmação destrutiva | `deletion-impact-dialog.tsx` | Preview, conflitos, destino e confirmação permanecem no domínio; não trocar por confirmação simples sem esses requisitos. Alteração de moeda tem confirmação própria já adaptada de bloco Pro. |
| Shell global | `layout/header.tsx`, `app-sidebar.tsx`, `mobile-bottom-nav.tsx` | Header também nas rotas de lista/detalhe de Patrimônio. Filtros, ações e calendário devem caber no viewport e oferecer nomes acessíveis. |

As novas composições leves (FilterSheet/MetricCard/adapter de tags) evoluem os componentes instalados. Na implementação de 20/10 o discovery MCP de registry não estava disponível; não houve instalação nem recriação de blocos presumidos. Ao disponibilizar o registry, compare capacidades e regressões antes de substituir a composição.

## Campos, erros e estados

Associe Label ao `id` do controle real, inclusive trigger de Select/ZoomDatePicker/MonthInvoicePicker; placeholders não substituem nome acessível. Erro usa `aria-invalid` e `aria-describedby` com mensagem estável. Dialog/Sheet mantêm foco, Escape e ação final alcançável por scroll/teclado. Não converter falha financeira em zero ou lista vazia: use indisponibilidade e recuperação localizada.

Mutação captura identidade de usuário, workspace e geração da sessão no início; antes de publicar no Zustand ou em estado local, valida o token de contexto. Guards de GET ou limpeza de QueryClient não protegem uma resposta de escrita tardia por si só. Reuse `captureCacheMutationContext/assertCacheMutationContext` de `services/data-cache.ts`.

## Ícones e padrões visuais

Use os catálogos Tabler existentes para categorias, contas e navegação de domínio; preserve IDs de ícones persistidos. Ações dos componentes usam o conjunto já adotado por essa família (Lucide nas primitivas compartilhadas). Radix continua onde faz parte da primitiva. Tamanho e cor seguem tokens/classes da superfície; evite acrescentar uma segunda família na mesma ação só por preferência. Não remover bibliotecas por suposto custo sem medição de bundle e consumidores.

Reutilize variantes semânticas e slots; mantenha fórmulas, moeda e sinais no domínio. Comparações visuais devem incluir claro/escuro, phone/desktop, zero, negativo, valor longo, indisponível, loading e erro. O [inventário de páginas](../product/coverage.md) inclui rotas fora do menu.

## Verificação

Jest cobre contratos de tabela, busca, filtros, cache, tags, indicadores, datas e formulários. Playwright usa API fictícia para jornadas e responsividade; nenhuma suíte deve apontar ao banco compartilhado. Consulte comandos de gate no README/CONTRIBUTING do frontend; resultados datados ficam nos artefatos de revisão, não como uma permissão permanente para checks vermelhos.
