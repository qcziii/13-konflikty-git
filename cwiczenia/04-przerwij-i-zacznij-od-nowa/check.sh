#!/usr/bin/env bash
# Exercise 04: verifies the redone merge of feature/categories into main.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 04-przerwij-i-zacznij-od-nowa: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/categories"
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
