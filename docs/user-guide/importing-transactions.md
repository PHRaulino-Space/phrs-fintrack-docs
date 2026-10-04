# Importando transações

Abra **Importações**, escolha uma conta ou cartão, envie um arquivo aceito pela interface e revise as linhas preparadas. Elas só viram lançamentos definitivos quando você confirma o commit. A sessão pode persistir para lotes seguintes. Para instituições conectadas, o fluxo de Open Finance tem autorização e sincronização próprias.

A [jornada de importação e Open Finance](../product/imports-open-finance.md) especifica o formato CSV realmente aceito, classificação, edição, prontidão, seleção, deduplicação, falhas e conciliação. A API detalhada está em [sessões de importação](../api-simple/import-sessions.md). Não presuma detecção automática de colunas, cores de confiança, suporte OFX ou treino imediato após commit: essas promessas antigas não são o contrato do parser e do caso de uso atuais.

Fontes: backend/internal/usecase/parser, import.go e session_enrichment.go; frontend/src/app/(fintrack)/import-sessions.
