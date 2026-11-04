#!/usr/bin/env bash
# Exercise 09: verifies feature/search on origin: rebased onto main, linear, nobody's commit lost.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 09-rebase-i-force-with-lease: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
origin_main=$(git --git-dir="$ORIGIN" rev-parse main)
of=$(git --git-dir="$ORIGIN" rev-parse feature/search)
git cat-file -e "$of" 2> /dev/null || git fetch -q origin
if [ "$origin_main" = "$(state_get origin_main)" ]; then ok "main na origin nietknięty"; else bad "main na origin nietknięty"; fi
if [ "$of" = "$(state_get ania_tip)" ]; then bad "feature/search na origin zaktualizowana (git push)" "na origin dalej jest stara wersja gałęzi"; else ok "feature/search na origin zaktualizowana (git push)"; fi
if [ "$(git merge-base "$origin_main" "$of")" = "$origin_main" ]; then ok "feature/search zaczyna się od aktualnego main (rebase zrobiony)"
else bad "feature/search zaczyna się od aktualnego main (rebase zrobiony)"; fi
if [ -z "$(git rev-list --merges "$origin_main..$of")" ]; then ok "historia liniowa (bez merge'y)"; else bad "historia liniowa (bez merge'y)" "zespół wymaga rebase, nie merge"; fi
subjects=$(git log --format=%s "$origin_main..$of")
for s in "Add product search by name" "Limit search results to 10" "Ignore blank search queries"; do
  n=$(printf '%s\n' "$subjects" | grep -cxF "$s")
  if [ "$n" -eq 1 ]; then ok "commit \"$s\" jest na origin/feature/search (dokładnie raz)"
  elif [ "$n" -eq 0 ]; then
    if [ "$s" = "Ignore blank search queries" ]; then
      bad "commit \"$s\" jest na origin/feature/search (dokładnie raz)" "zniknął commit Ani! Force push nadpisał jej pracę. Odzyskaj go: git reflog show origin/feature/search (to $(short "$(state_get ania_tip)")), git cherry-pick, push"
    else bad "commit \"$s\" jest na origin/feature/search (dokładnie raz)" "brak"; fi
  else bad "commit \"$s\" jest na origin/feature/search (dokładnie raz)" "jest $n razy"; fi
done
n=$(git rev-list --count "$origin_main..$of")
if [ "$n" -eq 3 ]; then ok "na gałęzi są dokładnie 3 commity ponad main"; else bad "na gałęzi są dokładnie 3 commity ponad main" "jest $n"; fi
if [ "$(git rev-parse feature/search)" = "$of" ]; then ok "lokalna feature/search = origin/feature/search"; else bad "lokalna feature/search = origin/feature/search"; fi
check_no_markers "$of"
java_check "$of" "$EX_DIR/Check.java" "origin/feature/search"
summary
