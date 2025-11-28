## Ordem RPG
Sistema de RPG em tempo real com fichas digitais, painel administrativo e fluxo de jogo integrado. A stack principal combina **Next.js 12**, **Prisma**, **MariaDB 11** e **Socket.io**, empacotados para execução em Docker.

### 🎮 Funcionalidades
- Gerenciamento completo de jogadores, atributos, equipamentos, itens e moedas
- Painel do narrador com editores de cenário, NPCs e ambiente
- Portrait/stream view em tempo real via websockets
- Autenticação com `iron-session` e rotas protegidas por SSR
- Migrações/sincronização de schema Prisma integradas ao container

### 🛠️ Stack
| Camada     | Tecnologia |
|------------|------------|
| Frontend   | Next.js 12, React 17, Bootstrap 5, SASS |
| Backend    | Next.js API Routes (Node.js 18) |
| Banco      | MariaDB 11 (Prisma ORM) |
| Tempo real | Socket.io 4 |
| Auth       | iron-session + bcrypt |
| Infra      | Docker + Docker Compose |

### ✅ Requisitos
- Node.js ≥ 16 e npm ≥ 8 (para desenvolvimento local)
- Docker Desktop + Docker Compose (para o ambiente containerizado)
- MariaDB 11 (local ou via Docker)

---

## Configuração de Ambiente

### Variáveis obrigatórias
Crie um arquivo `.env.local` (para dev) ou use variáveis no container:

```
DATABASE_URL=mysql://user:pass@host:3306/rpg
SESSION_SECRET=uma-chave-aleatoria-com-32+ caracteres
PORT=3000
```

> No `docker-compose.yml` já definimos `DATABASE_URL` (apontando para o serviço `db`) e um valor padrão para `SESSION_SECRET`. Ajuste conforme sua necessidade.

### Banco local (opcional)
Há um compose auxiliar em `DB-Local Docker/MariaDB-docker-compose.yml` que sobe apenas o MariaDB com dados iniciais. Use se quiser executar o Next.js fora do Docker.

---

## Desenvolvimento local (sem Docker)
```bash
npm install
npx prisma db push         # cria/atualiza as tabelas
npm run dev                # http://localhost:3000
```

> Para popular dados padrão, faça um POST para `http://localhost:3000/api/init` após subir o servidor.

---

## Ambiente Docker

O projeto possui um multi-stage Dockerfile baseado em `node:18-bullseye-slim`. O entrypoint aguarda o MariaDB ficar pronto, executa `npx prisma db push`, roda `npx prisma migrate deploy` e depois inicia o `next start`.

### Comandos principais
```bash
# subir aplicação + banco
docker-compose up -d

# acompanhar logs
docker-compose logs -f app
docker-compose logs -f db

# encerrar serviços
docker-compose down
```

### Primeira inicialização
1. `docker-compose up -d`
2. POST em `http://localhost:3000/api/init` (pode usar `Invoke-WebRequest` ou `curl`)
3. Acesse `http://localhost:3000` → a tela de login estará disponível.

---

## Scripts npm
| Script         | Descrição |
|----------------|-----------|
| `npm run dev`  | Servidor Next.js em modo desenvolvimento |
| `npm run build`| Build de produção (executa `next build`) |
| `npm start`    | Inicia o servidor de produção (`next start -p $PORT`) |
| `npm run lint` | ESLint |

---

## Dicas & Troubleshooting
- **Erro “Certifique-se de ter integrado um banco de dados…”**: significa que o Prisma não conseguiu acessar a tabela `Config`. Rode `npx prisma db push` (ou suba via Docker e chame `/api/init`).
- **Prisma reclamando de OpenSSL em Alpine**: já migramos para `node:18-bullseye-slim` e instalamos `openssl + ca-certificates`. Se usar outra imagem, garanta esses pacotes.
- **Sessões**: defina `SESSION_SECRET` com uma string longa e secreta tanto no `.env` quanto no Docker.

---

## Licença
Projeto privado. Uso restrito aos colaboradores autorizados.
