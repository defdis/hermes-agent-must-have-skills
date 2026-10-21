# K98 Hermes Skills — маст-хэв сет для флотилии инстансов Hermes Agent

> Каталог скиллов, обязательных/полезных для всех инстансов [Hermes Agent](https://github.com/NousResearch/hermes-agent) на K98.
> Не вендор-база знаний, а рабочий сет: что ставить, откуда, как проверять.
> Хозяин: defdis · Сервер: K98 · Обновлено: 21.10.2026

---

## Базовый сет (всем инстансам Hermes)

| # | Скилл | Что делает | Установка |
|---|-------|------------|-----------|
| 1 | **find-skills** | Агент сам находит и ставит недостающие скиллы через `npx skills` и API skills.sh. Мета-скилл — ставится первым | `npx skills add vercel-labs/find-skills -a hermes-agent -y` |
| 2 | **skill-creator** | Агент сам создаёт/правит/измеряет скиллы по канону SKILL.md | `npx skills add anthropics/skill-creator -a hermes-agent -y` |
| 3 | **git-guardrails** | Защита от git-факапов: блокирует `push --force`, `reset --hard`, `branch -D`, `clean -f`. Реализован как Hermes **Hook**, не скилл | см. [hooks/block-dangerous-git.sh](hooks/block-dangerous-git.sh) + инструкция ниже |
| 4 | **llm-wiki** | Karpathy-паттерн: персистентная wiki-база знаний в маркдауне — инжест источников, кросс-ссылки, консистент-линт. RAG-альтернатива | скопировать каталог `skills/llm-wiki/` в `~/.hermes/skills/`, затем `/reload-skills` |
| 5 | **dox-setup** | DOX = self-documenting проекты (agent0ai/dox): иерархия AGENTS.md, агент читает цепочку до правок и обновляет после | скопировать каталог `skills/dox-setup/` в `~/.hermes/skills/`, затем `/reload-skills` |
| 6 | **officecli** | AI-friendly CLI для .docx/.xlsx/.pptx: создание, анализ, proofreading, правки, диаграммы. Один бинарник, без Office-инсталла. Наш внутренний (user-owned) | скопировать каталог `skills/officecli/` в `~/.hermes/skills/` + поставить сам бинарник `officecli` (инструкция внутри SKILL.md) |

### Установка git-guardrails (hook)

Hermes умеет гонять bash-хук перед опасными командами терминала. Два шага:

1. Скопировать скрипт:
```bash
cp hooks/block-dangerous-git.sh ~/.hermes/hooks/
chmod +x ~/.hermes/hooks/block-dangerous-git.sh
```

2. Прописать в `~/.hermes/config.yaml`:
```yaml
hooks:
  tool_use:
    - command: ~/.hermes/hooks/block-dangerous-git.sh
```

Поведение: любая команда, совпадающая со списком паттернов внутри скрипта, получает `BLOCKED: ... matches dangerous pattern ...` и не исполняется. Паттерны правятся в массиве `DANGEROUS_PATTERNS` внутри скрипта.

---

## Дизайн/фронт-пак (для инстансов, рендерящих UI)

| Скилл | Что | Установка |
|-------|-----|-----------|
| **layout-grid** | Grid-сетки: 4/8/12 колонок, breakpoints 375/768/1024/1440, gutters/margins | `npx skills add owl-listener/designer-skills@layout-grid -a hermes-agent -y` |
| **pixel-perfect-ui** | Автономный цикл pixel-perfect вёрстки: render → screenshot → compare → fix (2–4 раунда) | `npx skills add corlab-tech/skills@pixel-perfect-ui -a hermes-agent -y` |
| **screenshot-to-html** | Скриншот → HTML через vision. Принцип: реплицировать RENDERED state, не computed state | `npx skills add sevzq/screenshot-to-html@screenshot-to-html -a hermes-agent -y` |
| **frontend-layout-vision** | Сводный пайплайн трёх выше — грузить ПЕРВЫМ перед вёрсткой по макету (наш, адаптирован под Vue 3.5 + Tailwind 4) | скопировать каталог из K98: `~/.hermes/skills/engineering/frontend-layout-vision/` |

## Наши внутренние скиллы (не из ecosystem — свои, обновляются через этот repo)

| Каталог в `skills/` | Что внутри |
|---------|-----------|
| `llm-wiki/` | восстановлен из curator-архива, Karpathy wiki |
| `dox-setup/` | DOX (agent0ai) + наш RLM-генератор дочерних AGENTS.md (references/rlm-dox-generation.md) |
| `officecli/` | user-owned: SKILL.md + gotchas pptx-декам. Памятка Паши: batch rows match, re-run = close+create --force, ячейки = /body/tbl[N]/tr[R]/tc[C], JSON в /tmp |

Обновление инстансов: `git pull` этого репо → `cp -r skills/<name> ~/.hermes/skills/` → `/reload-skills`. Не через skills.sh.

---

## Дополнительные (по профилю инстанса)

| Скилл | Профиль |
|-------|---------|
| officecli (+docx/xlsx/pptx/pdf) | документооборот |
| mermaid-diagrams | диаграммы в ответах |
| github-auth, github-issue-to-pr | работа с GitHub |
| polza-image-generation | генерация изображений (Polza MCP) |
| tech-digest-aggregation | дайджесты при поломанном web_search |

## Отказано в сет-апе (осознанно)

- **agent-browser** (1.1M инстоллов) — у Hermes свои встроенные browser-инструменты
- **systematic-debugging** (obra) — есть локальный аналог `debugging-and-error-recovery` (собственный)
- vendor-скиллы (supabase/convex/azure/firebase) — useless если vendor не твой
- hyperframes и прочие 900k-банеры — демо-инстоллы, спам

---

## Массовая установка скриптом

См. [install.sh](install.sh) — катает базовый сет по списку инстансов (Docker и bare-metal).

## Содержимое репо

```
├── README.md                    ← этот файл
├── install.sh                   ← массовая установка по списку инстансов
├── hooks/
│   └── block-dangerous-git.sh   ← git-guardrails hook для Hermes
└── skills/
    ├── llm-wiki/                ← SKILL.md (Karpathy wiki)
    ├── dox-setup/               ← SKILL.md + references/scripts (DOX)
    └── officecli/               ← SKILL.md + references (Office-документы)
```

Хранение версий: скиллы 1/2 всегда свежие из skills.sh (поставщик сам апдейтит); 3–5 копируются с K98 и обновляются git-пуллом этого репо.