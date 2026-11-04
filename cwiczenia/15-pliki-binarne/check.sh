#!/usr/bin/env bash
# Exercise 15: verifies which version of each binary file ended up in the merge.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 15-pliki-binarne: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_clean_tree
check_on_branch main
check_merge_commit HEAD "$(state_get main_start)" "$(state_get feature_tip)" \
  "HEAD na main to merge: pierwszy rodzic = poprzedni main, drugi = feature/rebranding"
which_version() {   # which_version <path>: says which branch the blob in HEAD comes from
  local b; b=$(blob_of HEAD "$1")
  if [ "$b" = "$(blob_of "$(state_get main_start)" "$1")" ]; then echo "wersja z main"
  elif [ "$b" = "$(blob_of "$(state_get feature_tip)" "$1")" ]; then echo "wersja z feature/rebranding"
  elif [ -z "$b" ]; then echo "plik usunięty"
  else echo "jakaś inna wersja (plik zepsuty?)"; fi
}
if [ "$(blob_of HEAD assets/logo.png)" = "$(state_get logo_expected)" ]; then ok "assets/logo.png: nowe logo z feature/rebranding"
else bad "assets/logo.png: nowe logo z feature/rebranding" "jest: $(which_version assets/logo.png)"; fi
if [ "$(blob_of HEAD assets/banner.png)" = "$(state_get banner_expected)" ]; then ok "assets/banner.png: baner z main (wymóg prawny)"
else bad "assets/banner.png: baner z main (wymóg prawny)" "jest: $(which_version assets/banner.png)"; fi
if git show HEAD:assets/theme.css | grep -q -- '--brand: #145ac8;'; then ok "theme.css: nowy kolor marki (scalony automatycznie)"; else bad "theme.css: nowy kolor marki"; fi
summary
