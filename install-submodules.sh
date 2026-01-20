#!/bin/bash

# Script para instalar submódulos do projeto Fintrack
# Executa: bash install-submodules.sh

echo "=== Instalando submódulos do Fintrack ==="

# Adicionar submódulo do frontend
echo "Adicionando submódulo frontend..."
git submodule add https://github.com/PHRaulino-Space/phrs-fintrack-frontend.git frontend

# Adicionar submódulo do backend
echo "Adicionando submódulo backend..."
git submodule add https://github.com/PHRaulino-Space/phrs-fintrack-backend.git backend

# Inicializar e atualizar os submódulos
echo "Inicializando submódulos..."
git submodule init

echo "Atualizando submódulos..."
git submodule update --recursive

echo "=== Submódulos instalados com sucesso! ==="
echo ""
echo "Estrutura criada:"
echo "  - frontend/ -> phrs-fintrack-frontend"
echo "  - backend/  -> phrs-fintrack-backend"
echo ""
echo "Para atualizar os submódulos no futuro, execute:"
echo "  git submodule update --remote"
