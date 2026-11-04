#!/usr/bin/env bash
# Exercise 03: verifies that the PR branch on origin contains current main and was not rewritten.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 03-konflikt-w-pull-requescie: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree

origin_main=$(git --git-dir="$ORIGIN" rev-parse main)
origin_feature=$(git --git-dir="$ORIGIN" rev-parse feature/discount-codes)
if [ "$origin_main" = "$(state_get origin_main)" ]; then ok "main na origin nietknięty (zmiany idą przez PR, nie prosto do main)"
else bad "main na origin nietknięty" "main na origin wskazuje teraz $(git --git-dir="$ORIGIN" rev-parse --short main), a nie powinien się zmienić"; fi

if [ "$origin_feature" = "$(state_get feature_start)" ]; then
  bad "gałąź PR-a na origin została zaktualizowana (git push)" "origin/feature/discount-codes dalej wskazuje stary commit"
else
  ok "gałąź PR-a na origin została zaktualizowana (git push)"
fi
git cat-file -e "$origin_feature" 2> /dev/null || git fetch -q origin
check "gałąź PR-a zawiera aktualny main z origin (konflikt PR-a rozwiązany)" is_ancestor "$origin_main" "$origin_feature"
if is_ancestor "$(state_get feature_start)" "$origin_feature"; then
  ok "historia PR-a nie została przepisana (stare commity PR-a dalej w historii, bez force push)"
else
  bad "historia PR-a nie została przepisana" "stare commity PR-a zniknęły z gałęzi (rebase + force push?). W tym zespole aktualizujemy PR merge'em"
fi
if [ "$(nparents "$origin_feature")" -eq 2 ]; then ok "na czubku gałęzi PR-a jest commit scalający main"
else bad "na czubku gałęzi PR-a jest commit scalający main" "ostatni commit na origin/feature/discount-codes nie jest merge'em"; fi
if [ "$(git rev-parse feature/discount-codes 2> /dev/null)" = "$origin_feature" ]; then ok "lokalna gałąź = gałąź na origin (wszystko wypchnięte)"
else bad "lokalna gałąź = gałąź na origin (wszystko wypchnięte)" "lokalna feature/discount-codes różni się od origin"; fi

check_no_markers "$origin_feature"
java_check "$origin_feature" "$EX_DIR/Check.java" "gałąź PR-a na origin"
summary
