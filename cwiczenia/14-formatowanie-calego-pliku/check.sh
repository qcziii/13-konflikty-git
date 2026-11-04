#!/usr/bin/env bash
# Exercise 14: verifies the merge of feature/new-rates: new rates AND the new formatting.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 14-formatowanie-calego-pliku: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
main_start=$(state_get main_start)
if is_ancestor "$main_start" HEAD && is_ancestor "$(state_get feature_tip)" HEAD && [ "$(nparents HEAD)" -eq 2 ]; then
  ok "HEAD na main to merge, który zawiera main i feature/new-rates"
else
  bad "HEAD na main to merge, który zawiera main i feature/new-rates"
fi
if is_ancestor "$main_start" HEAD && [ "$(git rev-parse HEAD^1)" = "$main_start" ]; then ok "pierwszy rodzic merge'a = poprzedni main"
else bad "pierwszy rodzic merge'a = poprzedni main"; fi
tabs=$(git grep -n "$(printf '\t')" HEAD -- src 2> /dev/null | sed 's/^[^:]*://' | head -5)
if [ -z "$tabs" ]; then ok "w kodzie nie ma tabulatorów (formatowanie z main zachowane)"
else bad "w kodzie nie ma tabulatorów (formatowanie z main zachowane)" "$tabs
(git merge -X ignore-space-change potrafi po cichu przywrócić stare formatowanie: sprawdź wynik merge'a)"; fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
