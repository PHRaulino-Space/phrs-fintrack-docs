É uma funcionalidade de importação de transações no app de finanças

Basicamente cada transação tem 3 infos principais transaction_date, description e amount

Para agrupar as transações nós temos uma session

Uma session é como se fosse uma área de stading que fica atrelada a um workspace para as transações isso significa que é um local onde podemos fazer o que quiser com as transações e isto não afetará nem o saldo final das contas e nem as tabelas principais do banco

Cada session pode ter 2 tipos de contextos, cartão ou conta sendo obrigatório passar a info de account_id ou card_id e o billing_month referente ao mês ou fatura da qual está sendo cadastrado as transações

Cartão sendo as despesas de cartão ou lançamentos de estorno na fatura, além disso podemos atrelar uma despesa a uma transação recorrente da tabelas de recurring card expenses

Conta são as transações de conta, como despesas e receitas, mas tem alguns outros tipos que são de controle como pagamento de cartão, transferência entre contas e saque ou depósito de investimentos, as despesas, receitas também podem ser atreladas a recurring incomes, expenses e transfers

Cada tipo de transação precisa de um campo específico pra serem cadastradas no banco final e pra padronizar, além das informações principais, temos um campo data do tipo json no banco e pra cada transação ele salva os atributos necessários para que ela seja salva no banco final

As staged transactions tbm possuem um status este status representa o estado da transação em relação ao banco final
Ready (possui as infos para cadastrar na base)
Pending (faltam infos para cadastrar na base)
Queued (está sendo processado pela ia)

Dentro do serviço de api eu tenho alguns endpoints

Create session
Cria a sessão, deve receber uma conta ou cartão, um billing_month e um target value opcional com valor default 0 ou no contexto de cartão deve se buscar no banco na tabela de pagamentos a soma dos pagamentos de cartão para este card id e billing_month
Deve pegar o workspace id do middleware x-workspace-id header
Cria a session na banco e retorna o id na request
O nome deve conter o nome da conta ou cartão e uma pipe seguida pelo billing month para o contexto de cartão, ele deve avaliar se a fatura existe e se existe ele deve estar no status de open, caso não existe ele deve ser criada e mantida no status open caso exista em outro status deve retorna um bad request

Delete session
Deve deletar todas as staged transactions e em seguida deve apagar a session

Create staged transactions
Este deve receber um array de staged transaction com transaction_date, description, amount
Aqui ele já pode verificar o sinal do valor, no contexto de conta ele salva uma receita para positivo e despesa para negativo, no contexto de cartão para positivo é uma despesa e para negativo é um estorno

Update transaction
Nesta function ele recebe um payload e substitui os dados no banco, o único critério é respeitar as contantes de tipo de transação e o campos principais não podem ser nulos ou inválidos, no json não precisa realizar validação, no final ele retorna a transaction


Delete all transactions
Neste ele deve pegar a session e apagar todas as transactions


Commit session
Neste ele deve pegar o session id e salvar todas as transactions no status ready para cada tipo tem sua tabela principal que deve ser salva com a regra de cada tipo salvando todas as transações com o status validating ou ignore cada no json possua a chave ignore: triue na tabela principal

Close session
Usando as infos da session como account_id ele irá pegar o account_id e alterar todos os registros de cada tabela principal relacionada a esse account onde possua transactions com o status validating e alterar para paid, depois ele irá apagar a session caso seja contexto de cartão deve se usar o billing_month e o card id para alterar o status para paid e depois alterar o status da fatura para paid

Recurring transaction atach 
Cada transaction pode possuir uma transaction recurring, nesta função ele recebe um id de staged transaction e um de recurring transaction, caso ambas existam a staged transaction deve assumir o tipo, description, category e subcategoria caso seja elegível

Get staged transaction
Retorna o objeto inteiro junto com o json de atributos de uma transaction

Get session
Busca os detalhes de uma session com contexto para ajudar o usuário
Nome, tipo, target value,  balanco inicial, context value, transactions, stats, status
Context value ( soma das transações desta conta até o saldo atual inclusive a soma das transactions da session)
Balanço inicial (no caso de uma conta é o valor de todas as transações para o saldo atual da conta até o mês do billing month ou seja saldo no início daquele mês)
Stats (contagem de transactions em ready vs total de transactions)
Status (se tudo estiver ready e o valor do target value estiver igual ao valor do context value) não é impeditivo para comemorar ou fechar a session
Transactions(são todas as transactions da session)


List import sessions
Lista de todas as sessions com nome, tipo target value, stats