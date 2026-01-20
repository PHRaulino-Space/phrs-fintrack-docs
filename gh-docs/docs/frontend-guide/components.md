---
sidebar_position: 2
---

# Componentes

O FinTrack usa shadcn/ui como base e componentes customizados para funcionalidades especificas.

## shadcn/ui

Biblioteca de componentes construida sobre Radix UI, totalmente customizavel.

### Componentes Disponiveis

| Componente | Descricao |
|------------|-----------|
| `Accordion` | Conteudo expansivel |
| `Alert` | Mensagens de alerta |
| `AlertDialog` | Dialog de confirmacao |
| `Avatar` | Imagem de perfil |
| `Badge` | Etiquetas |
| `Breadcrumb` | Navegacao hierarquica |
| `Button` | Botoes com variantes |
| `Calendar` | Calendario |
| `Card` | Container com estilo |
| `Checkbox` | Caixa de selecao |
| `Command` | Command palette |
| `Dialog` | Modal |
| `Drawer` | Painel lateral |
| `DropdownMenu` | Menu suspenso |
| `Form` | Formulario com validacao |
| `Input` | Campo de texto |
| `Label` | Rotulo |
| `Pagination` | Paginacao |
| `Popover` | Popup posicionado |
| `Progress` | Barra de progresso |
| `RadioGroup` | Opcoes exclusivas |
| `ScrollArea` | Area com scroll |
| `Select` | Dropdown de selecao |
| `Separator` | Linha divisoria |
| `Sheet` | Painel deslizante |
| `Sidebar` | Barra lateral |
| `Skeleton` | Placeholder de loading |
| `Switch` | Toggle on/off |
| `Table` | Tabela |
| `Tabs` | Abas |
| `Textarea` | Campo de texto longo |
| `Toast` | Notificacao |
| `Tooltip` | Dica ao passar mouse |

### Exemplo de Uso

```typescript
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export function LoginCard() {
  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>Login</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input id="email" type="email" placeholder="seu@email.com" />
          </div>
          <Button className="w-full">Entrar</Button>
        </div>
      </CardContent>
    </Card>
  );
}
```

## Componentes de Layout

### AppSidebar

Sidebar principal com navegacao, seletor de workspace e perfil do usuario.

```typescript
// components/layout/app-sidebar.tsx
import { Sidebar, SidebarContent, SidebarFooter } from '@/components/ui/sidebar';
import { NavGroups } from './nav-groups';
import { NavUser } from './nav-user';
import { TeamSwitcher } from './team-switcher';

export function AppSidebar() {
  return (
    <Sidebar collapsible="icon">
      <SidebarHeader>
        <TeamSwitcher />
      </SidebarHeader>
      <SidebarContent>
        <NavGroups />
      </SidebarContent>
      <SidebarFooter>
        <NavUser />
      </SidebarFooter>
    </Sidebar>
  );
}
```

### TeamSwitcher

Dropdown para alternar entre workspaces.

```typescript
// components/layout/team-switcher.tsx
export function TeamSwitcher() {
  const { workspaces, activeWorkspace, setActiveWorkspace } = useAuth();

  return (
    <DropdownMenu>
      <DropdownMenuTrigger>
        <div className="flex items-center gap-2">
          <Avatar>{activeWorkspace?.name[0]}</Avatar>
          <span>{activeWorkspace?.name}</span>
        </div>
      </DropdownMenuTrigger>
      <DropdownMenuContent>
        {workspaces.map((ws) => (
          <DropdownMenuItem
            key={ws.id}
            onClick={() => setActiveWorkspace(ws)}
          >
            {ws.name}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

## Componentes de Formulario

### Form com React Hook Form

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

const formSchema = z.object({
  email: z.string().email('Email invalido'),
  password: z.string().min(7, 'Minimo 7 caracteres'),
});

type FormData = z.infer<typeof formSchema>;

export function LoginForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: { email: '', password: '' },
  });

  const onSubmit = (data: FormData) => {
    console.log(data);
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="email@exemplo.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Senha</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit" className="w-full">
          Entrar
        </Button>
      </form>
    </Form>
  );
}
```

## Componentes de Data Table

### DataTable com TanStack Table

```typescript
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

interface DataTableProps<TData> {
  columns: ColumnDef<TData>[];
  data: TData[];
}

export function DataTable<TData>({ columns, data }: DataTableProps<TData>) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <Table>
      <TableHeader>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableRow key={headerGroup.id}>
            {headerGroup.headers.map((header) => (
              <TableHead key={header.id}>
                {flexRender(
                  header.column.columnDef.header,
                  header.getContext()
                )}
              </TableHead>
            ))}
          </TableRow>
        ))}
      </TableHeader>
      <TableBody>
        {table.getRowModel().rows.map((row) => (
          <TableRow key={row.id}>
            {row.getVisibleCells().map((cell) => (
              <TableCell key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
              </TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

## Componentes Customizados

### ProtectedRoute

Wrapper para rotas que requerem autenticacao.

```typescript
// components/protected-route.tsx
'use client';

import { useAuth } from '@/hooks/use-auth';
import { useAuthCheck } from '@/hooks/use-auth-check';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  useAuthCheck();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isLoading, isAuthenticated, router]);

  if (isLoading) {
    return <LoadingSkeleton />;
  }

  if (!isAuthenticated) {
    return null;
  }

  return <>{children}</>;
}
```

### DateRangePicker

Componente para selecao de periodo.

```typescript
import { Calendar } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Button } from '@/components/ui/button';
import { CalendarIcon } from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';

interface DateRangePickerProps {
  from?: Date;
  to?: Date;
  onSelect: (range: { from?: Date; to?: Date }) => void;
}

export function DateRangePicker({ from, to, onSelect }: DateRangePickerProps) {
  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button variant="outline" className="w-[280px] justify-start">
          <CalendarIcon className="mr-2 h-4 w-4" />
          {from ? (
            to ? (
              <>
                {format(from, 'dd/MM/yyyy', { locale: ptBR })} -{' '}
                {format(to, 'dd/MM/yyyy', { locale: ptBR })}
              </>
            ) : (
              format(from, 'dd/MM/yyyy', { locale: ptBR })
            )
          ) : (
            'Selecione um periodo'
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0">
        <Calendar
          mode="range"
          selected={{ from, to }}
          onSelect={onSelect}
          numberOfMonths={2}
          locale={ptBR}
        />
      </PopoverContent>
    </Popover>
  );
}
```

### ConfirmDialog

Dialog de confirmacao reutilizavel.

```typescript
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';

interface ConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description: string;
  onConfirm: () => void;
  confirmText?: string;
  cancelText?: string;
  variant?: 'default' | 'destructive';
}

export function ConfirmDialog({
  open,
  onOpenChange,
  title,
  description,
  onConfirm,
  confirmText = 'Confirmar',
  cancelText = 'Cancelar',
  variant = 'default',
}: ConfirmDialogProps) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>{description}</AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>{cancelText}</AlertDialogCancel>
          <AlertDialogAction
            onClick={onConfirm}
            className={variant === 'destructive' ? 'bg-destructive' : ''}
          >
            {confirmText}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
```

## Graficos com Recharts

```typescript
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { ChartConfig, ChartContainer, ChartTooltip } from '@/components/ui/chart';

const data = [
  { month: 'Jan', despesas: 3200, receitas: 5000 },
  { month: 'Fev', despesas: 2800, receitas: 5000 },
  { month: 'Mar', despesas: 3500, receitas: 5500 },
];

const chartConfig = {
  despesas: { label: 'Despesas', color: 'hsl(var(--chart-1))' },
  receitas: { label: 'Receitas', color: 'hsl(var(--chart-2))' },
} satisfies ChartConfig;

export function RevenueChart() {
  return (
    <ChartContainer config={chartConfig} className="h-[300px]">
      <BarChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="month" />
        <YAxis />
        <ChartTooltip />
        <Bar dataKey="despesas" fill="var(--color-despesas)" />
        <Bar dataKey="receitas" fill="var(--color-receitas)" />
      </BarChart>
    </ChartContainer>
  );
}
```

## Boas Praticas

1. **Composicao**: Prefira composicao a heranca
2. **Props tipadas**: Sempre defina interfaces para props
3. **Separacao**: Mantenha logica em hooks, apresentacao em componentes
4. **Acessibilidade**: Use componentes Radix UI para acessibilidade
5. **Responsividade**: Teste em diferentes tamanhos de tela
