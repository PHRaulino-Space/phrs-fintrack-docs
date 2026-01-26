# Self-Hosting (Manual)

Se você não quer usar Docker, pode rodar os binários diretamente.

## Requisitos
- Linux Server (Ubuntu/Debian)
- PostgreSQL instalado e rodando
- Systemd (para gerenciar os processos)
- Nginx (proxy reverso)

## Passos

1.  **Compile o Backend**:
    ```bash
    go build -o fintrack-api cmd/app/main.go
    mv fintrack-api /usr/local/bin/
    ```

2.  **Compile o Frontend**:
    ```bash
    npm run build
    # Use PM2 ou similar para rodar o Next.js
    pm2 start npm --name "fintrack-web" -- start
    ```

3.  **Configuração Systemd (Backend)**:
    Crie `/etc/systemd/system/fintrack.service`:
    ```ini
    [Unit]
    Description=FinTrack Backend
    After=network.target postgresql.service

    [Service]
    User=fintrack
    ExecStart=/usr/local/bin/fintrack-api
    Environment="DB_URL=postgres://..."
    Restart=always

    [Install]
    WantedBy=multi-user.target
    ```

4.  **Nginx**:
    Configure o Nginx para redirecionar `/api` para `localhost:8080` e `/` para `localhost:3000`.
