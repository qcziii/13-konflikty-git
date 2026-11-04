#!/usr/bin/env bash
# Exercise 19: verifies the integration: three merges in order, each one builds, final behaviour.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 19-projekt-dzien-integracji: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
main_start=$(state_get main_start)
chain=$(git rev-list --first-parent --reverse "$main_start..HEAD")
set -- $chain
if [ $# -eq 3 ]; then ok "na main (first-parent) są dokładnie 3 nowe commity"; else bad "na main (first-parent) są dokładnie 3 nowe commity" "jest $# (oczekiwane: 3 commity scalające, po jednym na PR, bez fast-forward i bez dodatkowych commitów)"; fi
prev=$main_start; i=1
for pr in pr1 pr2 pr3; do
  m=${!i}
  name=$(case $pr in pr1) echo feature/newsletter ;; pr2) echo feature/money-type ;; pr3) echo feature/coupons ;; esac)
  if [ -n "$m" ]; then
    check_merge_commit "$m" "$prev" "$(state_get $pr)" "merge $i: $name (pierwszy rodzic = poprzedni main)"
    if compiles "$m"; then ok "merge $i ($(short "$m")) się kompiluje"; else bad "merge $i ($(short "$m")) się kompiluje" "każdy merge na main ma się budować (popraw w samym merge'u, git commit --amend)"; fi
    prev=$m
  else
    bad "merge $i: $name"
  fi
  i=$((i+1))
done
check_no_markers $chain
check_file_absent HEAD src/shop/Notifications.java "Notifications.java usunięty (decyzja z PR coupons)"
log=$(git show HEAD:CHANGELOG.md | sed -n '/^## Unreleased/,/^## 1.0.0/p' | grep '^- ' | paste -sd'|' -)
if [ "$log" = "- Newsletter signup|- Money type for amounts|- Discount coupons" ]; then ok "CHANGELOG: trzy wpisy w kolejności scalania"
else bad "CHANGELOG: trzy wpisy w kolejności scalania" "sekcja Unreleased: $log"; fi
java_check HEAD "$EX_DIR/Check.java"
summary
