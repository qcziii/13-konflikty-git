# 07. Strategie, opcje merge'a i rerere

Ćwiczenia: [05](../cwiczenia/05-baza-diff3/ZADANIE.md), [14](../cwiczenia/14-formatowanie-calego-pliku/ZADANIE.md), [17](../cwiczenia/17-rerere/ZADANIE.md)

## Strategia (`-s`) a opcja strategii (`-X`)

Łatwo pomylić, a różnica jest ogromna:

| Komenda | Co robi |
|---|---|
| `git merge -X ours feature` | normalny merge; **tylko w miejscach konfliktu** bierze naszą stronę. Niekolidujące zmiany z feature wchodzą |
| `git merge -X theirs feature` | jw., w konfliktach bierze stronę feature |
| `git merge -s ours feature` | **ignoruje całą treść** feature; zapisuje merge (dwóch rodziców), ale drzewo = nasze. Używane, żeby „oznaczyć gałąź jako scaloną” bez jej zmian |
| `-s theirs` | nie istnieje |

`-X ours/theirs` rozwiązuje konflikty **na ślepo**, bez czytania. Nadaje się do plików, w których z góry wiadomo, która strona wygrywa (np. generowane). W kodzie to prosta droga do zgubionej poprawki (ćwiczenie 18). W rebase znaczenie stron jest odwrócone (rozdział 04).

Domyślna strategia to `ort` (od git 2.34, wcześniej `recursive`): radzi sobie z wieloma bazami, zmianami nazw i katalogów. Inne (`octopus` dla wielu gałęzi naraz, `subtree`) przydają się rzadko.

## Przydatne opcje `-X`

```bash
git merge -X ignore-space-change feature     # ignoruj zmiany ilości białych znaków (patrz rozdział 06: uwaga na wynik)
git merge -X ignore-all-space feature
git merge -X find-renames=30% feature        # niższy próg wykrywania zmian nazw
git merge -X diff-algorithm=histogram feature   # inny algorytm dopasowania linii, czasem mniejsze konflikty
git merge -X patience feature                # jw. (patience)
```

`histogram` / `patience` lepiej dopasowują kod z wieloma podobnymi liniami (`}`, puste linie), przez co konflikty bywają mniejsze i bardziej sensowne. Można ustawić na stałe: `git config --global diff.algorithm histogram`.

## Ustawienia, które warto mieć

```bash
git config --global merge.conflictStyle zdiff3     # baza w znacznikach (rozdział 02)
git config --global rerere.enabled true            # zapamiętuj rozwiązania
git config --global diff.algorithm histogram
git config --global pull.rebase false              # albo true: świadomy wybór zamiast ostrzeżenia
git config --global push.autoSetupRemote true
git config --global mergetool.keepBackup false     # bez plików *.orig
git config --global alias.pushf "push --force-with-lease --force-if-includes"
```

## Rerere: reuse recorded resolution

Gdy `rerere.enabled` jest włączone:

1. Przy konflikcie git zapisuje jego „odcisk” (preimage: treść konfliktu bez kontekstu) w `.git/rr-cache/<hash>/`.
2. Gdy zacommitujesz rozwiązanie, zapisuje wynik (postimage): `Recorded resolution for 'plik'`.
3. Gdy **taki sam** konflikt pojawi się znowu (merge, rebase, cherry-pick), git sam wpisze zapamiętane rozwiązanie: `Resolved 'plik' using previous resolution`.

```bash
git rerere status          # pliki, dla których rerere coś nagrywa
git rerere diff            # co zrobiłoby/zrobiło
git rerere forget plik     # zapomnij (złe) rozwiązanie
git config rerere.autoUpdate true   # od razu oznaczaj jako rozwiązane (git add). Domyślnie nie
```

Kiedy się przydaje (ćwiczenie 17):

- **próbny merge**: scalasz długą gałąź do `main`, żeby sprawdzić, czy się skleja, rozwiązujesz konflikty, cofasz (`git reset --hard HEAD~1`). Przy prawdziwym merge'u tych samych konfliktów nie rozwiązujesz drugi raz,
- **wielokrotny rebase** długiej gałęzi: te same konflikty przy każdym rebase,
- **merge do gałęzi testowej**, potem rebase do PR-a.

Ostrożnie: rerere rozpoznaje konflikt po treści, nie po kontekście. Jeśli wokół zmieniło się coś istotnego, zapamiętane rozwiązanie może być już złe. Dlatego domyślnie rerere **nie** oznacza pliku jako rozwiązanego: przejrzyj i `git add` sam.

Rozwiązania z rerere są lokalne (`.git/rr-cache` nie jest wypychany). Są narzędzia do przenoszenia (`rerere-train.sh` w `contrib/` gita), ale w praktyce rerere to pomoc dla jednej osoby.

## Pytania sprawdzające

1. Czym się różni `git merge -X ours` od `git merge -s ours`?
2. Dlaczego `-X theirs` jest niebezpieczne w kodzie aplikacji?
3. Co dokładnie zapisuje rerere i kiedy?
4. Dlaczego rerere domyślnie nie robi `git add` za Ciebie?
5. Wymień dwie sytuacje, w których rerere oszczędza czas.
