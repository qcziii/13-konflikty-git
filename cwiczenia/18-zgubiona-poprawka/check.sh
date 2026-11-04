#!/usr/bin/env bash
# Exercise 18: verifies the restored fix and the investigation result in the commit message.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 18-zgubiona-poprawka: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
main_start=$(state_get main_start); fix=$(state_get fix); bad_merge=$(state_get bad_merge)
if is_ancestor "$main_start" HEAD; then ok "historia main nie przepisana (main jest opublikowany)"; else bad "historia main nie przepisana (main jest opublikowany)" "nie wolno robić reset/rebase opublikowanej historii: napraw nowym commitem"; fi
n=$(git rev-list --count "$main_start..HEAD")
if [ "$n" -ge 1 ]; then ok "naprawa jest nowym commitem na main"; else bad "naprawa jest nowym commitem na main"; fi
if [ -z "$(git rev-list --merges "$main_start..HEAD")" ]; then ok "bez nowych merge'y i bez revertu merge'a"; else bad "bez nowych merge'y"; fi
if git log --format=%s "$main_start..HEAD" | grep -q '^Revert "Merge'; then bad "rabat hurtowy nie został wycofany (to nie revert merge'a)"; fi
msgs=$(git log --format=%B "$main_start..HEAD")
if printf '%s' "$msgs" | grep -qi "${fix:0:7}"; then ok "opis naprawy wskazuje commit z oryginalną poprawką ($(short "$fix")...)"
else bad "opis naprawy wskazuje commit z oryginalną poprawką" "w opisie nowego commita podaj skrót SHA (min. 7 znaków) commita, który wprowadził poprawkę"; fi
if printf '%s' "$msgs" | grep -qi "${bad_merge:0:7}"; then ok "opis naprawy wskazuje merge, w którym poprawka zginęła"
else bad "opis naprawy wskazuje merge, w którym poprawka zginęła" "w opisie nowego commita podaj skrót SHA (min. 7 znaków) commita scalającego, w którym zginęła poprawka"; fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
