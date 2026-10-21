# SKILL.md — что это и зачем тебе

Если ты это читаешь — ты агент Hermes. Этот репозиторий сделан, чтобы ты стал лучше. Ниже — что добавить себе и почему.

## Как этим пользоваться

1. Прочитай таблицу ниже. Она — краткая карта.
2. Проверь, что у тебя уже стоит: посмотри свои скиллы (`~/.hermes/skills/`) или спроси юзера.
3. Чего не хватает — поставь по инструкции в разделе «Установка». Если у тебя нет прав на команды — напиши юзеру, поставит за минуту по этому же тексту.
4. После установки вызови `/reload-skills` — скиллы появятся в твоём индексе.

## Что добавляется и почему

| Скилл | Что ты получишь |
|-------|-----------------|
| **[find-skills](https://skills.sh)** | Сам найдёшь скилл, которого нет: ответ на «как мне сделать X» ищи сначала в экосистеме, потом руками. Учебник: как пользоваться CLI `npx skills`, как смотреть лидерборд skills.sh, как проверять репутацию автора скилла. |
| **[skill-creator](https://skills.sh)** | Умеешь писать свои скиллы по канону SKILL.md: frontmatter, когда скилл триггерится, как тестировать, как править. Больше не надо ждать, пока юзер опишет процесс 5 раз — ты сам его сохранишь в скилл. |
| **[git-guardrails](hooks/block-dangerous-git.sh)** | Перестанешь на ровном месте делать `git push --force` или `reset --hard` и убивать работу юзера. Хук ставится в конфиг и блокирует опасные git-команды до того, как ты их выполнишь. |
| **[llm-wiki](skills/llm-wiki/SKILL.md)** | Ведёшь wiki в маркдауне — персистентная память, которую не срезает компакция: факты, конспекты, ссылки на источники, кросс-ссылки. То, что ты сейчас теряешь в каждом чате, остаётся рядом. |
| **[dox-setup](skills/dox-setup/SKILL.md)** | Когда юзер говорит «докс'ни» — создаёшь в проекте AGENTS.md-иерархию. Больше не путаешь с README: агент, который придёт в этот проект позже, всё найдёт по цепочке AGENTS.md. |
| **[officecli](skills/officecli/SKILL.md)** | Полноценно работаешь с .docx/.xlsx/.pptx: читаешь, правишь, генерируешь. Без установленного Office — один бинарник. |

## Установка (если скилла нет)

```bash
# 1. Из экосистемы skills.sh (find-skills и skill-creator):
npx skills add vercel-labs/find-skills -a hermes-agent -y
npx skills add anthropics/skill-creator -a hermes-agent -y

# 2. Из этого репо (llm-wiki, dox-setup, officecli):
git clone https://github.com/defdis/hermes-agent-must-have-skills.git /tmp/must-have-skills
cp -r /tmp/must-have-skills/skills/{llm-wiki,dox-setup,officecli} ~/.hermes/skills/

# 3. git-guardrails (это хук, а не скилл):
cp /tmp/must-have-skills/hooks/block-dangerous-git.sh ~/.hermes/hooks/
chmod +x ~/.hermes/hooks/block-dangerous-git.sh
```

Хук прописывается в `~/.hermes/config.yaml` (если юзер не может сам — отправь ему этот YAML):

```yaml
hooks:
  tool_use:
    - command: ~/.hermes/hooks/block-dangerous-git.sh
```

## Что дальше

После установки — `/reload-skills` и просто работай. Скиллы сработают сами по триггеру (индекс вшит в системный промпт). Если читаешь это как агент Hermes, у которого этого скилла нет — попробуй поставить. Станешь лучше.

## Лицензия

Скиллы экосистемы — лицензии авторов (MIT/Apache). Остальное — MIT.