# Estágio 1: Build
FROM node:18-bullseye-slim AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./
COPY tsconfig.json ./
COPY next.config.js ./

# Copiar schema do Prisma
COPY src/prisma ./src/prisma

# Instalar dependências
RUN npm ci

# Gerar Prisma Client
RUN npx prisma generate

# Copiar todo o código fonte
COPY . .

# Build da aplicação Next.js (sem migrations, serão executadas no runtime)
RUN npx next build --no-lint

# Estágio 2: Produção
FROM node:18-bullseye-slim AS runner

WORKDIR /app

ENV NODE_ENV=production

# Instalar dependências necessárias (netcat para wait e certificados/openssl)
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-openbsd \
    ca-certificates \
    openssl \
    dos2unix \
 && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root para segurança
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copiar arquivos necessários do builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/src/prisma ./src/prisma
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/entrypoint.sh ./entrypoint.sh

# Normalizar final de linha e permissões do entrypoint
RUN dos2unix entrypoint.sh && chmod +x entrypoint.sh

# Garantir permissões para o usuário não-root
RUN chown -R nextjs:nodejs /app

# Mudar para usuário não-root
USER nextjs

# Expor porta (padrão 3000, mas pode ser sobrescrita via PORT)
EXPOSE 3000

ENV PORT=3000

# Usar entrypoint padrão
CMD ["./entrypoint.sh"]

