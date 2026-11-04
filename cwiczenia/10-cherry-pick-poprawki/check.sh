#!/usr/bin/env bash
# Exercise 10: verifies that only the hotfix was cherry-picked onto main, with -x.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 10-cherry-pick-poprawki: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
main_start=$(state_get main_start); fix=$(state_get fix)
if [ "$(git rev-parse release/1.4)" = "$(state_get release_tip)" ]; then ok "release/1.4 nietknięta"; else bad "release/1.4 nietknięta"; fi
if is_ancestor "$main_start" HEAD; then ok "historia main nie przepisana"; else bad "historia main nie przepisana"; fi
n=$(git rev-list --count "$main_start..HEAD")
if [ "$n" -eq 1 ] && [ "$(nparents HEAD)" -eq 1 ]; then ok "na main doszedł dokładnie jeden zwykły commit (nie merge)"
else bad "na main doszedł dokładnie jeden zwykły commit (nie merge)" "nowych commitów: $n$( [ "$(nparents HEAD)" -eq 2 ] && echo ', ostatni to merge: merge release/1.4 wciągnąłby też podbicie wersji')"; fi
if git log -1 --format=%B HEAD | grep -qF "(cherry picked from commit $fix)"; then ok "opis commita ma adnotację (cherry picked from commit $(short "$fix")) (opcja -x)"
else bad "opis commita ma adnotację (cherry picked from commit $(short "$fix"))" "użyj git cherry-pick -x (jeśli już zrobione bez -x: git commit --amend i dopisz linię)"; fi
if git log -1 --format=%s HEAD | grep -qF "Fix VAT rounding"; then ok "opis commita zachowany z oryginału"; else bad "opis commita zachowany z oryginału"; fi
if [ "$(git show HEAD:version.txt)" = "2.0.0-SNAPSHOT" ]; then ok "version.txt na main dalej 2.0.0-SNAPSHOT (podbicie wersji z release nie trafiło na main)"
else bad "version.txt na main dalej 2.0.0-SNAPSHOT" "jest: $(git show HEAD:version.txt)"; fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
