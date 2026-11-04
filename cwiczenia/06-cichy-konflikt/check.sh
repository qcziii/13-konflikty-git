#!/usr/bin/env bash
# Exercise 06: verifies that the merge commit itself builds and behaves correctly.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 06-cichy-konflikt: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
main_start=$(state_get main_start)
merge=$(git rev-list --merges --first-parent "$main_start..HEAD" | tail -1)
if [ -z "$merge" ]; then
  bad "na main jest merge feature/gift-cards" "nie ma commita scalającego po $(short "$main_start")"
else
  check_merge_commit "$merge" "$main_start" "$(state_get feature_tip)" \
    "merge feature/gift-cards: pierwszy rodzic = poprzedni main, drugi = feature/gift-cards"
  if [ "$merge" = "$(git rev-parse HEAD)" ]; then
    ok "poprawki są w samym commicie scalającym (bez osobnego commita 'fix build' po nim)"
  else
    bad "poprawki są w samym commicie scalającym" "po merge'u są jeszcze commity: $(git log --format='%h %s' "$merge..HEAD" | tr '\n' ';')
merge, który się nie kompiluje, psuje git bisect i każdy checkout tego commita. Popraw sam merge (patrz ZADANIE)"
  fi
  if compiles "$merge"; then ok "commit scalający $(short "$merge") się kompiluje"; else bad "commit scalający $(short "$merge") się kompiluje"; fi
fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
