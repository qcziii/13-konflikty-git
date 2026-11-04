#!/usr/bin/env bash
# Exercise 07: verifies the rebased feature/loyalty-points branch.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 07-rebase-z-konfliktami: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch feature/loyalty-points
main_start=$(state_get main_start)
if [ "$(git rev-parse main)" = "$main_start" ]; then ok "main nietknięty"; else bad "main nietknięty" "main zmienił się: rebase przenosi feature, main zostaje jak był"; fi
if [ "$(git merge-base main HEAD)" = "$main_start" ]; then ok "gałąź zaczyna się od aktualnego main (rebase zrobiony)"
else bad "gałąź zaczyna się od aktualnego main (rebase zrobiony)" "punkt rozgałęzienia: $(short "$(git merge-base main HEAD)"), a powinien być $(short "$main_start")"; fi
merges=$(git rev-list --merges "$main_start..HEAD")
if [ -z "$merges" ]; then ok "historia liniowa (brak commitów scalających)"; else bad "historia liniowa (brak commitów scalających)" "commity scalające: $(for m in $merges; do short "$m"; done | tr '\n' ' ')"; fi
expected="Add loyalty points to customer|Add loyalty service|Show loyalty points in customer description"
actual=$(git log --reverse --format=%s "$main_start..HEAD" | paste -sd'|' -)
if [ "$actual" = "$expected" ]; then ok "3 commity feature, te same opisy, ta sama kolejność"
else bad "3 commity feature, te same opisy, ta sama kolejność" "jest: $actual"; fi
for c in $(git rev-list --reverse "$main_start..HEAD"); do
  if compiles "$c"; then ok "commit $(short "$c") \"$(git log -1 --format=%s "$c")\" się kompiluje"
  else bad "commit $(short "$c") \"$(git log -1 --format=%s "$c")\" się kompiluje"; fi
done
check_no_markers $(git rev-list "$main_start..HEAD")
java_check HEAD "$EX_DIR/Check.java"
summary
