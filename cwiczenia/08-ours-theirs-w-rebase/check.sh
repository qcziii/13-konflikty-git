#!/usr/bin/env bash
# Exercise 08: verifies the rebase of feature/translations onto main.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 08-ours-theirs-w-rebase: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch feature/translations
main_start=$(state_get main_start)
if [ "$(git rev-parse main)" = "$main_start" ]; then ok "main nietknięty"; else bad "main nietknięty"; fi
if [ "$(git merge-base main HEAD)" = "$main_start" ] && [ -z "$(git rev-list --merges "$main_start..HEAD")" ]; then
  ok "feature/translations przeniesiona na aktualny main, historia liniowa"
else
  bad "feature/translations przeniesiona na aktualny main, historia liniowa"
fi
actual=$(git log --reverse --format=%s "$main_start..HEAD" | paste -sd'|' -)
if [ "$actual" = "Update Polish translations (TransTool export 2026-01-02)|Use formal greeting" ]; then ok "oba commity feature są (te same opisy)"
else bad "oba commity feature są (te same opisy)" "jest: $actual"; fi
if [ "$(blob_of HEAD resources/messages_pl.properties)" = "$(state_get translations_blob)" ]; then
  ok "messages_pl.properties to dokładnie eksport TransTool z feature/translations"
else
  bad "messages_pl.properties to dokładnie eksport TransTool z feature/translations" "plik różni się od eksportu tłumaczy. Pomyliło się --ours z --theirs?
Porównaj z eksportem: git diff $(short "$(state_get feature_old_tip)")~1 HEAD -- resources/messages_pl.properties"
fi
check_no_markers HEAD
java_check HEAD "$EX_DIR/Check.java"
summary
