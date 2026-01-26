# Fluxo Git

Utilizamos um fluxo baseado em **Feature Branches**.

## Branches Principais

- `main`: Código de produção estável.
- `develop` (opcional): Branch de integração para next release.

## Criando uma Feature

1.  Atualize a main: `git checkout main && git pull`.
2.  Crie sua branch: `git checkout -b feature/nova-funcionalidade`.
3.  Desenvolva e commite.
4.  Push: `git push origin feature/nova-funcionalidade`.
5.  Abra um **Pull Request** para a `main`.

## Submódulos

Lembre-se que `frontend` e `backend` são submódulos.
- Se você alterar algo dentro de `backend/`, precisará commitar lá dentro primeiro, dar push no repositório do backend, e depois atualizar a referência no repositório principal (root).

```bash
# No backend
git add .
git commit -m "feat: new endpoint"
git push

# No root
git add backend
git commit -m "chore: update backend submodule"
```
