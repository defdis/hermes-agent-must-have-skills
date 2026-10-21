#!/bin/bash
# Массовая установка базового сета скиллов на инстансы Hermes (K98)
# Использование: ./install.sh "имя1 имя2 ..."
# Docker-инстансы: docker cp + adopt. Bare-metal: пропускаются с предупреждением (пока вручную).

set -euo pipefail

INSTANCE_LIST="${1:-}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$INSTANCE_LIST" ]; then
  echo "Использование: $0 \"instance1 instance2 ...\""
  exit 1
fi

SKILLS="find-skills skill-creator llm-wiki dox-setup officecli"
HOOK_SRC="$REPO_DIR/hooks/block-dangerous-git.sh"

for inst in $INSTANCE_LIST; do
  container="hermes-$inst"
  if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
    echo "⚠  $inst: docker-контейнер $container не найден/не запущен — ПРОПУСК"
    continue
  fi

  echo "→ $inst (container=$container)"
  for s in $SKILLS; do
    if [ -d "$REPO_DIR/skills/$s" ]; then
      docker cp "$REPO_DIR/skills/$s" "$container:/home/hermes/.hermes/skills/" >/dev/null
    else
      # npx-skills скиллы (find-skills, skill-creator) не храним в репо — ставим внутрь контейнера CLI
      docker exec "$container" npx -y skills add "vercel-labs/find-skills" -a hermes-agent -y >/dev/null 2>&1 \
        || echo "  ⚠ $s: не удалось поставить через npx — проверить вручную"
    fi
  done

  # git-guardrails hook
  docker cp "$HOOK_SRC" "$container:/home/hermes/.hermes/hooks/block-dangerous-git.sh" >/dev/null
  docker exec "$container" chmod +x /home/hermes/.hermes/hooks/block-dangerous-git.sh

  # зарегистрировать hook в config.yaml если ещё нет
  docker exec "$container" bash -c '''
    CFG=/home/hermes/.hermes/config.yaml
    grep -q "block-dangerous-git.sh" $CFG || cat >> $CFG <<< "
hooks:
  tool_use:
    - command: ~/.hermes/hooks/block-dangerous-git.sh
"
  '''

  # переадопт скиллов curator-ом
  docker exec -e HOME=/home/hermes "$container" hermes curator adopt --all-unmanaged --yes >/dev/null 2>&1 || echo "  ⚠ curator adopt не прошёл"

  # рестарт gateway для перечитки config.yaml
  docker exec "$container" hermes restart >/dev/null 2>&1 || echo "  ⚠ hermes restart не прошёл (можно руками)"

  echo "  ✓ $inst готов"
done

echo ""
echo "Готово. Проверка: docker exec hermes-<name> ls /home/hermes/.hermes/skills/"