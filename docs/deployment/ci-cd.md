# CI/CD

Integração e Entrega Contínua.

## GitHub Actions

O projeto inclui (ou deve incluir) workflows para:

### Pull Requests (`ci.yml`)
- Roda testes do backend (`go test`).
- Roda linting (`golangci-lint`).
- Roda build do frontend (`npm run build`).

### Release (`deploy.yml`)
- Cria tags Docker.
- Publica no Docker Hub ou GHCR.
- Deploy automático (se configurado via SSH ou Kubernetes).

## Pipeline Exemplo

```yaml
name: CI
on: [push, pull_request]
jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with: { go-version: '1.22' }
      - run: go test ./...

  build-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run build
```
