#!/bin/sh

# Aguardar o banco de dados ficar pronto
echo "Aguardando banco de dados..."
until nc -z db 3306; do
  echo "Aguardando conexão com o banco de dados..."
  sleep 2
done
echo "Banco de dados está pronto!"

# Sincronizar schema (db push cria tabelas se não existirem)
echo "Sincronizando schema..."
npx prisma db push

# Executar migrations sem falhar se houver erro (para compatibilidade futura)
echo "Executando migrations..."
npx prisma migrate deploy || true

# Iniciar aplicação
echo "Iniciando aplicação..."
exec npm start
