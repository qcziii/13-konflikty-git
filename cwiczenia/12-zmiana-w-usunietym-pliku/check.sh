#!/usr/bin/env bash
# Exercise 12: verifies the merge of feature/senior-discount: old file stays deleted, the rule is ported.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 12-zmiana-w-usunietym-pliku: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/senior-discount"
check_file_absent HEAD src/shop/LegacyDiscountService.java "LegacyDiscountService.java dalej usunięty (main go celowo wyrzucił)"
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
