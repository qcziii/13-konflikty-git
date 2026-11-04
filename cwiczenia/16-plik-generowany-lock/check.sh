#!/usr/bin/env bash
# Exercise 16: verifies deps.txt (both sides) and that deps.lock is exactly what the generator produces.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 16-plik-generowany-lock: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/guava"
check_no_markers HEAD
deps=$(git show HEAD:deps.txt)
for d in org.slf4j:slf4j-api:2.0.17 com.fasterxml.jackson.core:jackson-databind:2.18.3 org.junit.jupiter:junit-jupiter:5.11.4 \
         org.postgresql:postgresql:42.7.4 com.google.guava:guava:33.3.1-jre; do
  if printf '%s\n' "$deps" | grep -qxF "$d"; then ok "deps.txt: $d"; else bad "deps.txt: $d" "brak tej linii"; fi
done
n=$(printf '%s\n' "$deps" | grep -vcE '^[[:space:]]*(#|$)')
if [ "$n" -eq 5 ]; then ok "deps.txt: dokładnie 5 zależności (bez starych wersji)"; else bad "deps.txt: dokładnie 5 zależności" "jest $n"; fi

# Regenerate the lock from the committed deps.txt with the original generator and compare.
tmp="$EX_DIR/.check/lock"; rm -rf "$tmp"; mkdir -p "$tmp/tools"
git show "$(state_get main_start)":tools/lock.sh > "$tmp/tools/lock.sh"
printf '%s\n' "$deps" > "$tmp/deps.txt"
bash "$tmp/tools/lock.sh" > /dev/null
if [ "$(git show HEAD:deps.lock)" = "$(cat "$tmp/deps.lock")" ]; then ok "deps.lock = dokładnie to, co generuje tools/lock.sh z deps.txt"
else bad "deps.lock = dokładnie to, co generuje tools/lock.sh z deps.txt" "$(diff <(git show HEAD:deps.lock) "$tmp/deps.lock" | head -6)
plik lock poprawia się generatorem, nie ręcznie"; fi
summary
