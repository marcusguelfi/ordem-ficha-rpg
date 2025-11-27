Ordem RPG
Sistema de RPG em tempo real com gerenciamento de personagens, atributos, equipamentos e combate. Construído com Next.js, Prisma e MariaDB.

🎮 Características
Gerenciamento de Personagens - Criar e gerenciar jogadores com atributos, skills e equipamentos
Sistema de Atributos - Atributos dinâmicos com status e modificadores
Equipamentos e Itens - Sistema completo de equipamentos, moedas e inventário
Combate em Tempo Real - Sistema de dados e combate com socket.io
Autenticação - Login seguro com iron-session
Admin Dashboard - Painel administrativo para gerenciar ambiente
Editor de Cenários - Editor integrado para criar e editar conteúdo
Suporte a Múltiplas Plataformas - Desktop e retrato com websockets

🛠️ Tecnologias
Frontend: Next.js 12, React 17, Bootstrap 5, SASS
Backend: Next.js API Routes, Node.js 18
Banco de Dados: MariaDB 11, Prisma ORM
Real-time: Socket.io
Autenticação: iron-session, bcrypt
Infraestrutura: Docker, Docker Compose

📦 Requisitos
Node.js >= ^16.0.0

npm >= 8.0.0

Docker & Docker Compose (para produção)

MariaDB 11 (local ou Docker)

🚀 Início Rápido

# Instalar dependências
npm install

# Configurar banco de dados local
# Certifique-se que MariaDB está rodando em localhost:3306

# Sincronizar schema
npx prisma db push

# Iniciar servidor de desenvolvimento
npm run dev

Desenvolvimento Local
Acesse http://localhost:3000

Produção com Docker
Acesse http://localhost:3000


📝 Scripts Disponíveis
npm run dev - Servidor de desenvolvimento
npm run build - Build para produção
npm start - Iniciar servidor de produção
npm run lint - ESLint

🐳 Docker
docker-compose up - Iniciar todos os serviços
docker-compose down - Parar serviços
docker-compose logs -f app - Ver logs da aplicação
docker-compose logs -f db - Ver logs do banco
📄 Licença
Este projeto é privado.
