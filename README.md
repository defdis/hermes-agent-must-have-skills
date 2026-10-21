# hermes-agent-must-have-skills

![Hermes Skills](banner.jpg)

**Маст-хэв набор скиллов для инстансов [Hermes Agent](https://github.com/NousResearch/hermes-agent).**

Коллекция базовых скиллов, полезных каждому инстансу агента Hermes: автоматический поиск и установка новых скиллов, создание собственных, защита git от опасных команд, персистентная база знаний, работа с Office-документами.

> Базовый набор из 6 позиций закрывает ~80% типовых задач агента. Дизайн-пак — для профилей, рендерящих UI. Раздел «Внутренние» — собственные скиллы, которых нет в экосистеме.

## Состав базового набора

| Скилл | Что делает | Установка |
|-------|-----------|-----------|
| **[find-skills](https://skills.sh)** | Агент сам находит и ставит нужные скиллы через `npx skills`. Мета-скилл — ставится первым | `npx skills add vercel-labs/find-skills -a hermes-agent -y` |
| **[skill-creator](https://skills.sh)** | Агент сам создаёт/правит/тестирует скиллы по канону SKILL.md | `npx skills add anthropics/skill-creator -a hermes-agent -y` |
| **git-guardrails** | Хук, блокирующий опасные git-команды: `push --force`, `reset --hard`, `branch -D`, `clean -f` | [hooks/block-dangerous-git.sh](hooks/block-dangerous-git.sh) + секция в config.yaml |
| **[llm-wiki](skills/llm-wiki/SKILL.md)** | Персистентная wiki-база знаний в маркдауне (паттерн Andrej Karpathy): инжест источников, кросс-ссылки, линт консистентности. Альтернатива RAG | в этом репо: `skills/llm-wiki/` |
| **[dox-setup](skills/dox-setup/SKILL.md)** | DOX-фреймворк ([agent0ai/dox](https://github.com/agent0ai/dox)): иерархия AGENTS.md, агент читает цепочку до правок и обновляет после | в этом репо: `skills/dox-setup/` |
| **[officecli](skills/officecli/SKILL.md)** | CLI для .docx/.xlsx/.pptx: создание, анализ, проверка, диаграммы. Один бинарник, без установки Office | в этом репо: `skills/officecli/` + бинарник `officecli` |

## Быстрый старт

```bash
# 1. Из экосистемы skills.sh
npx skills add vercel-labs/find-skills -a hermes-agent -y
npx skills add anthropics/skill-creator -a hermes-agent -y

# 2. Из этого репо
git clone https://github.com/defdis/hermes-agent-must-have-skills.git
cp -r hermes-agent-must-have-skills/skills/{llm-wiki,dox-setup,officecli} ~/.hermes/skills/

# 3. Git-guardrails
cp hermes-agent-must-have-skills/hooks/block-dangerous-git.sh ~/.hermes/hooks/
chmod +x ~/.hermes/hooks/block-dangerous-git.sh
```

Регистрация хука в `~/.hermes/config.yaml`:

```yaml
hooks:
  tool_use:
    - command: ~/.hermes/hooks/block-dangerous-git.sh
```

## Массовая установка (скрипт)

`install.sh` устанавливает набор на список Docker-инстансов: `docker cp` скиллов и хука → регистрация в config.yaml → curator adopt → рестарт gateway.

```bash
./install.sh "имя1 имя2 ..."
```

## Дополнительно (по профилю инстанса)

Дизайн/фронт-пак и профильные скиллы ставятся по потребности: layout-grid, pixel-perfect-ui, screenshot-to-html, mermaid-diagrams, github-auth, polza-image-generation.

## Структура репозитория

```
├── README.md                    ← этот файл
├── install.sh                   ← массовая установка на Docker-инстансы
├── banner.jpg                   ← обложка
├── hooks/
│   └── block-dangerous-git.sh   ← git-guardrails хук
└── skills/
    ├── llm-wiki/                ← Karpathy wiki
    ├── dox-setup/               ← DOX (иерархия AGENTS.md)
    └── officecli/               ← Office-документы
```

## Лицензия

Скиллы экосистемы — под лицензиями авторов (MIT/Apache). Внутренние скиллы — MIT.

---

*Автор: defdis · обновлено 21.10.2026*