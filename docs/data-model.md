## Modelo de Dados (Prisma) – Ordem RPG

Este arquivo resume como os campos exibidos nas telas se relacionam no banco MySQL (via Prisma). Use-o para entender impactos de edições no Editor ou para criar integrações externas.

---

### 1. Entidades principais

| Model | Campos-chave | Uso nas telas |
|-------|--------------|---------------|
| `Player` | `id`, `name`, `username`, `role` | Sessões de login, painel do mestre, lista de retratos. |
| `Info` + `PlayerInfo` | `PlayerInfo (player_id, info_id, value)` | Contêiner “Detalhes Pessoais” (partes 1 e 2). |
| `Attribute`, `PlayerAttribute` | `value`, `maxValue`, `show` | Barras de atributo (jogador e retrato). |
| `AttributeStatus`, `PlayerAttributeStatus`, `PlayerAvatar` | `value` (bool), `link` (imagem) | Estados que trocam avatar e badges. |
| `Spec`, `PlayerSpec` | `value` | Especificações de personagem (ex.: Dano Bônus). |
| `Characteristic`, `PlayerCharacteristic` | `value`, `modifier` | Características secundárias (For, Des, etc.). |
| `Skill`, `PlayerSkill` | `value`, `modifier`, `checked` | Perícias (contêiner principal). |
| `Equipment`, `PlayerEquipment` | `currentAmmo` | Contêiner Combate (armas). |
| `Item`, `PlayerItem` | `currentDescription`, `quantity` | Inventário e peso. |
| `Currency`, `PlayerCurrency` | `value` | Campo de moedas. |
| `ExtraInfo`, `PlayerExtraInfo` | `value` (texto) | Detalhes pessoais parte 2. |
| `Spell`, `PlayerSpell` | — | Contêiner de Magias. |
| `PlayerNote` | `value` | Anotações (página 2). |
| `Config` | (`name`, `value`) | Inicialização, chave do mestre, configs gerais, dados e retrato. |
| `Trade` | `sender_id`, `receiver_id` | Utilitário de trocas entre jogadores. |

---

### 2. Relacionamentos importantes

```text
Player 1—∞ PlayerAttribute → Attribute
Player 1—∞ PlayerAttributeStatus → AttributeStatus
Player 1—∞ PlayerSpec → Spec
Player 1—∞ PlayerCharacteristic → Characteristic
Player 1—∞ PlayerSkill → Skill
Player 1—∞ PlayerEquipment → Equipment
Player 1—∞ PlayerItem → Item
Player 1—∞ PlayerSpell → Spell
Player 1—∞ PlayerCurrency → Currency
Player 1—∞ PlayerExtraInfo → ExtraInfo
Player 1—∞ PlayerInfo → Info
Player 1—∞ PlayerNote
```

Cada par `PlayerXxx` atua como tabela pivô com chave composta (`player_id`, `xxx_id`), permitindo que o Editor atualize tanto o “catálogo” (ex.: `Equipment`) quanto o vínculo individual (ex.: munição de cada jogador).

---

### 3. Configurações (model `Config`)

| Nome (`name`) | Onde impacta | Detalhes |
|---------------|--------------|----------|
| `init` | `/` | Quando `false`, mostra wizard “Realizando configuração inicial…”. |
| `admin_key` | `/register/admin` | Obriga chave após primeiro mestre. |
| `environment` | Painel do mestre | Usado para indicar estado do jogo. |
| `dice` | Configurações > Dado | JSON com parâmetros de rolagem padrão. |
| `enable_success_types`, `enable_automatic_markers` | Configurações > Geral | Liga/desliga comportamentos de feedback nas perícias. |
| `portrait_font`, atributos JSON | OBS retratos | Define estilos default. |

Adicione novas configs via `Config` e consuma com Prisma (`prisma.config.findUnique`).

---

### 4. Campos especiais referenciados nas telas

- **Dano Bônus (`PlayerSpec` com nome “Dano Bônus”)**: usado nos campos de dano (`Equipment`, `Spell`) via tokens `DB` ou `DB/2`.
- **Características em expressões de dano**: token de 3 letras (ex.: `FOR`, `DES`).
- **`PlayerAttribute.show`**: define se atributo aparece no retrato. Controlado na ficha (ícone olho).
- **`PlayerAttributeStatus`**: booleanos, mas ordenação/precedência é inferida pela ordem definida no Editor.
- **`PlayerSkill.checked`**: marcação automática quando sucesso (se habilitado).
- **`PlayerEquipment.currentAmmo`**: decrementa a cada rolagem; impede rolagem quando 0.

---

### 5. Inicialização (`/api/init`)

O endpoint popula todas as tabelas acima com seeds. Rodá-lo em um banco vazio garante:
- Criação de valores default em `Config`.
- Inserção de atributos, características, equipamentos base etc.

Após execução bem-sucedida:
- `config.init = true`
- A tela `/` passa a exibir o formulário de login.

---

### 6. Dicas para integrações
- Use `schema.prisma` como fonte da verdade; rodar `npx prisma format` antes de commits.
- Para relatórios, preferira `Player` + `PlayerXxx` em joins; evite consultas diretas aos catálogos sem considerar `visible`.
- Se precisar auditar rolagens, veja tabelas/coleções alimentadas no backend (histórico em memória via sockets).

Consulte `schema.prisma` para campos adicionais não listados aqui. Este documento cobre todas as entidades utilizadas nas telas descritas em `docs/app-guide.md`.

