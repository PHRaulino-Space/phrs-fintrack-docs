# Casos de uso

Regras de negócio e orquestração ficam em backend/internal/usecase, com contratos em interfaces.go e arquivos *_contracts.go. Um caso de uso pode consultar múltiplos repositórios, validar workspace, status e período, ou pedir uma transação atômica. Saldos do extrato são calculados em modelo de leitura; não existe uma única entidade física Transaction que todos os fluxos atualizam.

Veja o [mapa de domínio](../product/domain-map.md) e as [jornadas](../product/index.md) para saber qual caso de uso produz cada efeito. Use testes de unidade e integração para confirmar arredondamentos e falhas, sem copiar pseudocódigo antigo como comportamento implementado.

Fontes: backend/internal/usecase, backend/internal/entity, backend/internal/infra/postgres/repository.
