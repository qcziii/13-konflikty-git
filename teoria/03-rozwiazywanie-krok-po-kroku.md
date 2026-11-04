# 03. Rozwiązywanie konfliktu krok po kroku

Ćwiczenia: [01](../cwiczenia/01-pierwszy-konflikt/ZADANIE.md)-[06](../cwiczenia/06-cichy-konflikt/ZADANIE.md), w praktyce wszystkie

## Przed merge'em

1. **Czysty katalog roboczy.** `git status` bez zmian. Niezacommitowane zmiany zacommituj albo schowaj (`git stash`). Merge na brudnym katalogu utrudnia `--abort`, a wynik miesza się z Twoimi zmianami.
2. **Aktualne gałęzie.** `git fetch`, potem scalaj `origin/main` albo zaktualizuj lokalne `main` (`git switch main && git pull`). Lokalne `main` sprzed tygodnia to nie jest „aktualny main” (ćwiczenie 03).
3. **Wiedz, co scalasz.** `git log --oneline --graph main feature`, `git diff main...feature --stat`.

## Procedura

```bash
git merge feature/x                 # konflikt
git status                          # które pliki?
```

Dla każdego pliku z konfliktem:

1. Zobacz **trzy** wersje: zdiff3 albo `git show :1:/:2:/:3:plik`.
2. Ustal **intencję** każdej strony względem bazy. Jeśli nie wiesz, dlaczego ktoś coś zmienił: `git log --merge -p -- plik`, opisy commitów, zgłoszenie, zapytaj autora. **Nie zgaduj.**
3. Napisz wynik, który realizuje obie intencje. Usuń znaczniki.
4. `git add plik`.

Na koniec, **zanim zacommitujesz**:

```bash
git diff --cached                    # co wejdzie do commita scalającego
git diff --check                     # zostawione znaczniki i białe znaki na końcu linii
grep -rnE '^(<<<<<<<|=======|>>>>>>>)' src   # na wszelki wypadek
mvn -q verify / ./gradlew build / npm test    # build i testy: obowiązkowo (cichy konflikt!)
git commit                            # albo git merge --continue
```

Edytor otworzy się z gotowym opisem `Merge branch 'feature/x'`. Jeśli konflikt wymagał decyzji (np. „wygrywa SEC-311”), dopisz to w treści commita. Ktoś za rok podziękuje.

## Wycofanie się i zaczęcie od nowa

| Sytuacja | Komenda |
|---|---|
| Pogubiłem się w merge'u, chcę stan sprzed merge'a | `git merge --abort` |
| Zepsułem rozwiązanie **jednego** pliku, chcę znowu znaczniki | `git restore --merge plik` (stara forma: `git checkout -m plik`) |
| To samo, ale ze stylem zdiff3 dla tego pliku | `git checkout --conflict=zdiff3 plik` |
| Merge już zacommitowany, niewypchnięty, jest zły | `git reset --hard HEAD~1` (albo `ORIG_HEAD`) |
| Merge wypchnięty i zły | **nie** przepisuj historii: popraw nowym commitem albo `git revert -m 1 <merge>` (rozdział 09) |
| Rebase: chcę wrócić | `git rebase --abort`; po zakończonym: `git reset --hard ORIG_HEAD` albo z `git reflog` |
| Cherry-pick: chcę wrócić | `git cherry-pick --abort` |

`git merge --abort` próbuje odtworzyć stan sprzed merge'a. Jeśli przed merge'em miałeś niezacommitowane zmiany, może nie dać rady ich odtworzyć. Kolejny powód, żeby zaczynać od czystego katalogu.

**Pułapka z ćwiczenia 04:** `git status` pokazuje tylko to, co różni się od `HEAD`. Plik „rozwiązany” w całości na korzyść HEAD (`--ours`) i dodany do indeksu jest niewidoczny w `git status`, choć zgubił całą zmianę z drugiej gałęzi. Gdy nie ufasz stanowi: `git merge --abort` i od nowa.

## Narzędzia

- **IntelliJ IDEA**: przy konflikcie okno *Merge Revisions*: trzy kolumny (Your / Result / Their), strzałki `>>`/`<<` przenoszą fragmenty, *Accept Yours/Theirs* dla całego pliku. Środkowa kolumna startuje od **bazy**, nie od Twojej wersji. Przycisk „magic wand” rozwiązuje proste, niekolidujące fragmenty.
- **VS Code**: nad konfliktem „Accept Current / Incoming / Both”, a od niedawna 3-way merge editor („Resolve in Merge Editor”).
- **`git mergetool`**: uruchamia skonfigurowane narzędzie (`git config --global merge.tool meld`, `vimdiff`, `kdiff3`, `vscode`...). Zostawia pliki `*.orig`: `git config --global mergetool.keepBackup false`.

Narzędzie nie zwalnia z myślenia. „Accept Both” w VS Code skleja obie strony jedna pod drugą: w enumie da dwa średniki, w `if` podwójny warunek.

## Komunikacja

Najlepsze rozwiązanie konfliktu bywa rozmową: „Piotr, zmieniłeś próg na 150, ja dostawę na 12, zostawiam oba, OK?”. Konflikt w cudzym kodzie, którego nie rozumiesz, rozwiązuje się z autorem, nie samemu.

## Pytania sprawdzające

1. Dlaczego merge zaczyna się na czystym katalogu roboczym?
2. Co sprawdza `git diff --check`?
3. Jak odtworzyć konflikt w jednym pliku, nie przerywając całego merge'a?
4. Merge jest zacommitowany, ale niewypchnięty i zły. Jak go cofnąć? A jeśli jest już na `origin/main`?
5. Co pokazuje środkowa kolumna w oknie merge'a w IntelliJ na starcie?
