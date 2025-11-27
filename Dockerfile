# Stage 1: Build
FROM node:18-bullseye AS builder

WORKDIR /app

# Copiar package.json e package-lock.json
COPY package*.json ./

# Instalar dependências
RUN npm install

# Copiar código fonte
COPY . .

# Build da aplicação Next.js
RUN npm run build

# Stage 2: Production
FROM node:18-bullseye

WORKDIR /app

# Instalar netcat e curl
RUN apt-get update && apt-get install -y --no-install-recommends netcat-traditional curl && rm -rf /var/lib/apt/lists/*

# Instalar apenas dependências de produção
COPY package*.json ./
RUN npm install --only=production

# Copiar arquivos buildados do estágio anterior
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/src ./src
COPY --from=builder /app/node_modules ./node_modules

# Copiar entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expor porta
EXPOSE 3000

# Comando para iniciar a aplicação
ENTRYPOINT ["/app/entrypoint.sh"]
