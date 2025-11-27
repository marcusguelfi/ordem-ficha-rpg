#!/bin/sh

# Aguardar o banco de dados ficar pronto
echo "Aguardando banco de dados..."
sleep 15

# Executar migrations sem falhar se houver erro
echo "Executando migrations..."
npx prisma migrate deploy || true

# Iniciar aplicação
echo "Iniciando aplicação..."
exec npm start
