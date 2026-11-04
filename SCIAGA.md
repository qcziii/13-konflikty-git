# Ściąga: konflikty w gicie

## Ustaw raz

```bash
git config --global merge.conflictStyle zdiff3
git config --global rerere.enabled true
git config --global diff.algorithm histogram
git config --global mergetool.keepBackup false
git config --global alias.pushf "push --force-with-lease --force-if-includes"
git config --global alias.lg "log --oneline --graph --all"
```

## Przed

```bash
git status                         # czysto? jak nie: commit albo git stash
git fetch                          # origin/* aktualne
git lg                             # obraz gałęzi
git diff main...feature --stat     # co zmieniła feature od bazy
git merge-base main feature        # baza
```

## W trakcie (merge, rebase, cherry-pick, stash pop, revert)

```bash
git status                         # co jest nierozwiązane, jaka operacja trwa
git diff                           # konflikty (combined diff)
git show :1:plik  :2:plik  :3:plik # baza / ours / theirs
git log --merge -p -- plik         # commity z obu stron dotykające pliku
git checkout --ours|--theirs plik  # cały plik z jednej strony (binarne, generowane)
git restore --merge plik           # odtwórz konflikt w pliku (zepsułem rozwiązanie)
git checkout --conflict=zdiff3 plik
git add plik / git rm plik         # oznacz jako rozwiązany
git diff --check                   # zostawione znaczniki
# BUILD I TESTY
```

## Ours / theirs

| Operacja | ours (`HEAD`, górna część) | theirs (dolna część) |
|---|---|---|
| `merge X` | gałąź, na której stoisz | `X` |
| `rebase main` | **`main`** (+ już nałożone) | **Twój commit** |
| `cherry-pick C` | gałąź, na której stoisz | `C` |
| `stash pop` | `HEAD` (Updated upstream) | stash (Stashed changes) |

## Dokończ albo przerwij

| | dokończ | pomiń commit | przerwij |
|---|---|---|---|
| merge | `git commit` / `git merge --continue` | | `git merge --abort` |
| rebase | `git rebase --continue` | `git rebase --skip` | `git rebase --abort` |
| cherry-pick | `git cherry-pick --continue` | `--skip` | `--abort` |
| revert | `git revert --continue` | `--skip` | `--abort` |
| stash pop | rozwiąż, `git restore --staged plik`, `git stash drop` | | `git reset --merge` (stash zostaje) |

## Rodzaje konfliktów

| Komunikat / status | Co zrobić |
|---|---|
| `CONFLICT (content)`, `UU` | czytaj bazę, połącz intencje obu stron |
| `CONFLICT (modify/delete)`, `DU`/`UD` | zwykle `git rm` **i** przenieś zmianę w nowe miejsce |
| `CONFLICT (rename/rename)`, `DD` + `AU`/`UA` | wybierz jedną nazwę, `git rm` drugiej, popraw odwołania |
| `Cannot merge binary files` | `--ours`/`--theirs` (w katalogu jest ours!) |
| konflikt w `*.lock` / `package-lock.json` | rozwiąż źródło, **wygeneruj** lock, dodaj oba |
| cały plik w konflikcie (formatowanie, CRLF) | formatter na swojej gałęzi przed merge'em; `-X ignore-space-change` i sprawdź wynik |
| brak konfliktu, build czerwony | cichy konflikt: popraw w merge'u (`--no-commit` / `commit --amend`) |

## Po

```bash
git show --remerge-diff HEAD       # jak rozwiązałem konflikty
git log --first-parent --oneline   # główna linia
git push                           # po merge'u: zwykły
git pushf                          # po rebase wypchniętej gałęzi; najpierw git pull --rebase na tej gałęzi!
```

## Coś zniknęło

```bash
git reflog                         # gdzie był HEAD; commity po reset/rebase dalej tu są
git reset --hard ORIG_HEAD         # cofnij ostatni merge/rebase (niewypchnięte)
git log -m --first-parent -S'tekst' --oneline     # gdzie tekst zniknął (także w merge'ach)
git log --full-history -S'tekst' -- plik
git bisect start HEAD <dobry>; git bisect run ./test.sh; git bisect reset
git revert -m 1 <merge>            # cofnij cały scalony PR w opublikowanej historii
git cherry-pick -x <sha>           # przenieś pojedynczą poprawkę
```

## Zasady

1. Baza, ours, theirs: **trzy** wersje, nie dwie.
2. Nie wybieraj strony. Połącz intencje. Jak nie wiesz, czyja intencja: zapytaj.
3. Po każdym rozwiązaniu: build i testy, zanim commit.
4. Nie przepisuj opublikowanej historii. Naprawiaj nowym commitem.
5. Małe PR-y, częsta synchronizacja, refaktoryzacje i formatowanie osobno.
