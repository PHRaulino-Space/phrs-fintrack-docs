# Docker e Self-Hosting

O FinTrack é "Docker Native". A maneira mais fácil de rodá-lo em produção é usando Docker Compose.

## Estrutura do Docker Compose

Crie um arquivo `docker-compose.yml` no seu servidor:

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: securepassword
      POSTGRES_DB: fintrack
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    image: phraulino/fintrack-backend:latest
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_USER: postgres
      DB_PASSWORD: securepassword
      DB_NAME: fintrack
      PORT: 8080
    ports:
      - "8080:8080"

  frontend:
    image: phraulino/fintrack-frontend:latest
    environment:
      NEXT_PUBLIC_API_BASE_URL: http://backend:8080 # Atenção: no browser do cliente, isso deve ser acessível!
      # Se usar proxy reverso, configure a URL pública aqui.
    ports:
      - "3000:3000"

volumes:
  pgdata:
```

*Nota: A configuração acima é básica. Em produção, use um proxy reverso (Nginx) para servir frontend e backend na mesma porta (80/443) e evitar problemas de CORS e portas mistas.*

## Passos para Deploy

1.  Provisione um servidor (VPS Linux).
2.  Instale Docker e Docker Compose.
3.  Copie o `docker-compose.yml`.
4.  Rode `docker-compose up -d`.
5.  Acesse `http://seu-ip:3000`.
