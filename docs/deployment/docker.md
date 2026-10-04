# Docker e Compose

Os manifests atuais estão na raiz do workspace e nos repositórios backend e frontend. Eles são a referência para nomes de serviços, portas, rede e variáveis. Não copie exemplos antigos de imagem, porta ou credencial desta documentação como receita de produção.

O frontend em desenvolvimento serve em 7201 e o servidor de produção do Next.js usa 3000 por padrão; a API usa PORT 8080 por padrão. A URL pública NEXT_PUBLIC_API_BASE_URL precisa ser alcançável pelo navegador e é fixada no build. Banco e serviços opcionais devem ser configurados conforme os READMEs. Veja [configuração](../getting-started/configuration.md).

Nenhum container foi iniciado nem modificado nesta revisão.
