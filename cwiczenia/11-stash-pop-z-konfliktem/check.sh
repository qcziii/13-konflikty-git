#!/usr/bin/env bash
# Exercise 11: verifies that main is up to date and the local work in progress survived, uncommitted.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 11-stash-pop-z-konfliktem: sprawdzenie"
need_sandbox

check_no_operation
check_no_unmerged
check_on_branch main
if [ "$(git rev-parse HEAD)" = "$(state_get origin_main)" ]; then ok "main = aktualny origin/main (zmiany kolegi pobrane, nic nie zacommitowane)"
elif is_ancestor "$(state_get origin_main)" HEAD; then bad "main = aktualny origin/main" "zmiany kolegi są, ale doszły Twoje commity: $(git log --format='%h %s' "$(state_get origin_main)..HEAD" | tr '\n' ';') (praca w toku miała zostać niezacommitowana)"
else bad "main = aktualny origin/main" "nie masz zmian z origin (git pull)"; fi
if [ -z "$(git stash list)" ]; then ok "schowek pusty (git stash list): nic nie wisi zapomniane"
else bad "schowek pusty (git stash list)" "$(git stash list)
po konflikcie git stash pop NIE usuwa wpisu: gdy wszystko jest na miejscu, usuń go (git stash drop)"; fi
if git diff --cached --quiet; then ok "nic nie jest dodane do indeksu (git diff --cached puste)"
else bad "nic nie jest dodane do indeksu" "$(git diff --cached --name-only)
po rozwiązaniu konfliktu ze stasha pliki zostają w indeksie: git restore --staged <plik>"; fi
if git diff --quiet -- src/shop/Pricing.java; then bad "Twoje zmiany w Pricing.java są w katalogu roboczym (niezacommitowane)" "Pricing.java = wersja z HEAD: praca w toku zginęła"
else ok "Twoje zmiany w Pricing.java są w katalogu roboczym (niezacommitowane)"; fi
check_no_markers_worktree
java_check WORKTREE "$EX_DIR/Check.java" "katalog roboczy"
summary
