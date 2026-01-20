# Serviço de IA (Categorização)

Um dos diferenciais do FinTrack é o uso de Inteligência Artificial Local para categorização automática.

## Fluxo de Processamento

1.  **Ingestão**: Quando uma transação é importada (ex: "UBER *TRIP SAO PAULO"), o sistema a recebe.
2.  **Geração de Embedding**: O texto da descrição é convertido em um vetor numérico (embedding) que representa seu significado semântico.
3.  **Busca Vetorial**: O sistema consulta no banco de dados (`category_embeddings`) por transações passadas com vetores similares (distância de cosseno ou similar).
4.  **Classificação**:
    - Se encontrar alta similaridade, sugere a mesma categoria/subcategoria.
    - O sistema calcula um "score de confiança".
5.  **Aprendizado**: Quando o usuário confirma ou corrige uma categorização, essa nova associação (Descrição -> Categoria) é salva e vetorizada, refinando o modelo para o futuro.

## Privacidade

Todo esse processo ocorre localmente ou em um container dedicado dentro da sua infraestrutura. Nenhuma descrição de transação é enviada para APIs públicas como OpenAI ou Google Gemini, garantindo que seus hábitos de consumo permaneçam privados.

## Integração Técnica

No backend (Go), a lógica reside tipicamente em um serviço (`internal/service/embedding_service.go`) que pode chamar uma biblioteca local ou um microserviço Python lateral para gerar os vetores, dependendo da implementação específica do modelo escolhido (ex: BERT, Sentence Transformers).
