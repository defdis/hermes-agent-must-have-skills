# hermes-agent-must-have-skills

![Hermes Skills](banner.jpg)

**Маст-хэв набір скиллів для інстансів [Hermes Agent](https://github.com/NousResearch/hermes-agent).**

Ця колекція містить базовий набір скиллів, які корисні (або прямо необхідні) для кожного інстансу агента Hermes: автоматичний пошук і встановлення нових скиллів, створення власних, захист git від небезпечних команд, персистентна база знань, робота з Office-документами.

> Базовий набір із 6 позицій закриває ~80% типових задач агента. Дизайн-пак — для профілів, що рендерять UI. Розділ «Внутрішні» — власні скилли, яких немає в екосистемі.

## Склад базового набору

| Скилл | Що робить | Установка |
|-------|-----------|-----------|
| **[find-skills](https://skills.sh)** | Агент сам знаходить і ставить потрібні скилли через `npx skills`. Мета-навичка — ставиться першою | `npx skills add vercel-labs/find-skills -a hermes-agent -y` |
| **[skill-creator](https://skills.sh)** | Агент сам створює/редагує/тестує скилли за каноном SKILL.md | `npx skills add anthropics/skill-creator -a hermes-agent -y` |
| **git-guardrails** | Хук, що блокує небезпечні git-команди: `push --force`, `reset --hard`, `branch -D`, `clean -f` | [hooks/block-dangerous-git.sh](hooks/block-dangerous-git.sh) + секція у config.yaml |
| **[llm-wiki](skills/llm-wiki/SKILL.md)** | Персистентна wiki-база знань у маркдауні (патерн Andrej Karpathy): інжест джерел, крос-посилання, лінт консистентності. Альтернатива RAG | у цьому репо: `skills/llm-wiki/` |
| **[dox-setup](skills/dox-setup/SKILL.md)** | DOX-фреймворк ([agent0ai/dox](https://github.com/agent0ai/dox)): ієрархія AGENTS.md, агент читає ланцюжок до редагувань і оновлює після | у цьому репо: `skills/dox-setup/` |
| **[officecli](skills/officecli/SKILL.md)** | CLI для .docx/.xlsx/.pptx: створення, аналіз, перевірка, діаграми. Одна бінарка, без Office-встановлення | у цьому репо: `skills/officecli/` + бінарний `officecli` |

## Швидкий старт

```bash
# 1. З екосистеми skills.sh
npx skills add vercel-labs/find-skills -a hermes-agent -y
npx skills add anthropics/skill-creator -a hermes-agent -y

# 2. З цього репо
git clone https://github.com/defdis/hermes-agent-must-have-skills.git
cp -r hermes-agent-must-have-skills/skills/{llm-wiki,dox-setup,officecli} ~/.hermes/skills/

# 3. Git-guardrails
cp hermes-agent-must-have-skills/hooks/block-dangerous-git.sh ~/.hermes/hooks/
chmod +x ~/.hermes/hooks/block-dangerous-git.sh
```

Реєстрація хука у `~/.hermes/config.yaml`:

```yaml
hooks:
  tool_use:
    - command: ~/.hermes/hooks/block-dangerous-git.sh
```

## Масова установка (скрипт)

`install.sh` встановлює набір на список Docker-інстансів: `docker cp` скиллів і хука → реєстрація в config.yaml → curator adopt → рестарт gateway.

```bash
./install.sh "ім'я1 ім'я2 ..."
```

## Додатково (за профілем інстансу)

Дизайн/фронт-пак і профільні скилли — у [wiki на K98](https://github.com/defdis), за потреби: layout-grid, pixel-perfect-ui, screenshot-to-html, mermaid-diagrams, github-auth, polza-image-generation.

## Структура репозиторія

```
├── README.md                    ← цей файл
├── install.sh                   ← масова установка на Docker-інстанси
├── banner.jpg                   ← обкладинка
├── hooks/
│   └── block-dangerous-git.sh   ← git-guardrails хук
└── skills/
    ├── llm-wiki/                ← Karpathy wiki
    ├── dox-setup/               ← DOX (AGENTS.md ієрархія)
    └── officecli/               ← Office-документи
```

## Ліцензія

Скилли екосистеми — під власними ліцензіями авторів (MIT/Apache). Внутрішні скилли — MIT.

---

*Хостинґ: defdis · оновлено 21.10.2026*