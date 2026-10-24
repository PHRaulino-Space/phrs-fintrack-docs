---
title: MFA, prova recente e recuperação
---

# MFA: estado, instante de prova e consumo único

A correção de segurança de 23/10/2026 mantém o fator ativo durante chamadas de setup, preserva a comprovação real entre renovações de sessão e recusa acesso quando não é possível consultar o estado MFA. Nenhuma credencial, fator ou sessão real foi alterada durante a implementação.

## Gates de acesso

Quando há fator ativo, o token de acesso precisa declarar MFA verificado e uma prova temporal válida, posterior ou igual à ativação do fator atual. Uma sessão criada antes da ativação não passa a comprovar o novo fator apenas por conter `mfa_verified=true`. Prova ausente ou futura também não libera acesso. Operações sensíveis exigem ainda prova nos últimos cinco minutos.

A ausência de registro MFA significa fator desativado. Um erro de armazenamento é distinto: os middlewares respondem `503` e não executam o handler protegido. Login e vínculo OAuth também recusam continuar quando o estado é desconhecido. A exceção existente de chaves de API permanece explícita, sujeita aos próprios escopos e à associação ao workspace.

## Refresh não é uma nova prova

`refresh_tokens.mfa_verified_at` guarda o instante original da autenticação. A rotação transacional recebe o token consumido, propaga esse instante para o substituto e emite o acesso com a mesma prova. Não atualiza a janela de cinco minutos. O JWT mantém o claim Unix de compatibilidade e também uma representação RFC3339 com precisão suficiente para comparar a prova com a ativação do fator.

Sessões antigas cuja coluna é nula não recebem um horário inferido nem uma prova fabricada: o novo acesso conserva a ausência de comprovação. Se o usuário tem MFA ativo, deve verificar novamente o fator. O mecanismo existente de uso único, tolerância limitada a duplicatas recentes de rotação e revogação diante de replay tardio não foi substituído.

A migração aditiva está em `backend/internal/infra/dbsetup/migrations/20261023_refresh_mfa_proof.sql`. O caminho de AutoMigrate também conhece a coluna pela entidade. **Não foi executada migração nem acessado banco real nesta mudança**; publicação de schema e aplicação precisa ser coordenada separadamente.

## Setup e confirmação

Setup não é um mecanismo de substituição do fator ativo. Uma chamada quando o MFA já está habilitado retorna conflito e mantém segredo e ativação atuais. A persistência do setup só permite inserir ou atualizar estado pendente com `enabled_at IS NULL`; uma ativação concorrente impede que outro setup a sobrescreva.

A confirmação invalida atomicamente o lote de recuperação do fator anterior ao ativar o novo, eliminando a janela entre ativação e geração dos novos códigos. Só ativa o segredo pendente efetivamente validado: a atualização condiciona usuário, segredo cifrado esperado e estado ainda pendente. Não renova nem troca um fator ativo. Após confirmar o OTP pendente e salvar o lote de recuperação, o HTTP emite novos cookies com prova do fator recém-ativado; a sessão anterior à ativação não é reutilizada como prova. Para cadastrar outro fator pelo fluxo existente é necessário desativar o atual com a comprovação exigida e então iniciar outro cadastro. Uma futura troca sem desativação requer jornada própria e não foi introduzida aqui.

## Códigos de recuperação

A validação consome o código com uma única atualização condicionada ao usuário, hash e `used_at IS NULL`. Duas chamadas concorrentes não recebem dois sucessos para o mesmo código. Regeneração substitui o lote em uma transação; bloqueia o proprietário para serializar regenerações concorrentes. Falha ao criar o novo lote reverte a exclusão do anterior.

Os códigos continuam armazenados por hash; o texto só aparece na geração. A política atual de validação TOTP por janela da biblioteca não foi transformada em uma política nova de consumo por contador. Redis não participa desses caminhos de MFA; o risco reproduzido de falha aberta era a consulta de estado, e o risco de consumo concorrente estava no repositório PostgreSQL de recuperação.

## Evidência e limites

- Regressões de setup ativo e falha seletiva de consulta foram executadas antes da correção e falharam, comprovando o comportamento anterior.
- Testes unitários cobrem preservação da prova no refresh, legado sem prova, lookup ausente versus falha, recusa de novo setup/confirm em fator ativo, consumo concorrente por porta atômica e gates HTTP com falha seletiva ou prova anterior à ativação.
- Teste PostgreSQL isolado cobre setup protegido, ativação condicionada, dois consumos concorrentes e regenerações completas. Nesta implementação ele foi compilado, sem executar banco ou containers.
- O campo `mfa_verified_at` de `/settings/security` continua representando a data de habilitação na resposta legada; não deve ser usado como prova recente da sessão. O gate usa exclusivamente os claims validados e o estado do fator.

## Credenciais e revogação na mesma transação

A correção de IDN-003 abrange alteração de senha, confirmação de e-mail pendente, desvinculação OAuth e desativação do MFA. Desativar o fator e revogar seus refresh tokens usa uma transação com comparação do segredo e da ativação esperados; se a revogação falha, o fator continua ativo. Uma regressão unitária reproduziu a desativação parcial anterior e comprova o rollback pelo novo contrato atômico. O gerenciador de autenticação fornece repositórios de usuário, identidade, workspace, membro, refresh e verificação de e-mail vinculados à mesma transação. Leituras de usuário nessa fronteira usam bloqueio de linha, na mesma ordem de proprietário adotada pela rotação de refresh.

A senha é verificada e o novo hash é calculado antes de abrir a transação; sob bloqueio, o caso de uso relê o usuário e compara o hash anterior para rejeitar uma mudança concorrente. Atualização e revogação de refresh só são efetivadas juntas. Notificação ocorre depois do commit.

Confirmação de e-mail relê o token depois de bloquear o usuário, aplica a alteração, revoga as sessões quando troca o endereço e consome o token condicionalmente em uma transação. Falha em qualquer etapa reverte todas. Cancelar o endereço pendente invalida seus tokens na mesma transação que limpa o endereço pendente. Login e vínculo OAuth também usam o refresh repository da transação quando aplicam um e-mail pendente. Desvinculação e revogação são atômicas; não foi introduzida uma política nova sobre retirar o último método de autenticação.

Quatro regressões foram reproduzidas contra a lógica anterior com mocks: senha persistida após erro de revogação, e-mail atualizado antes de erro no consumo do token, identidade removida antes de erro de revogação e revogação fora da transação durante rollback OAuth. Os mesmos testes passam no código atual, junto da matriz de sucesso e falhas de atualização, revogação, consumo e commit.

A validade dos access JWT já emitidos continua limitada pelo TTL existente; revogar refresh não equivale a criar uma lista de bloqueio de access tokens. A política de último método de login continua uma decisão separada. Testes de rollback com mocks não substituem a execução das integrações PostgreSQL: elas foram apenas compiladas nesta etapa, sem acessar banco ou executar migrações.

## Desativação e atualizações concorrentes de perfil

Desativar MFA e revogar refresh tokens são uma única transação, com lock do usuário e comparação da versão real do fator (segredo/instante de ativação). Falha na revogação reverte a desativação; um fator substituído durante a verificação não é desativado pela prova anterior. A atualização de avatar usa a transação de autenticação e relê o usuário sob lock antes de salvar, evitando sobrescrever senha nova com um perfil lido anteriormente ou reativar usuário excluído. Nenhuma configuração MFA real é alterada por testes. Fontes: `MFAService.DisableMFA`, `MFARepo.DisableAndRevoke`, `EmailVerificationService.UpdateUserAvatar`.
