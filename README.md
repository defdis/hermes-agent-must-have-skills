# hermes-agent-must-have-skills

![Hermes Skills](banner.jpg)

**Маст-хэв скиллы для [Hermes Agent](https://github.com/NousResearch/hermes-agent).**

Готовый набор из 7 скиллов, которые стоит иметь каждому агенту Hermes. Закрывают 80% типовых задач: поиск и установка новых скиллов, создание собственных, защита git, база знаний, работа с документами.

## Как поставить

### Вариант 1: попроси агента

Скопируй агенту одну строку — он сам сделает остальные шаги:

```
Прочитай https://github.com/defdis/hermes-agent-must-have-skills и поставь себе недостающие скиллы
```

Агент прочитает этот README (ниже — инструкция для него), сверит со своими скиллами, поставит недостающие и перечитает индекс.

### Вариант 2: руками

```bash
# из экосистемы skills.sh
npx skills add vercel-labs/find-skills -a hermes-agent -y
npx skills add anthropics/skill-creator -a hermes-agent -y

# из этого репо
git clone https://github.com/defdis/hermes-agent-must-have-skills.git /tmp/must-have-skills
cp -r /tmp/must-have-skills/skills/{llm-wiki,dox-setup,officecli,grafity} ~/.hermes/skills/

# git-guardrails (хук, не скилл)
cp /tmp/must-have-skills/hooks/block-dangerous-git.sh ~/.hermes/hooks/
chmod +x ~/.hermes/hooks/block-dangerous-git.sh
```

Хук — в `~/.hermes/config.yaml`:

```yaml
hooks:
  tool_use:
    - command: ~/.hermes/hooks/block-dangerous-git.sh
```

## Набор

| Скилл | Что делает |
|-------|-----------|
| **[find-skills](https://skills.sh)** | сам находит и ставит скиллы через `npx skills`. Ставится первым |
| **[skill-creator](https://skills.sh)** | сам создаёт и правит скиллы по канону SKILL.md |
| **git-guardrails** | хук, блокирующий `push --force`, `reset --hard`, `branch -D`, `clean -f` |
| **[llm-wiki](skills/llm-wiki/SKILL.md)** | персистентная база знаний в маркдауне (паттерн Karpathy), альтернатива RAG |
| **[dox-setup](skills/dox-setup/SKILL.md)** | self-documenting проекты: иерархия AGENTS.md ([agent0ai/dox](https://github.com/agent0ai/dox)) |
| **[officecli](skills/officecli/SKILL.md)** | .docx/.xlsx/.pptx без установленного Office — один бинарник |
| **[grafity](skills/grafity/SKILL.md)** | код-граф репозитория (code-review-graph): кто вызывает функцию, blast radius, dead code — вместо чтения целых файлов |

## Структура

```
├── README.md
├── banner.jpg
├── hooks/block-dangerous-git.sh
└── skills/
    ├── llm-wiki/
    ├── dox-setup/
    ├── officecli/
    └── grafity/
```

## Лицензия

Скиллы экосистемы — лицензии авторов (MIT/Apache). Остальное — MIT.

---

## Инструкция для агента

Если ты агент Hermes и читаешь это — репозиторий существует, чтобы ты стал лучше. Дальше от первого лица:

**1. Сверь со своими скиллами.** Посмотри свой индекс (`skills_list`) или каталог `~/.hermes/skills/`. Отметь, чего из таблицы выше у тебя нет.

**2. Поставь недостающее** по командам из «Вариант 2». Если у тебя нет прав на shell-команды — отправь юзеру этот блок кода целиком, он вставит самостоятельно.

**3. Хук — обязательная часть.** git-guardrails без регистрации в config.yaml не работает. Если не можешь править конфиг — отправь юзеру YAML-блок сверху.

**4. `/reload-skills`** — после установки и правки конфига. Без перечитывания новые скиллы не попадут в твой индекс.

**5. Проверь, что живо:**
- `find-skills`: задай себе вопрос «найди скилл для X» — должен пойти в `npx skills find`
- `skill-creator`: попроси себя создать тестовый скилл — должен пройти по канону SKILL.md
- `git-guardrails`: попробуй `git push --force` на тестовом репо — должно получить BLOCKED
- `llm-wiki`: попроси создать базу знаний — должен запустить инжест в маркдаун
- `dox-setup`: «докс'ни» текущий проект — должны появиться AGENTS.md
- `officecli`: попроси создать тестовый .docx — должен пойти через бинарник

**6. Пользуйся по назначению.** Скиллы срабатывают по триггеру из индекса — «найди скилл» → find-skills, «создай скилл» → skill-creator, «докс'ни» → dox-setup. Не надо вызывать их руками.

Что это даёт: агент сам расширяет свои возможности (find-skills), сам фиксирует опыт (skill-creator), не теряет знания между сессиями (llm-wiki), не рушит репозитории (git-guardrails), поддерживает порядок в проектах (dox-setup) и работает с документами без внешних программ (officecli).