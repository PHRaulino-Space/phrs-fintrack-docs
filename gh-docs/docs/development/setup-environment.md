# Setup do Ambiente

Para desenvolver no FinTrack, você precisará de um ambiente consistente. Recomendamos Linux ou macOS (ou WSL2 no Windows).

## Ferramentas Necessárias

- **VS Code**: Editor recomendado. O projeto inclui configurações de workspace (`fintrack-docs.code-workspace`).
- **Go 1.22+**: Para o backend.
- **Node.js 20+**: Para o frontend.
- **Docker**: Para rodar o banco de dados.
- **Make**: Para rodar scripts de automação.

## Extensões do VS Code

Recomendamos as seguintes extensões (já listadas no `.vscode/extensions.json` se houver):
- **Go**: Suporte oficial da Google.
- **ESLint / Prettier**: Para o frontend.
- **Tailwind CSS IntelliSense**: Autocomplete de classes.
- **SQLTools**: Para acessar o banco de dados direto do editor.

## Clonando o Projeto

```bash
git clone https://github.com/PHRaulino-Space/fintrack.git
cd fintrack
bash install-submodules.sh
```

Isso baixará o código principal e os submódulos `frontend` e `backend`.
