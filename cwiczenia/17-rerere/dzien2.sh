#!/usr/bin/env bash
# Exercise 17, step 3: "the next day" a colleague adds a commit to feature/new-menu.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
need_sandbox
[ "$(git config --get rerere.enabled)" = "true" ] || die "krok 1: najpierw włącz rerere (git config rerere.enabled true)"
ls .git/rr-cache/*/postimage > /dev/null 2>&1 || die "krok 2: rerere nie zapamiętał jeszcze żadnego rozwiązania (zrób próbny merge, rozwiąż i zacommituj)"
[ "$(git rev-parse main)" = "$(state_get main_start)" ] || die "krok 2: cofnij próbny merge na main (main ma wrócić do $(short "$(state_get main_start)"))"
[ -n "$(state_get day2_tip)" ] && die "dzien2.sh już był uruchomiony (od nowa: setup.sh)"
[ -f "$(git_dir)/MERGE_HEAD" ] && die "trwa merge: dokończ albo przerwij (git merge --abort)"
current=$(git symbolic-ref -q --short HEAD)
git switch -q feature/new-menu || die "nie da się przełączyć na feature/new-menu (masz niezacommitowane zmiany?)"
as "Ania Nowak" anowak
write src/shop/Help.java <<'EOF'
package shop;

public class Help {
    public static String text() {
        return "Masz pytanie? Napisz do nas: pomoc@sklep.example";
    }
}
EOF
git add -A && GIT_AUTHOR_DATE="@1767600000 +0100" GIT_COMMITTER_DATE="@1767600000 +0100" git commit -q -m "Add contact e-mail to help page"
state_set day2_tip "$(git rev-parse HEAD)"
as_student
git switch -q "${current:-main}"
echo "Dzień 2: Ania dodała commit na feature/new-menu. Teraz krok 4: prawdziwy merge feature/new-menu do main."
