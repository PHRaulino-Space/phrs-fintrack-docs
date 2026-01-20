# Migrações

O FinTrack utiliza scripts SQL puros ou ferramentas de migração (como `golang-migrate`) para evoluir o esquema do banco.

*(Nota: Baseado na estrutura atual, o schema parece ser gerenciado via dump SQL. Em um ambiente de produção evolutivo, recomendamos a adoção de uma ferramenta de migração versionada).*

## Histórico

Atualmente, o estado do banco é definido pelo arquivo `backend/docs/fintrack_schema.sql`.

Para aplicar alterações:
1.  Modifique o schema localmente.
2.  Gere um novo dump ou crie um script `ALTER TABLE`.
3.  Aplique no banco.

## Estratégia Recomendada

Para futuras versões, adotaremos:
- `000001_init_schema.up.sql`
- `000002_add_user_preferences.up.sql`
