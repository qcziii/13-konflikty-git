#!/usr/bin/env bash
# Exercise 13: verifies the merge of feature/invoice: one class name (PriceFormatter), nothing lost.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 13-zmiana-nazwy-pliku: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/invoice"
check_file_absent HEAD src/shop/Formatter.java "nie ma starego Formatter.java"
check_file_absent HEAD src/shop/MoneyFormatter.java "nie ma MoneyFormatter.java (obowiązuje nazwa z main)"
hits=$(git grep -n MoneyFormatter HEAD -- src | sed 's/^[^:]*://')
if [ -z "$hits" ]; then ok "nigdzie w kodzie nie ma odwołań do MoneyFormatter"; else bad "nigdzie w kodzie nie ma odwołań do MoneyFormatter" "$hits"; fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
