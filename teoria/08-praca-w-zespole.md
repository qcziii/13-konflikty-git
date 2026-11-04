# 08. Konflikty w pracy zespołowej i pull requestach

Ćwiczenia: [03](../cwiczenia/03-konflikt-w-pull-requescie/ZADANIE.md), [09](../cwiczenia/09-rebase-i-force-with-lease/ZADANIE.md), [19](../cwiczenia/19-projekt-dzien-integracji/ZADANIE.md)

## Lokalne gałęzie, gałęzie zdalne i fetch

```
origin (GitHub):  main ── X ── Y            (Y: PR kolegi, scalony godzinę temu)
Ty, lokalnie:     main ── X                  (stan z rana)
                  origin/main ── X           (też z rana! aktualizuje go dopiero fetch)
```

`origin/main` to **lokalna kopia** stanu serwera z ostatniego `git fetch` (albo `pull`). Nie zmienia się sama. Stąd klasyczny błąd z ćwiczenia 03: `git merge main` mówi „Already up to date”, a GitHub dalej pokazuje konflikt.

```bash
git fetch                       # pobiera, nic nie zmienia w Twoich gałęziach
git log --oneline main..origin/main    # co przyszło
git pull                        # fetch + merge (albo + rebase, jeśli pull.rebase=true)
```

## „This branch has conflicts that must be resolved”

GitHub (GitLab, Bitbucket) nie scali PR-a, jeśli merge gałęzi PR-a do docelowej dałby konflikt. Konflikt rozwiązuje się **na gałęzi PR-a**, nie na `main`:

**Wariant A: merge `main` do gałęzi PR-a** (bezpieczny zawsze):

```bash
git switch feature/x
git fetch
git merge origin/main           # rozwiąż konflikty, build, testy
git push                        # zwykły push: tylko dokładasz commit
```

**Wariant B: rebase gałęzi PR-a na `main`** (czysta historia, ale przepisuje gałąź):

```bash
git switch feature/x
git fetch
git rebase origin/main
git push --force-with-lease --force-if-includes
```

Wariant B zmienia SHA commitów: komentarze recenzentów przy konkretnych commitach mogą się „zgubić”, a każdy, kto pobrał gałąź, musi ją zresetować. Zespół powinien mieć **jedną zasadę** i ją zapisać (CONTRIBUTING.md).

Przycisk **„Resolve conflicts”** na GitHubie robi wariant A w przeglądarce (commit scalający `main` do gałęzi PR-a). Działa tylko dla prostych konfliktów tekstowych: nie dla binarnych, modify/delete czy rename, i nie skompiluje Ci kodu przed commitem.

## Sposoby scalania PR-a i ich wpływ na konflikty

| Przycisk na GitHubie | Co powstaje na `main` | Uwagi |
|---|---|---|
| Create a merge commit | merge (`--no-ff`) | historia gałęzi zachowana, `git revert -m 1` cofa cały PR |
| Squash and merge | jeden nowy commit z całą zmianą | dalsza praca na tej samej gałęzi = konflikty z własnym, zsquashowanym kodem; gałąź po squashu najlepiej usunąć |
| Rebase and merge | commity PR-a przepisane na `main` | nowe SHA, jak przy rebase |

## Cichy konflikt w CI

PR był zielony tydzień temu. Od tego czasu na `main` coś się zmieniło. Po scaleniu `main` się nie buduje, choć nikt nie miał konfliktu (ćwiczenie 06). Zabezpieczenia:

- branch protection: **„Require branches to be up to date before merging”** (CI musi przejść na gałęzi zawierającej aktualny `main`),
- **merge queue** (GitHub, GitLab merge trains): CI testuje wynik merge'a przed jego wykonaniem, po kolei,
- build i testy lokalnie po każdym merge'u `main` do gałęzi.

## Jak mieć mniej konfliktów

- **Małe PR-y, scalane szybko.** Konflikty rosną z czasem życia gałęzi szybciej niż liniowo.
- **Często synchronizuj** długą gałąź z `main` (codziennie), małe konflikty zamiast jednego wielkiego.
- **Refaktoryzacje, zmiany nazw i formatowanie w osobnych PR-ach**, ogłoszone zespołowi i scalane szybko. Nie mieszaj ich z funkcjonalnymi zmianami.
- **Jedna rzecz na linię** w listach, konfiguracji, importach; sortowanie; przecinek po ostatnim elemencie tam, gdzie język pozwala.
- **Wspólny formatter** w repo (i w CI), `.editorconfig`, `.gitattributes` z `eol=lf`.
- **Feature flagi** zamiast miesięcznych gałęzi: kod wchodzi do `main` od razu, wyłączony.
- **Rozmowa**: „będę teraz przerabiać `OrderService`, macie tam coś otwartego?”.

## Kto rozwiązuje konflikt

Zasada: **autor zmiany, która przyszła później**, bo zna jej intencję. Konflikt w kodzie, którego nie rozumiesz, rozwiązujesz z jego autorem (`git log --merge`, `git blame` pokażą, kto to). Integrator (ćwiczenie 19) może scalać proste rzeczy, ale przy decyzjach biznesowych pyta.

## Pytania sprawdzające

1. Dlaczego `git merge main` może powiedzieć „Already up to date”, choć PR na GitHubie ma konflikt?
2. Jakie są dwa sposoby rozwiązania konfliktu PR-a? Który przepisuje historię?
3. Co robi przycisk „Resolve conflicts” na GitHubie i kiedy nie zadziała?
4. Dlaczego dalsza praca na gałęzi po „Squash and merge” prowadzi do konfliktów?
5. Wymień trzy praktyki zespołowe, które zmniejszają liczbę konfliktów.
