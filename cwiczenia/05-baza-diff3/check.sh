#!/usr/bin/env bash
# Exercise 05: verifies the merge of feature/reports into main and the conflictStyle setting.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 05-baza-diff3: sprawdzenie"
need_sandbox

style=$(git config --get merge.conflictStyle)
case "$style" in
  diff3|zdiff3) ok "merge.conflictStyle = $style (konflikty pokazują też bazę)" ;;
  *) bad "merge.conflictStyle ustawione na zdiff3 albo diff3" "teraz: ${style:-domyślne merge}" ;;
esac
check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/reports"
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
