# FinTrack — documentação de produto e desenvolvimento

Este repositório é o site Docusaurus do FinTrack. A documentação de comportamento atual começa em [docs/intro.md](docs/intro.md) e no [índice de produto](docs/product/index.md). A [matriz de cobertura](docs/product/coverage.md) relaciona jornadas, código e testes; [lacunas](docs/product/known-gaps.md) distinguem comportamento observado de decisões pendentes. Os contratos HTTP estão em docs/api-simple e o artefato OpenAPI é preservado separadamente.

## Checkpoint desta revisão

As regras foram lidas contra backend cc862284112cd171e145895b2fb83fa576e5befc e frontend fbb75d06862c324b5e5a0fc2076498d634c6e627, em 4 de outubro de 2026. O checkpoint inicial deste repositório era e3f78176a5ad8dfc355e28d659e415bf6af62060. O checkout canônico editado é backend/docs; frontend/docs é outro checkout do mesmo submódulo e não foi editado. Não houve escrita em banco, seed, migração ou deploy.

Para instalação e operação do aplicativo, siga os README e AGENTS.md dos repositórios backend e frontend. Eles são independentes; este repositório não os contém como submódulos internos. O [guia de manutenção](docs/product/maintenance.md) explica como atualizar jornadas e cálculos sem copiar código ou expor dados reais.

## Validar o site

Use npm ci e npm run build **neste repositório docs**. O site constrói as localidades pt-BR e en. O diretório build é artefato local ignorado; não equivale a publicar. Arquivos HTML e assets versionados na raiz e em en/ pertencem à publicação antiga e não são atualizados pela revisão de fontes. A atualização deles requer fluxo de publicação próprio.

## Conteúdo histórico

COMPLIANCE_REVIEW.md é um retrato de avaliação datado e contém declarações que não representam necessariamente o produto atual. Não o utilize para inferir rotas, integrações ou política de privacidade presente. dashboard-data-rules.md foi reduzido a remissão para a página atual. As fontes operacionais são código, testes e páginas de produto indicadas acima.
