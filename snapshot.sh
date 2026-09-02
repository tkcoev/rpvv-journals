#!/bin/bash
# Снимок журналов контура Трекера во внешнюю копию (решение ГД 03.09.2026, п. 15).
# Корпус out/tracker.db не копируется: он пересобирается из Трекера и в GitHub не помещается.
set -u
export HOME=/root
SRC=/opt/tracker-tools/out
DST=/opt/tracker-journals
LOG=/var/log/repos-push.log
cd "$DST" || exit 1
mkdir -p out/automats out/pipeline
cp -p "$SRC"/*.jsonl out/ 2>/dev/null
cp -p "$SRC"/*.md out/ 2>/dev/null
cp -p "$SRC"/opros*.json out/ 2>/dev/null
cp -p "$SRC"/automats/*.jsonl out/automats/ 2>/dev/null
cp -p "$SRC"/pipeline/okna.json out/pipeline/ 2>/dev/null
git add -A
if git diff --cached --quiet; then echo "$(date '+%F %T') journals: без изменений" >> "$LOG"; exit 0; fi
git -c user.name="Контур Трекера" -c user.email="noreply@anthropic.com" commit -q -m "Снимок журналов $(date '+%d.%m.%Y %H:%M')" || exit 1
if git remote get-url origin >/dev/null 2>&1; then
  if git push -q origin HEAD:master 2>>"$LOG"; then echo "$(date '+%F %T') journals -> github tkcoev/rpvv-journals OK" >> "$LOG"
  else echo "$(date '+%F %T') journals: push не прошёл (репозиторий rpvv-journals ещё не создан?)" >> "$LOG"; fi
fi
