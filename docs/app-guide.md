## Guia de Utilização do Ordem RPG

Este documento descreve todas as telas, URLs, fluxos de navegação e campos principais do aplicativo. Use-o como referência rápida para operar o sistema em produção ou para treinar novos narradores/jogadores.

---

### 1. Visão geral de rotas

| URL | Perfil | Descrição |
|-----|--------|-----------|
| `/` | Público | Tela inicial. Mostra erro de banco, wizard de inicialização ou login, dependendo do estado. |
| `/register` | Público | Cadastro de jogador. |
| `/register/admin` | Público | Cadastro de mestre (exige chave). |
| `/api/init` | Público (POST) | Popula o banco com dados padrão e marca `config.init=true`. |
| `/sheet/player/[id]` | Jogador autenticado | Ficha completa do jogador (tabs 1 e 2). |
| `/sheet/npc/[id]/[page]` | Mestre | Leitura rápida de fichas NPC. |
| `/portrait/[characterID]` | OBS/browser source | Retrato sincronizado para streaming. |
| `/admin/main` | Mestre autenticado | Painel do Mestre (monitoramento, utilitários). |
| `/admin/editor` | Mestre autenticado | Editor de todos os contêineres da ficha. |
| `/admin/configurations` | Mestre autenticado | Configurações de sistema, dados e retrato. |

---

### 2. Fluxo de autenticação
1. Usuário acessa `/`.
2. O SSR (`getSSP`) verifica `req.session.player`.
   - **Não autenticado**: consulta `config.init`. Se `false`, exibe “Inicialização…” com botão para `/api/init`. Se ocorrer erro no Prisma, mostra mensagem “Certifique-se de ter integrado um banco…”.
   - **Sessão de jogador**: redireciona para `/sheet/player/{id}`.
   - **Sessão de mestre**: redireciona para `/admin/main`.
3. Após login, rotas protegidas usam `sessionSSR` para impedir acesso anônimo.

Campos do formulário de login:
- `username` (texto)
- `password` (password)

Erros e toasts são tratados por `useToast` + `ErrorToastContainer`.

---

### 3. Cadastro

#### `/register`
Campos:
- `username`, `password`, `confirmPassword`
- Dados básicos da ficha (nome opcional) podem ser preenchidos após o primeiro acesso.
Fluxo:
1. Usuário conclui cadastro.
2. Recebe sessão de jogador e é enviado à sua ficha.

#### `/register/admin`
Campos adicionais:
- `masterKey` (obrigatório caso já exista um mestre).
- Mesmo fluxo de criação; ao finalizar, sessão marcada com `admin=true`.

---

### 4. Ficha do Jogador (`/sheet/player/:id`)

Container principais (detalhados em `docs/sheet.md`):

1. **Avatar & Rolagem livre**
   - Upload de URLs para avatar normal + estados (Status de Atributo).
   - Botão de dados 1d4–1d20; resultado aparece para mestre e retrato.
2. **Atributos**
   - Campos: valor atual, valor máximo, visibilidade no retrato, rollable flag.
   - Status associados (ex.: Inconsciente) alteram o avatar exibido.
3. **Características**
   - Valor base + modificador. Click = teste.
4. **Especificações de Personagem**
   - Campo especial `Dano Bônus (DB)` usado por armas e magias.
5. **Combate (Equipamentos)**
   - Campos: nome, tipo, dano (expressões), alcance, munição, visibilidade.
   - Relaciona-se com `PlayerEquipment` + `Equipment` no Prisma.
6. **Perícias**
   - Nome, valor, especialização opcional, flag “obrigatória”.
7. **Itens & Moedas**
   - Itens herdados do mestre; jogador customiza descrição e quantidade.
   - Capacidade total vs peso soma.
8. **Magias**
   - Similar a equipamentos: custo, tipo, dano, visibilidade.
9. **Anotações**
   - Campo livre (segunda página).

Fluxo entre páginas:
- Tab 1 foca em informações rápidas (atributos, combate, perícias).
- Tab 2 contém Detalhes Extras + Anotações + Itens extensos.

---

### 5. Painel do Mestre

#### `/admin/main`
Sessões:
- **Monitoramento**: lista todos os jogadores, atributos atuais, links de retrato.
- **Rolagem Livre**: mestre rola dados com presets ou expressões customizadas.
- **Combate**: controla ordem/rodadas, registra ações.
- **Histórico**: feed de rolagens dos jogadores.
- **NPCs**: CRUD rápido (nome, vida, iniciativa).
- **Anotações**: bloco de notas do mestre.
- **Retrato OBS toggle**: troca layout dos retratos (somente atributos ou nome).

#### `/admin/editor`
Permite CRUD em cada contêiner da ficha. Todos os campos descritos em `docs/editor.md`. Alterações salvam instantaneamente e afetam todas as fichas ligadas.

#### `/admin/configurations`
Dividido em:
1. **Geral**: chave do mestre, títulos dos contêineres, marcação automática.
2. **Dado**: tipos de sucesso, ramificações para atributos/características/perícias.
3. **Retrato**: orientação, atributos principais/ secundários exibidos no OBS.

---

### 6. Retratos e Streaming
URL copiada no painel do mestre → `/portrait/{characterID}`.

Elementos:
- Nome e atributos definidos na config.
- Avatar muda conforme status.
- Histórico de rolagens (últimas ações) surge como popup.

Para usar no OBS:
1. Adicione Browser Source com o link.
2. Ajuste largura/altura.
3. No painel, use o toggle “Retrato em Ambiente de Combate?” para trocar layout.

---

### 7. Fluxo completo recomendado
1. **Deploy & Docker**: `docker-compose up -d`.
2. **Inicialização**: `POST /api/init` para preencher tabelas.
3. **Cadastro do primeiro mestre**: acessar `/register/admin` (sem chave exigida).
4. **Configurações**: em `/admin/configurations`, definir títulos e chave nova.
5. **Edição da ficha base**: `/admin/editor` para personalizar atributos/perícias/etc.
6. **Cadastro de jogadores**: `/register`.
7. **Jogo**:
   - Jogadores usam `/` → login → `/sheet/player/:id`.
   - Mestre usa `/admin/main` para monitorar, `/admin/editor` para ajustes on-the-fly.
   - Retratos exibidos via OBS Browser Source.

---

### 8. Campos & Relações (resumo rápido)
- `Player` possui coleções para cada contêiner (`PlayerInfo`, `PlayerAttribute`, `PlayerItem`, etc.).
- `Attribute` ↔ `AttributeStatus` ↔ `PlayerAttributeStatus` determine visualizações e testes.
- `Equipment`, `Item`, `Spell` têm flag `visible` para controlar quando aparecem.
- `Config` guarda valores críticos (`init`, `environment`, `admin_key`, configurações JSON).
- `Trade`, `PlayerNote`, `PlayerAvatar` complementam utilitários do mestre.

Consulte `docs/data-model.md` para detalhes adicionais.

---

### 9. Dicas finais
- Sempre mantenha `DATABASE_URL` e `SESSION_SECRET` configurados antes de subir o container.
- Em ambientes novos, rode `/api/init` uma única vez.
- Para resetar totalmente, derrube os containers, apague o volume `mariadb_data` e repita o fluxo.

Esta documentação cobre 100% das rotas e funcionalidades presentes no repositório atual. Combine com os demais arquivos em `docs/` para aprofundar em tópicos específicos (Editor, Painel do Mestre, OBS).

