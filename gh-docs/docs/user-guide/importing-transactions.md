# Importando Transações

O FinTrack foi desenhado para eliminar a digitação manual através da importação de arquivos bancários.

## Passo 1: Obter o arquivo (CSV)

Acesse o internet banking do seu banco e procure pela opção "Extrato". Exporte o período desejado em formato **CSV** (Planilha).
*Nota: OFX também é um padrão comum, mas o FinTrack foca primariamente em CSV pela flexibilidade de leitura.*

## Passo 2: Criar Sessão de Importação

1.  No FinTrack, acesse o menu **Importações**.
2.  Clique em **Nova Importação**.
3.  Selecione o destino:
    - É uma importação para uma **Conta** (débito/extrato direto)?
    - Ou para um **Cartão de Crédito** (fatura)?
4.  Faça o upload do arquivo CSV.

## Passo 3: Mapeamento (Parsing)

Se for a primeira vez que importa desse banco, o sistema pode pedir para confirmar quais colunas representam o quê (Data, Descrição, Valor). O sistema tenta detectar automaticamente.

## Passo 4: Revisão (Staging)

Após o upload, você não verá as transações imediatamente no seu extrato oficial. Elas vão para uma área de rascunho.

Nesta tela, você verá lista de transações importadas. O sistema de IA já terá tentado preencher a **Categoria** e **Subcategoria** para cada uma.

- **Verde**: O sistema tem alta confiança.
- **Amarelo/Vermelho**: O sistema está em dúvida, verifique com atenção.

Você pode:
- Editar descrições para ficarem mais limpas.
- Alterar categorias em massa.
- Excluir transações duplicadas ou indesejadas.

## Passo 5: Efetivar (Commit)

Ao finalizar a revisão, clique em **Concluir Importação**.
- As transações saem do rascunho e entram no livro razão oficial.
- Seus saldos são atualizados.
- O modelo de IA é treinado com suas correções para acertar mais na próxima vez.
