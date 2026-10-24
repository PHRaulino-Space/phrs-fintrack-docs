---
title: Instante de avaliação dos investimentos
---

# Saldo informado é uma posição no instante efetivo

Uma atualização de saldo informa uma **posição absoluta naquele instante**, não o fechamento do dia e nem um aporte. A posição seguinte é o último saldo informado, acrescido dos aportes e diminuído dos resgates **posteriores** a ele. Movimentos anteriores já estão contidos na posição informada e não são reaplicados. Não existe conversão de moedas neste cálculo; aplica-se também a [política de moedas](./currency-policy.md).

Exemplo fictício: aporte de 100 às 09h; avaliação absoluta de 1.000 às 10h; aporte de 50 às 11h; resgate de 20 às 12h. A posição após 12h é 1.030. O aporte das 09h continua no histórico de fluxos para cálculo de resultado, mas não é somado novamente aos 1.000. Um movimento exatamente no instante da avaliação é considerado já contido nela. Entre avaliações com o mesmo instante, a cadastrada mais recentemente prevalece, com desempate determinístico por ID.

## Contrato temporal

- Novas avaliações e novos aportes/resgates manuais via API/MCP devem informar `effective_at`, um instante RFC3339 com offset explícito. `transaction_date` ou `updated_at_date` continua como dia civil e deve corresponder ao instante em `America/Sao_Paulo`, o fuso contábil atual do backend.
- O frontend permite informar o instante real junto do dia. A hora inicial sugerida para um registro de hoje não substitui a conferência do usuário; registros retroativos precisam de horário efetivo conhecido.
- Carteira, resumo de investimento e metas usam o mesmo cálculo temporal. Consultas de um período fechado usam o fim do dia civil; consultas atuais respeitam o instante de corte e não incluem movimentos futuros apenas porque estão no mesmo dia.
- Aportes e resgates de outra conta da **mesma moeda** entram na posição do investimento. A consulta de avaliação vincula os movimentos pelo investimento e sua conta proprietária, sem limitar a origem/destino bancário à conta proprietária.
- Editar valor ou dia de um movimento legado exige informar o instante real. Uma edição de metadados que mantém dia e valor não atribui horário a um registro antigo.

## Histórico antigo e precisão ausente

O modelo anterior persistia apenas `DATE`. O campo aditivo `effective_at` é nullable e não recebe preenchimento automático. `created_at` é o momento do cadastro; não prova quando ocorreu o evento financeiro. Importações que só conhecem o dia conservam essa precisão.

Avaliações antigas sem horário preservam a interpretação civil anterior: incluem os fluxos do mesmo dia. Essa compatibilidade não prova a ordem intradiária do legado. Se uma avaliação com instante explícito encontra um movimento sem horário no mesmo dia, não há informação suficiente para ordenar os dois. O mesmo ocorre entre avaliações com e sem horário no mesmo dia relevante. O cálculo retorna HTTP 400 com mensagem de ambiguidade temporal, sem inventar posição numérica ou atribuir horário ao legado.

Para resolver uma ambiguidade é preciso comprovar o instante real e corrigir o registro, ou remover e recriar a avaliação com informações verificadas. Não foi autorizada nem executada reparação em massa. Permanecem limitações anteriores fora desta decisão: histórico de composição das metas usa vínculos atuais; o status resgatado não possui data própria de encerramento e depende dos movimentos registrados.

## Preparação do banco e validação

As entidades adicionam `effective_at` em `investment_value_history`, `investment_deposits` e `investment_withdrawals`. A migração SQL aditiva está em `backend/internal/infra/dbsetup/migrations/20261023_investment_effective_at.sql`; o caminho existente de AutoMigrate também conhece as novas colunas pelas entidades. O aplicativo não executa migração no startup.

**A migração não foi executada nesta implementação.** O ambiente de desenvolvimento compartilha banco com produção. Aplicação e schema precisam ser publicados de forma coordenada após revisão humana; o arquivo não autoriza rodar setup, migração ou alterar dados reais.

Testes isolados cobrem avaliação absoluta, aportes/resgates antes e depois, mesmo dia, instante igual, múltiplas avaliações, cortes históricos, offsets, dia civil e ambiguidade do legado. Esses testes não comprovam uma migração ou leitura real em PostgreSQL; essa etapa depende de banco descartável e autorização apropriada.
