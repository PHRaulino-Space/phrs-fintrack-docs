# Testes Frontend

Atualmente focamos em testes de unidade e testes de componentes.

## Ferramentas
- **Jest**: Runner de testes.
- **React Testing Library**: Para renderizar componentes e interagir com o DOM virtual.

## O que testar?
- Renderização correta de componentes com props diferentes.
- Interações do usuário (cliques, digitação).
- Validação de formulários.
- Hooks customizados complexos.

## Exemplo

```tsx
test('renders login button', () => {
  render(<LoginForm />)
  const button = screen.getByRole('button', { name: /entrar/i })
  expect(button).toBeInTheDocument()
})
```
