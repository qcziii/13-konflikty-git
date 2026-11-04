#!/usr/bin/env bash
# Exercise 02: verifies the merge of feature/paypal into main.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 02-obie-zmiany-zostaja: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/paypal"
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
