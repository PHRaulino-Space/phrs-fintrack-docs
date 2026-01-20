# Estrutura do Projeto Backend

O projeto segue o layout padrão de projetos Go (Standard Go Project Layout).

## Diretórios Principais

- `cmd/`: Main applications.
- `internal/`: Código privado da biblioteca.
    - `controller/`: Camada de transporte HTTP.
    - `usecase/`: Lógica de negócio.
    - `entity/`: Modelos de domínio.
    - `infra/`: Implementações externas (ex: Auth Providers).
- `pkg/`: Código de biblioteca que pode ser usado por apps externos (OK para importar).
    - `postgres/`: Configuração de conexão DB.
    - `logger/`: Log estruturado.
- `docs/`: Documentação Swagger e SQL.
- `config/`: Carregamento de configuração (YAML/Env).
- `migrations/`: Scripts de migração de banco (se aplicável).

## Fluxo de Dependência

A regra de ouro é: **Dependências apontam para dentro**.
- Controller depende de UseCase.
- UseCase depende de Entity e Interfaces de Repositório.
- Repository (implementação) depende de Interfaces.

Nunca importe `controller` dentro de `entity`.
