# Monitoramento

Como saber se o FinTrack está saudável.

## Logs

- **Backend**: Logs estruturados em JSON (stdout). Use ferramentas como `jq` ou agregadores de log (Loki, ELK) para analisar.
- **Frontend**: Logs de renderização do Next.js (stdout).
- **Postgres**: Logs de queries lentas e erros de conexão.

## Health Checks

O backend expõe um endpoint `/health` ou `/live`?
- Recomendamos configurar um uptime monitor (Uptime Kuma) batendo em `http://host:8080/api/v1/health` a cada minuto.

## Métricas (Prometheus)

*(Futuro)*: Instrumentar a aplicação Go com métricas Prometheus para monitorar:
- Latência de requisições HTTP.
- Uso de memória/CPU.
- Número de Goroutines.
- Taxa de erro 5xx.
