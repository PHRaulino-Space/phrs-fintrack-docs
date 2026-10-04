# Setup de schema e migrações

O setup é explícito por backend/cmd/dbsetup, não ocorre no startup HTTP. SetupDatabaseSchema cria extensões e tipos necessários; AutoMigrate registra entidades GORM e impõe alguns índices/restrições; SetupDatabaseFunctions instala funções e gatilhos. O alvo make db-setup agrega as etapas; a execução requer ambiente e banco apropriados. Esta revisão documental **não** executou nenhuma delas.

O comando e suas flags atuais estão em backend/cmd/dbsetup/main.go, backend/Makefile e backend/AGENTS.md. Antes de mudar um modelo, confira dependências de gatilhos e testes de integração. Arquivos em backend/reports/migrations são registros históricos, não o único esquema canônico em execução.

Fontes: backend/internal/infra/dbsetup/setup.go, migrations.go; backend/cmd/dbsetup/main.go.
