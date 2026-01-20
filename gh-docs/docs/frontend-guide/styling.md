# Estilização

O estilo visual é 100% **Tailwind CSS**.

## Princípios

- **Utility-First**: Escreva classes diretamente no JSX.
- **Theming**: As cores (primary, secondary, accent) são definidas em variáveis CSS no `globals.css` e mapeadas no `tailwind.config.ts`. Isso facilita a troca entre Light e Dark Mode.
- **Responsividade**: Use prefixos `md:`, `lg:` para adaptar layouts.

Exemplo:
```tsx
<div className="flex flex-col md:flex-row gap-4 p-4 bg-muted/50 rounded-xl">
  ...
</div>
```

## Dark Mode

O suporte a tema escuro é nativo via `next-themes`. A classe `dark` é aplicada ao elemento `html`, e as variáveis CSS ajustam as cores automaticamente.
