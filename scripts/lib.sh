#!/usr/bin/env bash
# Shared helpers for setup.sh and check.sh scripts of the exercises.
# Requires bash, git 2.36+ and a JDK 21+ (javac, java). On Windows: Git Bash.
#
# Every exercise works in its own sandbox: a separate git repository in
# cwiczenia/NN-.../repo (and sometimes a fake remote in cwiczenia/NN-.../origin.git).
# Both directories are ignored by the course repository.

# ---------------------------------------------------------------- common

EX_DIR=${EX_DIR:-$(cd "$(dirname "$0")" && pwd)}
REPO="$EX_DIR/repo"
ORIGIN="$EX_DIR/origin.git"
EX_NAME=$(basename "$EX_DIR")

die() { echo "BŁĄD: $*" >&2; exit 1; }

require_tools() {
  command -v git > /dev/null || die "brak gita w PATH"
  local v major minor
  v=$(git --version | sed -E 's/^git version ([0-9]+)\.([0-9]+).*/\1 \2/')
  major=${v% *}; minor=${v#* }
  if [ "$major" -lt 2 ] || { [ "$major" -eq 2 ] && [ "$minor" -lt 36 ]; }; then
    die "potrzebny git 2.36 lub nowszy (masz: $(git --version))"
  fi
}

# Hidden key=value state of the sandbox (expected hashes etc.), kept inside .git
# so it does not show up in `git status` or `git log --all`.
state_file() { echo "$REPO/.git/kurs-state"; }
state_set() { echo "$1=$2" >> "$(state_file)"; }
state_get() { grep -E "^$1=" "$(state_file)" 2>/dev/null | tail -1 | cut -d= -f2-; }

# ---------------------------------------------------------------- setup helpers

# Fixed dates and identities make every setup produce exactly the same commits
# (the same hashes) on every machine.
T=1767250800   # 2026-01-01 08:00 +0100
tick() {
  T=$((T + 3600))
  export GIT_AUTHOR_DATE="@$T +0100" GIT_COMMITTER_DATE="@$T +0100"
}
as() {   # as "Name Surname" login
  export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2@example.com"
  export GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2@example.com"
}
as_student() { unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL; }

# Local config of a sandbox: independent of the student's global config where it matters.
configure_sandbox() {
  git config user.name "Kursant"
  git config user.email "kursant@example.com"
  git config core.autocrlf false
  git config core.safecrlf false
  git config commit.gpgsign false
  git config advice.detachedHead false
  git config merge.renames true
  git config pull.rebase false
}

# new_sandbox: removes the old sandbox and creates an empty repository on branch main.
new_sandbox() {
  require_tools
  rm -rf "$REPO" "$ORIGIN" "$EX_DIR/.check" "$EX_DIR/.tmp-colleague"
  git init -q -b main "$REPO" || die "git init nie zadziałał"
  cd "$REPO" || die "brak $REPO"
  configure_sandbox
  as "Ania Nowak" anowak
  tick
}

# write <path>: file content from stdin (creates directories).
write() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

# commit "message": commits everything with the next fixed timestamp.
commit() { git add -A && tick && git commit -q -m "$1" || die "commit nie zadziałał: $1"; }

# merge_no_ff <branch> "message": a clean merge done during setup.
merge_no_ff() { tick; git merge -q --no-ff --no-edit -m "$2" "$1" > /dev/null || die "merge $1 w setupie"; }

# Turns the current sandbox into a clone of a bare remote origin.git.
# After this call: $ORIGIN is the remote, $REPO is a fresh clone of it.
publish_to_origin() {
  local branches=("$@")
  local saved_state; saved_state=$(cat "$(state_file)" 2> /dev/null)
  git clone -q --bare "$REPO" "$ORIGIN" || die "clone --bare"
  cd "$EX_DIR" && rm -rf "$REPO"
  git clone -q "$ORIGIN" "$REPO" 2> /dev/null || die "clone"
  cd "$REPO" || die "brak $REPO"
  [ -n "$saved_state" ] && printf '%s\n' "$saved_state" > "$(state_file)"
  configure_sandbox
  local b
  for b in "${branches[@]}"; do
    git show-ref -q --verify "refs/heads/$b" || git branch -q --track "$b" "origin/$b"
  done
}

# Runs commands as a colleague in a temporary clone of origin and pushes.
# colleague "Name" login <<'EOF' ... commands ... EOF
colleague() {
  local name=$1 login=$2 script
  script=$(cat)
  rm -rf "$EX_DIR/.tmp-colleague"
  git clone -q "$ORIGIN" "$EX_DIR/.tmp-colleague" 2> /dev/null || die "clone kolegi"
  (
    cd "$EX_DIR/.tmp-colleague" || exit 1
    configure_sandbox
    as "$name" "$login"
    eval "$script"
  ) || die "skrypt kolegi"
  rm -rf "$EX_DIR/.tmp-colleague"
}

setup_done() {
  as_student
  unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE
  echo
  echo "Gotowe. Piaskownica: cwiczenia/$EX_NAME/repo"
  echo "Dalej:  cd cwiczenia/$EX_NAME/repo   (i postępuj według ZADANIE.md)"
  echo "Potem:  ./cwiczenia/$EX_NAME/check.sh   (z katalogu głównego kursu, albo bash ../check.sh z repo)"
  echo "Od nowa: uruchom setup.sh jeszcze raz (kasuje piaskownicę)."
}

# ---------------------------------------------------------------- check helpers

PASS=0
FAIL=0
ok()  { echo "  [OK]   $1"; PASS=$((PASS+1)); }
bad() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); [ -n "$2" ] && printf '%s\n' "$2" | sed 's/^/           /'; return 0; }
info() { echo "         $1"; }

# check <description> <command...>: OK when the command succeeds.
check() { local d=$1; shift; if "$@" > /dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }

# Stops the check when there is no sandbox.
need_sandbox() {
  if [ ! -d "$REPO/.git" ]; then
    echo "Brak piaskownicy cwiczenia/$EX_NAME/repo. Uruchom najpierw ./cwiczenia/$EX_NAME/setup.sh"
    exit 1
  fi
  cd "$REPO" || exit 1
}

sha() { git rev-parse -q --verify "$1^{commit}" 2> /dev/null; }
short() { git rev-parse --short "$1" 2> /dev/null; }
git_dir() { git rev-parse --git-dir; }

# No merge/rebase/cherry-pick/revert in progress.
check_no_operation() {
  local gd; gd=$(git_dir)
  local what=""
  [ -f "$gd/MERGE_HEAD" ] && what="merge (git merge --continue albo git commit, ewentualnie git merge --abort)"
  [ -d "$gd/rebase-merge" ] || [ -d "$gd/rebase-apply" ] && what="rebase (git rebase --continue albo --abort)"
  [ -f "$gd/CHERRY_PICK_HEAD" ] && what="cherry-pick (git cherry-pick --continue albo --abort)"
  [ -f "$gd/REVERT_HEAD" ] && what="revert (git revert --continue albo --abort)"
  if [ -n "$what" ]; then bad "nie trwa żadna niedokończona operacja" "trwa: $what"
  else ok "nie trwa żadna niedokończona operacja (merge, rebase, cherry-pick)"; fi
}

check_no_unmerged() {
  local u; u=$(git ls-files -u | awk '{print $4}' | sort -u)
  if [ -n "$u" ]; then bad "brak nierozwiązanych plików w indeksie" "$u"
  else ok "brak nierozwiązanych plików (git ls-files -u jest puste)"; fi
}

# Working tree and index clean, also no leftovers like *.orig from mergetool.
check_clean_tree() {
  local s; s=$(git status --porcelain --untracked-files=all)
  if [ -n "$s" ]; then
    local hint=""
    printf '%s\n' "$s" | grep -q '\.orig$' && hint=$'\n(pliki *.orig zostawia git mergetool: usuń je, na przyszłość: git config --global mergetool.keepBackup false)'
    bad "katalog roboczy czysty (git status nic nie pokazuje)" "$(printf '%s\n' "$s" | head -8)$hint"
  else ok "katalog roboczy czysty (git status nic nie pokazuje)"; fi
}

check_on_branch() {
  local b; b=$(git symbolic-ref -q --short HEAD)
  if [ "$b" = "$1" ]; then ok "jesteś na gałęzi $1"
  else bad "jesteś na gałęzi $1" "aktualnie: ${b:-odłączony HEAD (detached)}"; fi
}

MARKERS='^(<{7,}( |$)|>{7,}( |$)|={7,}$|\|{7,}( |$))'

# check_no_markers <rev> [<rev>...]: no conflict markers in committed files.
check_no_markers() {
  local rev hits all=""
  for rev in "$@"; do
    hits=$(git grep -nE "$MARKERS" "$rev" -- 2> /dev/null | head -5)
    [ -n "$hits" ] && all+="$hits"$'\n'
  done
  if [ -n "$all" ]; then bad "w zacommitowanych plikach nie ma znaczników konfliktu" "$(printf '%s' "$all" | sed "s/^[0-9a-f]\{40\}://" | head -8)"
  else ok "w zacommitowanych plikach nie ma znaczników konfliktu (<<<<<<< ======= >>>>>>>)"; fi
}

check_no_markers_worktree() {
  local hits; hits=$(grep -rnE "$MARKERS" --exclude-dir=.git . 2> /dev/null | head -5)
  if [ -n "$hits" ]; then bad "w plikach nie ma znaczników konfliktu" "$hits"
  else ok "w plikach nie ma znaczników konfliktu"; fi
}

parents() { git rev-list --parents -n 1 "$1" | cut -d' ' -f2-; }
nparents() { set -- $(parents "$1"); echo $#; }
is_ancestor() { git merge-base --is-ancestor "$1" "$2" 2> /dev/null; }

# check_merge_commit <rev> <expected first parent> <expected second parent> <description>
check_merge_commit() {
  local rev=$1 p1=$2 p2=$3 desc=$4 ps
  ps=$(parents "$rev")
  if [ "$(nparents "$rev")" -ne 2 ]; then
    bad "$desc" "$(short "$rev") nie jest commitem scalającym (ma rodziców: $(nparents "$rev"))"
  elif [ "$ps" != "$p1 $p2" ]; then
    bad "$desc" "rodzice: $(for p in $ps; do short "$p"; done | tr '\n' ' '); oczekiwani: $(short "$p1") (pierwszy) i $(short "$p2") (drugi)"
  else
    ok "$desc"
  fi
}

# check_file_absent <rev> <path> <description>
check_file_absent() {
  if git cat-file -e "$1:$2" 2> /dev/null; then bad "$3" "plik $2 dalej jest w $(short "$1")"; else ok "$3"; fi
}

# blob_of <rev> <path>
blob_of() { git rev-parse -q --verify "$1:$2" 2> /dev/null; }

# ---------------------------------------------------------------- Java checks

# java_check <source> <Check.java>
# <source>: a revision (commit) to export, or "WORKTREE" for the working tree.
# Copies the files to a temporary directory, compiles src/**/*.java together with
# Check.java and runs it there. Check (with the helper scripts/T.java) prints lines "OK|name" or "FAIL|name|message".
java_check() {
  local src=$1 checker=$2 label=${3:-}
  local tmp="$EX_DIR/.check"
  rm -rf "$tmp"; mkdir -p "$tmp/tree" "$tmp/out"
  if [ "$src" = "WORKTREE" ]; then
    (cd "$REPO" && tar --exclude=./.git -cf - .) | tar -xf - -C "$tmp/tree"
  else
    git -C "$REPO" archive "$src" | tar -xf - -C "$tmp/tree" || { bad "eksport $src"; return; }
  fi
  cp "$checker" "$tmp/tree/Check.java"
  cp "$EX_DIR/../../scripts/T.java" "$tmp/tree/T.java"
  local files
  files=$(cd "$tmp/tree" && find src -name '*.java' 2> /dev/null | sort)
  if ! command -v javac > /dev/null; then bad "kompilacja (brak javac w PATH, potrzebny JDK 21+)"; return; fi
  if ! (cd "$tmp/tree" && javac -J-Dstdout.encoding=UTF-8 -J-Dstderr.encoding=UTF-8 -encoding UTF-8 -nowarn -d ../out $files Check.java T.java > ../javac.log 2>&1); then
    bad "kod ${label:+($label) }razem z testami się kompiluje" "$(grep -E 'error:|błąd:' -A2 "$tmp/javac.log" | sed -e 's#\\#/#g' | head -14)"
    return
  fi
  ok "kod ${label:+($label) }razem z testami się kompiluje"
  local st name msg
  while IFS='|' read -r st name msg; do
    case "$st" in
      OK) ok "$name" ;;
      FAIL) bad "$name" "$msg" ;;
      Picked*|NOTE:*) ;;
      *) [ -n "$st$name" ] && bad "test: $st$name" "$msg" ;;
    esac
  done < <(cd "$tmp/tree" && java -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-8 -cp ../out Check 2>&1 | tr -d '\r')
}

# compiles <rev>: true when src/**/*.java of a commit compiles (no tests).
compiles() {
  local tmp="$EX_DIR/.check/c-$1"
  rm -rf "$tmp"; mkdir -p "$tmp/tree" "$tmp/out"
  git -C "$REPO" archive "$1" | tar -xf - -C "$tmp/tree" || return 1
  local files; files=$(cd "$tmp/tree" && find src -name '*.java' | sort)
  (cd "$tmp/tree" && javac -encoding UTF-8 -nowarn -d ../out $files > /dev/null 2>&1)
}

summary() {
  rm -rf "$EX_DIR/.check"
  echo
  echo "Wynik: $PASS OK, $FAIL FAIL"
  if [ "$FAIL" -eq 0 ] && [ "$PASS" -gt 0 ]; then
    echo "WYNIK: wszystkie sprawdzenia przeszły"
  else
    echo "WYNIK: są błędy"
    exit 1
  fi
}
