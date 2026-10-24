---
name: grafity
description: "Код-граф для агентных задач: строит по репо граф (функции, классы, импорты, вызовы) и отвечает точными запросами — кто вызывает функцию, blast radius правки, dead code, god-функции. Вместо чтения целых файлов. Инструмент — code-review-graph (CRG), команда code-review-graph."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [code-graph, code-review, refactoring, tree-sitter, mcp]
    category: engineering
    related_skills: [skill-creator]
---

# Grafity — код-граф репозитория

«Графит» в наборе = инструмент [code-review-graph (CRG)](https://github.com/tirth8205/code-review-graph).
Старые имена той же задачи (grafity, graphify) больше не используются — команда одна: `code-review-graph`.

**Идея:** агент не перечитывает файлы, а спрашивает граф. Ревью, рефакторинг и навигация
по большому репо съедают в 38–528 раз меньше токенов, потому что агент получает выжимку
(«функцию X зовут 16 мест, Y не зовёт никто»), а не 10 копий кода.

Граф строится Tree-sitter'ом (без LLM), хранится в SQLite внутри проекта, обновляется
инкрементально.

## Установка

```bash
pip3 install code-review-graph
# Ubuntu/Debian с system-python при ошибке "externally-managed":
pip3 install --break-system-packages code-review-graph
```

CRITICAL провайдер парсеров: `tree-sitter-language-pack`. CRG проверяет парсеры через
`python -I -c ...` — флаг `-I` игнорирует user site-packages, поэтому пак должен стоять
в **системных** site-packages, иначе получите `0 nodes, 0 edges` с WARNING'ом:

```bash
sudo /usr/bin/python3 -m pip install --break-system-packages tree-sitter-language-pack
/usr/bin/python3 -I -c "from tree_sitter_language_pack import get_parser; get_parser('python'); print('OK')"
```

Языки: Python, JS/TS, Vue, Go, Rust, C/C++, Java, PHP, Ruby и ещё ~20. Работает на репо
 любого размера (проверено на монолитах с файлами >1MB — парсится посекционно).

## Базовый цикл

```bash
cd <repo>
code-review-graph build     # полный билд после клонирования
code-review-graph status    # ноды, рёбра, сообщества
code-review-graph update    # инкрементально — только изменённые файлы (секунды)
```

Граф лежит в `.code-review-graph/graph.db` внутри проекта — добавьте в `.gitignore`
(или используйте `graft/`-подобные аналоги). `update` инкрементальный: на репо в ~30
изменённых файлов переиндексация занимает секунды.

## Команды

| Команда | Что даёт |
|---|---|
| `build` / `update` | полный / инкрементальный билд графа |
| `status` | статистика: ноды, рёбра, сообщества |
| `query callers_of <fn>` | кто вызывает функцию (blast radius по коду) |
| `query callees_of <fn>` | кого вызывает |
| `query imports_of <file>` / `importers_of` | импорты файла (и кто его импортирует) |
| `query children_of <class>` | методы/вложения класса |
| `query tests_for <symbol>` | тесты, покрывающие символ |
| `query file_summary <file>` | резюме файла: символы, импорты, вызовы |
| `search <term>` | FTS-поиск по именам нод (напр. `search instance`) |
| `impact <symbol>` | blast radius: что затронет правка X |
| `dead-code` | недостижимый код, god-функции |
| `large-functions` | функции ≥50 строк — кандидаты на разрезание |
| `communities` / `architecture` | кластеризация + предупреждения архитектуры |
| `visualize` | интерактивный HTML-граф |
| `wiki` | markdown-вики по сообществам в `.code-review-graph/wiki/` |
| `serve` | MCP-сервер (stdio) для агентных платформ |
| `install` / `uninstall` | регистрация/снятие MCP-сервера и хуков |

## Правила

1. **`query` — только формальные паттерны**: `callers_of`, `callees_of`, `imports_of`,
   `importers_of`, `children_of`, `tests_for`, `inheritors_of`, `file_summary`.
   Естественный язык (`query "как работает X?"`) вернёт ошибку — для этого `search`.
2. **Update после правок.** Граф сам не свежеет (нет file-watcher'а по умолчанию).
   Поменял код — `code-review-graph update`, потом спрашивай.
3. Перед ревью/рефакторингом сначала `status` + `large-functions` + `dead-code`:
   они дают карту проблем, с которой идёшь в `query`/`impact`.
4. Двусмысленные имена: ответ попросит `qualified_name` — повтори запрос с модулем.

## Питфоллы

- **Пустой граф (0 нод)** — см. установку `tree-sitter-language-pack` выше: CRG зовёт
  парсер через `python -I`, user site-packages игнорируются.
- **venv vs system python:** CRG ставится в системный питон; если в окружении активен
  venv, проверьте `which code-review-graph` и вызывайте бинарь напрямую.
- **Граф протух:** после больших правок забытый `update` даёт ответы по схеме
  месячной давности. Привычка: `update` перед запросами.
- **`query` на естественном языке** — не работает (ошибка invalid choice). Только формальные
  паттерны или `search`.
- **Не путать с graphify** — удалённый прежний инструмент той же задачи; команда одна.

## Разделение ролей с Graft (опциональный компаньон)

Graft (npm `@nanonets/graft`) — НЕ замена, у них разные работы:
- **CRG** — структурная диагностика: dead-code, large-functions, impact, communities.
- **Graft** — навигационный контекст: `map` / `ask` (лексический), `callers`, `blast`
  по незакоммиченному диффу; markdown-карта, автообновляется при каждом запросе.
- Живут вместе в одном репо, оба в gitignore. Для проверки risk'а перед коммитом:
  `graft blast --base origin/main`; для формального dead-code: `code-review-graph dead-code`.

## Оценка эффекта

Запускал на реальном менеджерском репо (~120 файлов, ~600 нод, ~1400 рёбер):
`map`-эквивалент экономил ~150K токенов за одну ориентацию, точечные запросы — десятки
тысяч на вопрос. Окупается на репо от ~50 файлов; на маленьких скриптах быстрее глазами.