# Componentes Frontend

O FinTrack utiliza uma biblioteca de componentes baseada em **Shadcn UI**.

## Botões (`components/ui/button.tsx`)

Botões padronizados com variantes (default, destructive, outline, secondary, ghost, link).

```tsx
<Button variant="outline" size="sm" onClick={handleClick}>
  Cancelar
</Button>
```

## Formulários (`components/ui/form.tsx`)

Usamos `react-hook-form` com `zod` para validação de esquemas.

```tsx
const form = useForm<z.infer<typeof formSchema>>({
  resolver: zodResolver(formSchema),
})

<Form {...form}>
  <form onSubmit={form.handleSubmit(onSubmit)}>
    <FormField control={form.control} name="username" ... />
  </form>
</Form>
```

## Data Tables (`components/ui/table.tsx`)

Tabelas poderosas usando `@tanstack/react-table` para listagens de transações, com suporte a ordenação, filtros e paginação.

## Layout (`components/layout`)

- **Sidebar**: Navegação principal colapsável.
- **Header**: Barra superior com perfil e troca de tema.
