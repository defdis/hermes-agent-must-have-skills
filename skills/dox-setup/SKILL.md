---
name: dox-setup
description: Установка DOX (AGENTS.md hierarchy) от agent0ai/dox в проект — скачивание шаблона, создание дочерних AGENTS.md с автоопределением структуры.
---

# DOX Setup — установка фреймворка в проект

Устанавливает [agent0ai/dox](https://github.com/agent0ai/dox) — мини-фреймворк само-документирующихся проектов через `AGENTS.md`. DOX заставляет агента читать цепочку AGENTS.md перед правками и обновлять их после.

## Trigger

Когда пользователь говорит **«dox»**, **«dox'ни»**, **«задокси»** — он имеет в виду именно DOX (AGENTS.md hierarchy), НЕ обычную документацию, НЕ RLM-анализ, НЕ README. Это частая путаница — НЕ предлагай `rlm_complete` или написание README.md когда пользователь просит «dox».

**PITFALL (реальный случай):** Я запустил `rlm_complete` для «докс'ни этот проект» — пользователь имел в виду DOX (AGENTS.md дерево), а не RLM-анализ. RLM потратил 5 минут на генерацию README, который никому не нужен. DOX = создание/инициализация AGENTS.md файлов с правилами чтения/обновления. Если пользователь говорит «dox» — сразу скачай шаблон и создавай дерево AGENTS.md, НЕ вызывай RLM.

## Что такое DOX (кратко)

DOX = иерархия AGENTS.md файлов в проекте:
- Root `AGENTS.md` — правила чтения/обновления + Child DOX Index
- Child `AGENTS.md` в подпапках — Purpose, Ownership, Local Contracts, Work Guidance, Verification, Child DOX Index
- Агент читает цепочку от root до целевой папки перед редактированием
- После изменений — обновляет соответствующий AGENTS.md (DOX pass)

## Процесс установки

### Шаг 1: Скачать корневой AGENTS.md

```bash
curl -sL https://raw.githubusercontent.com/agent0ai/dox/main/AGENTS.md -o /path/to/project/AGENTS.md
```

### Шаг 2: Создать дочерние AGENTS.md

Используй скрипт `scripts/create-children.py` из этого скилла — он рекурсивно сканирует проект и создаёт `AGENTS.md` в каждой директории, где есть код.

```bash
python3 /home/kiberslav/.hermes/skills/software-development/dox-setup/scripts/create-children.py /path/to/project
```

### Шаг 3 (опционально): обновить корневой Child DOX Index

После создания дочерних AGENTS.md нужно вручную заполнить Child DOX Index в корневом файле — перечислить все дочерние AGENTS.md и их области ответственности.

### Шаг 4 (опционально): генерация через RLM

Вместо ручного написания AGENTS.md для новой директории, можно использовать RLM (Recursive Language Model) — модель сама проанализирует структуру проекта и сгенерирует AGENTS.md.

**Когда использовать:** сложные проекты с 10+ директориями, когда ручное написание займёт слишком долго. RLM рекурсивно изучает контекст, выполняет код для проверки гипотез, и синтезирует результат.

**Требования:**
- RLM venv: `~/.hermes/rlm/.venv/` с установленными `openai`, `python-dotenv`, `rich`
- RLM repo: `~/.hermes/rlm/repo/` (github.com/alexzhang13/rlm, commit 156fd72)
- Env vars: `RLM_OPENAI_BASE_URL`, `RLM_OPENAI_API_KEY`, `RLM_MODEL`

**Пример скрипта** — см. `references/rlm-dox-generation.md`.

**Важно:** RLM генерирует качественный, но не идеальный DOX. Всегда проверяй результат — модель может пропустить нюансы проекта, которые очевидны при ручном анализе. Используй RLM как черновик, затем дорабатывай.

**PITFALL (реальный случай, 2026-07-03):** `rlm_complete` tool вернул управляющий код (`answer["content"] = result; answer["ready"] = True`) вместо текста AGENTS.md. RLM «понял» задачу как программирование, а не генерацию текста. Решение: запускать через `~/.hermes/rlm/.venv/bin/python` напрямую с промптом из файла, НЕ через `rlm_complete` tool.

**Проверенный паттерн (2026-07-03, hermes-manager, 4 файла за ~30 сек):**
1. Собери контекст по каждой папке (grep routes, models, functions)
2. Запиши промпт в `/tmp/rlm-dox-prompt.txt` с описанием каждой папки
3. Запусти `~/.hermes/rlm/.venv/bin/python /tmp/rlm-dox-runner.py 2>/dev/null` (stderr подавить — RLM verbose логи)
4. Раздели вывод по `===END_FILE===`, запиши каждый файл в `<folder>/AGENTS.md`
5. Обнови Child DOX Index в родительском AGENTS.md

**Установка RLM venv** (если ещё не установлен):
```bash
python3 -m venv ~/.hermes/rlm/.venv
~/.hermes/rlm/.venv/bin/pip install openai python-dotenv rich httpx
git clone https://github.com/alexzhang13/rlm.git ~/.hermes/rlm/repo
cd ~/.hermes/rlm/repo && git checkout 156fd72
```

**Pitfall при использовании `rlm_complete` tool:** RLM может вернуть управляющий код (`answer["content"] = result; answer["ready"] = True`) вместо текста. В этом случае запускай через terminal + Python скрипт напрямую:

```bash
export RLM_OPENAI_BASE_URL=$(grep '^RLM_OPENAI_BASE_URL=' ~/.hermes/.env | cut -d= -f2-)
export RLM_OPENAI_API_KEY=$(grep '^RLM_OPENAI_API_KEY=' ~/.hermes/.env | cut -d= -f2-)
export RLM_MODEL=$(grep '^RLM_MODEL=' ~/.hermes/.env | cut -d= -f2-)

~/.hermes/rlm/.venv/bin/python << 'PYEOF'
import sys, os
sys.path.insert(0, os.path.expanduser("~/.hermes/rlm/repo"))
for line in open(os.path.expanduser("~/.hermes/.env")):
    if "=" in line and not line.startswith("#"):
        k, v = line.strip().split("=", 1)
        os.environ[k] = v
from rlm import RLM
rlm = RLM(backend="openai", backend_kwargs={
    "base_url": os.environ["RLM_OPENAI_BASE_URL"],
    "api_key": os.environ["RLM_OPENAI_API_KEY"],
    "model_name": os.environ["RLM_MODEL"],
}, max_iterations=5, max_timeout=150, verbose=False)
prompt = open("/tmp/rlm-dox-prompt.txt").read()
result = rlm.completion(prompt=prompt)
answer = result.response if hasattr(result, "response") else str(result)
print(answer)
PYEOF
```

**Реальный запуск (2026-07-03, hermes-manager):** glm-5.2, ~30 сек, 4 AGENTS.md файла (pages, sections, components/ui, lib) за один прогон. Промпт 5KB с контекстом по каждой папке (routes, components, API methods, tech stack). Вывод разделён `===END_FILE===`, каждый блок записан в `<folder>/AGENTS.md`.

## Pitfalls

- **Не создавать AGENTS.md там где их нет.** DOX работает через родительский AGENTS.md + сканирование файловой системы. Не нужно создавать дочерние в каждой папке.
- **DOX не мешает graphify** — они решают разные задачи: DOX документирует правила, graphify строит граф зависимостей.
- **AGENTS.md ≠ CLAUDE.md.** DOX использует именно `AGENTS.md` в каждой директории, не другие имена.
- **Архив с DOX — без исходников.** Когда пользователь просит «скинь архив DOX», архивируй ТОЛЬКО файлы AGENTS.md, не весь проект. Команда: `find /path -name "AGENTS.md" | tar czf dox.tar.gz -T -`. Если заархивировать с кодом — пользователь получит лишние сотни KB/MB исходников, которые ему не нужны.
- **RLM генерация — дочерние DOX пачкой.** RLM может сгенерировать AGENTS.md для всех подпапок за один запуск (13 файлов за ~2 мин). Подготовь контекст по каждой папке (модели, views, URL-роуты), передай одним промптом с `===END_FILE===` разделителем. Пример — в `references/rlm-dox-generation.md`.
