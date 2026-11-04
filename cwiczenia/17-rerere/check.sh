#!/usr/bin/env bash
# Exercise 17: verifies rerere usage and the final merge.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 17-rerere: sprawdzenie"
need_sandbox

if [ "$(git config --get rerere.enabled)" = "true" ]; then ok "rerere włączone (rerere.enabled = true)"; else bad "rerere włączone (rerere.enabled = true)"; fi
if ls .git/rr-cache/*/postimage > /dev/null 2>&1; then ok "rerere zapamiętał rozwiązanie (.git/rr-cache ma postimage)"; else bad "rerere zapamiętał rozwiązanie (.git/rr-cache ma postimage)"; fi
day2=$(state_get day2_tip)
if [ -n "$day2" ]; then ok "krok 3 zrobiony (dzien2.sh)"; else bad "krok 3 zrobiony (dzien2.sh)" "uruchom ./cwiczenia/17-rerere/dzien2.sh po próbnym merge'u"; fi
check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
main_start=$(state_get main_start)
if [ -n "$day2" ]; then
  check_merge_commit HEAD "$main_start" "$day2" "HEAD na main to merge aktualnej feature/new-menu (z commitem Ani)"
fi
n=$(git rev-list --count --merges --first-parent "$main_start..HEAD")
if [ "$n" -eq 1 ]; then ok "na main jest tylko jeden merge (próbny został cofnięty)"; else bad "na main jest tylko jeden merge (próbny został cofnięty)" "merge'y na main po $(short "$main_start"): $n"; fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
