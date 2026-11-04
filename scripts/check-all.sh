#!/usr/bin/env bash
# Runs check.sh of every exercise (that has a sandbox) and prints a summary.
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ok=0; fail=0; none=0
for c in "$ROOT"/cwiczenia/*/; do
  name=$(basename "$c")
  if [ ! -d "$c/repo" ]; then
    echo "[ -- ] $name (brak piaskownicy: uruchom setup.sh)"; none=$((none+1)); continue
  fi
  if bash "$c/check.sh" > /dev/null 2>&1; then
    echo "[OK]   $name"; ok=$((ok+1))
  else
    echo "[FAIL] $name"; fail=$((fail+1))
  fi
done
echo
echo "Ćwiczenia: $ok OK, $fail FAIL, $none bez piaskownicy"
[ "$fail" -eq 0 ]
