---
title: Último administrador e exclusão de conta
---

# Membros de workspace e exclusão de usuário são fluxos distintos

A gestão de membros já impede remover ou rebaixar o último `ADMIN` de um workspace. O repositório faz autorização, contagem e alteração na mesma transação, com serialização das associações. Também impede remover a última associação a workspace do membro alvo. Essas proteções existem; não dependem de uma nova escolha de produto nesta implementação.

A função de administrador global do aplicativo é diferente do papel `ADMIN` em um workspace. A exclusão de conta atual recusa usuários com papel global `ADMIN`, mas um usuário comum pode ser administrador de um ou vários workspaces.

## Comportamento atual da exclusão de conta

`AccountDeletionUseCaseImpl.deleteUserCascade` usa as seguintes regras atuais:

| Situação da associação do usuário excluído | Ação atual |
| --- | --- |
| É o único membro do workspace | Apaga o workspace |
| Há outros membros, mas ele é o único ADMIN | **Apaga o workspace compartilhado**, incluindo os dados desse espaço |
| Há outro ADMIN | Remove sua associação; não apaga o workspace por essa regra |
| É MEMBER de um workspace com outros membros | Remove sua associação |

Esse comportamento foi caracterizado com repositórios falsos, sem dados reais. Não constitui aprovação da política de apagar dados compartilhados. A proteção da gestão de membros não deve ser apresentada como solução dessa jornada: excluir o usuário aciona outro código e pode apagar o próprio workspace.

## Decisão necessária para workspace compartilhado

Antes de alterar esse comportamento, é necessário escolher o resultado esperado quando o único administrador exclui a própria conta:

1. **Preservar o workspace e exigir outro administrador antes de concluir a exclusão da conta** — recomendação conservadora; a promoção deve ser uma escolha explícita de quem tem autorização. Não promove automaticamente um membro nem transfere propriedade por inferência.
2. Permitir excluir também o workspace compartilhado, por ação separada que apresente o impacto e obtenha confirmação explícita do workspace. O texto atual sobre apagar “seus dados” não descreve esse alcance.

A escolha afeta a prévia de exclusão, a autorização, a transação de associação e a cascata. Não foi implementada uma transferência ou regra de ownership nova. Também não se atribuiu aos demais membros uma política de consentimento ainda não definida.

## Confirmação e retomada: limites atuais

O pedido `POST /user/delete-request` devolve um token à própria sessão autenticada. O caso de uso não chama mailer; a interface atual anuncia um e-mail e descarta essa resposta. Portanto, esse caminho não comprova posse da caixa de e-mail como segundo canal independente. As rotas herdam o gate MFA comum, mas não usam o grupo de prova recente aplicado a outras operações sensíveis. A decisão de preservar o workspace deve ser acompanhada da definição do canal de confirmação pretendido; não se deve afirmar que já existe confirmação por e-mail.

A confirmação marca o usuário como excluído, consome o token em outra operação e inicia uma goroutine de remoção. Uma falha ou parada do processo pode interromper a cascata; as novas chamadas retornam cedo para um usuário já excluído. Não existe comprovação de retomada durável nesse fluxo. Contagens de membros/administradores e exclusão de workspace também não formam uma única fronteira de decisão nessa cascata. A existência de proteção atômica na gestão normal de membros não garante a mesma propriedade durante exclusões de contas concorrentes.

Esses limites foram documentados e continuam separados da correção dos bugs de MFA, atomicidade de credenciais e isolamento financeiro. Não foi escolhido canal de entrega, política de retenção nem scheduler novo nesta revisão.

## Evidências

- `backend/internal/infra/postgres/repository/workspace_access_postgres.go`: `UpdateMemberRoleAsAdmin`, `RemoveMemberAsAdmin`, `lockWorkspaceMemberships`.
- `backend/internal/usecase/account_deletion.go`: `RequestDeletion`, `ConfirmDeletion`, `startAsyncDeletion`, `deleteUserCascade`.
- `backend/internal/controller/http/v1/user.go`: `newUserRoutes`, `requestAccountDeletion`.
- `frontend/src/app/(fintrack)/settings/profile/components/delete-account-section.tsx`: pedido e texto de confirmação.
- Testes existentes `workspace_access_postgres_integration_test.go` cobrem rebaixamentos concorrentes e remoção do último administrador. Nenhuma execução PostgreSQL foi feita nesta etapa de triagem.
