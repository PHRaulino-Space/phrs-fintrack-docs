# FinTrack - Contexto do Projeto

## 1. Visão Geral

FinTrack é um aplicativo web de gestão de finanças pessoais auto-hospedado, projetado para automatizar e simplificar o controle financeiro. O sistema permite que usuários registrem, categorizem e analisem suas transações financeiras de forma inteligente, oferecendo insights sobre gastos, receitas e fluxo de caixa.

### Propósito Central

- Automatizar o processo de registro de transações financeiras
- Eliminar trabalho manual repetitivo na categorização de despesas
- Fornecer visibilidade clara sobre a saúde financeira pessoal
- Permitir gestão multi-contexto (pessoal, familiar, empresarial)

### Diferenciais

- **Auto-hospedado**: Controle total sobre os dados financeiros
- **Inteligência Artificial Integrada**: Categorização automática usando modelos de linguagem
- **Multi-tenant**: Suporte para múltiplos contextos financeiros isolados
- **Segurança**: Acesso via rede privada sem exposição pública

-----

## 2. Problema que Resolve

### Dores Identificadas

1. **Registro Manual é Tedioso**: Inserir transações uma por uma consome tempo e é propenso a erros
2. **Categorização Inconsistente**: Sem padrão, a mesma despesa pode ser categorizada diferentemente
3. **Falta de Visibilidade**: Dados espalhados dificultam o entendimento do panorama financeiro
4. **Privacidade**: Soluções comerciais exigem compartilhamento de dados bancários sensíveis

### Solução Proposta

- Importação em lote via arquivos CSV exportados de bancos
- Categorização inteligente baseada em histórico e padrões
- Dashboard centralizado com múltiplas visualizações
- Hospedagem privada com acesso seguro remoto

-----

## 3. Usuários e Casos de Uso

### Perfil de Usuário

- Pessoas que buscam controle detalhado sobre finanças pessoais
- Usuários com conhecimento técnico básico para auto-hospedagem
- Indivíduos que valorizam privacidade de dados
- Pessoas que gerenciam múltiplos contextos financeiros (pessoal + família, freelancer + empresa)

### Casos de Uso Principais

#### 3.1. Importação de Transações

**Ator**: Usuário com extrato bancário
**Objetivo**: Registrar dezenas de transações rapidamente
**Fluxo**:

1. Exportar extrato do banco em formato CSV
2. Fazer upload do arquivo no FinTrack
3. Revisar sugestões automáticas de categorização
4. Ajustar manualmente transações que precisam de atenção
5. Confirmar importação para registro definitivo

#### 3.2. Categorização Inteligente

**Ator**: Sistema (automático)
**Objetivo**: Reduzir trabalho manual do usuário
**Fluxo**:

1. Receber descrição bruta da transação (ex: "SUPERMERCADO XYZ LTDA 123")
2. Padronizar descrição (ex: "Supermercado XYZ")
3. Sugerir categoria (ex: "Alimentação")
4. Sugerir subcategoria (ex: "Supermercado")
5. Calcular nível de confiança da sugestão

#### 3.3. Gestão Multi-Workspace

**Ator**: Usuário com múltiplos contextos financeiros
**Objetivo**: Separar finanças pessoais de familiares/empresariais
**Fluxo**:

1. Criar workspaces distintos (ex: "Pessoal", "Família")
2. Alternar entre contextos conforme necessário
3. Visualizar dados isolados por workspace
4. Compartilhar workspaces com outros usuários (com permissões)

#### 3.4. Análise e Acompanhamento

**Ator**: Usuário buscando insights
**Objetivo**: Entender padrões de gastos
**Fluxo**:

1. Acessar dashboards com visualizações gráficas
2. Filtrar por período, categoria, conta
3. Identificar tendências e anomalias
4. Exportar relatórios personalizados

-----

## 4. Modelo de Dados Conceitual

### Entidades Principais

#### Workspaces

Contextos isolados de dados financeiros. Cada usuário pode ter acesso a múltiplos workspaces com diferentes níveis de permissão (Admin ou Membro).

#### Contas (Accounts)

Representam onde o dinheiro está guardado:

- Contas bancárias
- Investimentos
- Carteiras digitais
- Dinheiro em espécie

Cada conta possui saldo, moeda e tipo.

#### Cartões de Crédito (Cards)

Meios de pagamento com características especiais:

- Limite de crédito
- Data de fechamento da fatura
- Data de vencimento
- Vinculação a uma conta para débito da fatura

#### Categorias e Subcategorias

Sistema hierárquico para classificar transações:

- **Categoria**: Agrupamento amplo (ex: Alimentação, Transporte, Moradia)
- **Subcategoria**: Detalhamento específico (ex: Restaurante, Supermercado, Delivery)

#### Tags

Etiquetas transversais para análises customizadas (ex: "Trabalho", "Viagem", "Saúde").

#### Transações

Movimentações financeiras que podem ser de vários tipos:

- **Receitas**: Entradas de dinheiro (salário, freelance, investimentos)
- **Despesas**: Saídas debitadas de contas
- **Despesas de Cartão**: Compras no crédito
- **Transferências**: Movimentação entre contas próprias

Cada transação possui data, valor, descrição, categoria e entidades relacionadas.

#### Sessões de Importação

Ambiente temporário onde transações importadas aguardam revisão antes de se tornarem definitivas. Funciona como uma "área de staging".

#### Transações Temporárias (Staged Transactions)

Versão provisória de transações dentro de uma sessão de importação. Podem ser editadas, enriquecidas e aprovadas antes do commit final.

-----

## 5. Jornadas do Usuário

### 5.1. Primeira Utilização

1. Criar conta no sistema
2. Criar primeiro workspace (ex: "Finanças Pessoais")
3. Cadastrar contas bancárias e cartões de crédito
4. Configurar categorias e subcategorias personalizadas
5. Fazer primeira importação de extrato

### 5.2. Rotina Mensal

1. Acessar sistema via rede segura
2. Exportar extratos do mês dos bancos
3. Criar nova sessão de importação
4. Fazer upload dos arquivos CSV
5. Revisar sugestões automáticas
6. Ajustar transações com baixa confiança
7. Confirmar importação
8. Analisar dashboards atualizados
9. Identificar oportunidades de economia

### 5.3. Gestão Compartilhada

1. Criar workspace familiar (ex: "Casa - João e Maria")
2. Convidar cônjuge/parceiro
3. Definir permissões (Admin vs Membro)
4. Ambos importam suas transações pessoais
5. Visualizar consolidado das finanças do casal
6. Tomar decisões informadas sobre orçamento

-----

## 6. Fluxo de Importação Detalhado

### Fase 1: Upload

- Usuário seleciona arquivo CSV do computador
- Sistema valida formato do arquivo
- Cria sessão de importação vinculada a uma conta ou cartão
- Faz parsing do CSV e extrai colunas relevantes

### Fase 2: Processamento e Enriquecimento

- Para cada linha do CSV:
  - Extrai data, descrição e valor
  - Envia descrição para modelo de IA
  - Recebe sugestões de categorização
  - Cria transação temporária com sugestões pré-preenchidas
  - Atribui nível de confiança à sugestão

### Fase 3: Revisão Humana

- Usuário visualiza lista de transações temporárias
- Interface destaca transações que precisam de atenção (baixa confiança)
- Usuário pode:
  - Aceitar sugestão automaticamente
  - Editar descrição
  - Alterar categoria/subcategoria
  - Adicionar tags
  - Marcar como "pronta" para commit

### Fase 4: Commit

- Usuário confirma importação da sessão
- Sistema valida todas as transações marcadas como "prontas"
- Move dados de transações temporárias para registro definitivo
- Atualiza saldos de contas
- Vincula despesas de cartão às faturas correspondentes
- Marca sessão como concluída

-----

## 7. Inteligência Artificial no Sistema

### Objetivo

Reduzir fricção no processo de categorização, aprendendo com o histórico do usuário.

### Como Funciona

1. **Entrada**: Descrição bruta da transação (ex: "PAG*JoaoSilva PIX")
2. **Processamento**: Modelo local analisa padrões
3. **Saída**:
   - Descrição padronizada
   - Categoria sugerida
   - Subcategoria sugerida
   - Tags relacionadas
   - Nível de confiança (0-1)

### Aprendizado Contínuo

- Quanto mais o usuário corrige sugestões, mais o sistema aprende
- Padrões específicos do usuário são incorporados
- Modelo roda localmente, garantindo privacidade total

-----

## 8. Segurança e Privacidade

### Princípios

- **Dados Próprios**: Usuário é dono absoluto de suas informações
- **Zero Conhecimento Externo**: Nenhum dado sai do ambiente controlado
- **Acesso Privado**: Sistema não fica exposto à internet pública
- **Isolamento por Contexto**: Workspaces garantem separação total de dados

### Mecanismos

- Autenticação com senha ou via provedores confiáveis
- Comunicação criptografada ponta a ponta
- Rede virtual privada para acesso remoto
- Controle de permissões granular por workspace

-----

## 9. Arquitetura de Alto Nível

### Componentes

#### Interface Web

- Dashboard responsivo acessível de qualquer dispositivo
- Componentes visuais modernos e intuitivos
- Formulários inteligentes com validação em tempo real

#### Servidor de Aplicação

- Gerencia lógica de negócio
- Processa requisições da interface
- Orquestra comunicação entre componentes

#### Banco de Dados

- Armazena todas as informações financeiras
- Garante integridade e consistência dos dados
- Otimizado para consultas analíticas

#### Serviço de Inteligência Artificial

- Modelo de linguagem rodando localmente
- Processa descrições de transações
- Retorna sugestões de categorização

#### Infraestrutura

- Sistema de orquestração de serviços
- Rede privada virtual para acesso seguro
- DNS interno para resolução de nomes
- Pipeline de deploy automatizado

-----

## 10. Estado Atual do Projeto

### O Que Já Existe

- Infraestrutura completa configurada e operacional
- Banco de dados estruturado com histórico financeiro
- Dashboards de visualização funcionais
- Sistema de autenticação implementado
- Gestão de workspaces com controle de acesso
- Fluxo de sessões de importação definido
- Modelo de IA local em execução

### Ponto de Dor Atual

O processo de inserção de dados ainda é manual e trabalhoso, sem aproveitar todo o potencial da IA disponível.

### Próxima Fase

Integrar o modelo de IA ao fluxo de importação para enriquecer automaticamente as transações, transformando o upload de CSV em um processo semi-automático que requer mínima intervenção humana.

-----

## 11. Visão de Futuro

### Funcionalidades Planejadas

- **Orçamentos**: Definir limites por categoria e receber alertas
- **Metas Financeiras**: Acompanhar progresso de objetivos de economia
- **Reconciliação Bancária**: Validar saldos contra extratos oficiais
- **Relatórios Personalizados**: Criar visualizações customizadas
- **Análise Preditiva**: Projetar gastos futuros baseado em histórico
- **Integração com Bancos**: Importação automática via Open Banking
- **Aplicativo Mobile**: Acesso nativo para iOS e Android
- **Notificações**: Alertas de gastos incomuns ou orçamento estourado

### Evolução da IA

- Detecção de anomalias (gastos fora do padrão)
- Sugestões proativas de economia
- Reconhecimento de despesas recorrentes
- Categorização multi-label (uma transação, várias tags)

-----

## 12. Métricas de Sucesso

### Eficiência

- **Tempo de importação**: Reduzir de 30min para <5min por extrato
- **Taxa de acerto da IA**: >85% de sugestões corretas sem intervenção
- **Transações por sessão**: Suportar uploads de 100+ transações

### Adoção

- **Frequência de uso**: Usuário acessa semanalmente
- **Retenção**: Continua usando após 3 meses
- **Workspaces ativos**: Média de 2+ contextos por usuário

### Qualidade dos Dados

- **Completude**: >95% das transações categorizadas
- **Consistência**: Mesma despesa sempre na mesma categoria
- **Acurácia**: Saldo calculado = saldo real do banco

-----

## 13. Considerações Operacionais

### Hospedagem

Sistema roda em hardware próprio, mantendo custo operacional próximo de zero após investimento inicial em equipamento.

### Manutenção

- Backups automáticos do banco de dados
- Atualizações de segurança aplicadas via pipeline
- Monitoramento de saúde dos serviços

### Escalabilidade

Arquitetura preparada para migração futura para nuvem caso o volume de dados ou número de usuários cresça além da capacidade do hardware atual.

-----

## 14. Conclusão

FinTrack nasceu da necessidade de ter controle total sobre dados financeiros pessoais sem depender de serviços externos. Ao combinar auto-hospedagem, inteligência artificial local e uma interface moderna, o projeto oferece uma solução única que equilibra privacidade, automação e usabilidade.

A fase atual foca em eliminar o maior atrito do sistema - a entrada manual de dados - através da integração profunda entre importação de CSV e categorização inteligente via IA. Com essa fundação sólida, o caminho está aberto para evoluir para uma plataforma completa de gestão financeira pessoal.
