# Documentação FinTrack (Docusaurus)

Este diretório contém a documentação técnica gerada com Docusaurus.

## Como Publicar no GitHub Pages

A configuração já foi realizada. Para que a documentação fique online:

1.  **Workflow Automático**: Um arquivo `.github/workflows/deploy-docs.yml` foi criado. Toda vez que você fizer push na `main` alterando a pasta `gh-docs/`, o GitHub Actions irá construir o site e publicar na branch `gh-pages`.

2.  **Configuração do Repositório**:
    - Vá na aba **Settings** do seu repositório no GitHub.
    - No menu lateral esquerdo, clique em **Pages**.
    - Em **Build and deployment**, selecione **Deploy from a branch**.
    - Em **Branch**, selecione `gh-pages` e a pasta `/ (root)`.
    - Clique em **Save**.

Após alguns minutos, sua documentação estará acessível em:
`https://phraulino-space.github.io/fintrack/`

## Rodando Localmente

```bash
npm install
npm start
```
Acesse `http://localhost:3000`.

## Estrutura

- `docs/`: Arquivos Markdown da documentação.
- `src/`: Componentes React e páginas customizadas.
- `docusaurus.config.js`: Configurações principais.
