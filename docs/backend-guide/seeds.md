# Seeds e dados sintéticos

O backend contém rotas administrativas para aplicar categorias padrão e gerar treinamento sintético. Elas ficam em backend/internal/controller/http/v1/admin.go e são cobertas por casos de uso/testes. São operações de escrita e exigem autorização de administrador; não fazem parte da consulta normal nem desta revisão documental.

A tarefa de preparar um workspace de demonstração e seus dados é separada. Esta documentação não fornece comando para disparar seed, criar saldos ou duplicar esse trabalho. Para contrato HTTP, veja [API administrativa](../api-simple/admin.md). Para fluxo de usuário, comece por [acesso e taxonomia](../product/access-categories-tools.md).
