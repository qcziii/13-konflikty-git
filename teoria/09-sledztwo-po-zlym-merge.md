# 09. Śledztwo: co zginęło w merge'u i jak to naprawić

Ćwiczenia: [18](../cwiczenia/18-zgubiona-poprawka/ZADANIE.md), [19](../cwiczenia/19-projekt-dzien-integracji/ZADANIE.md)

Źle rozwiązany konflikt nie daje błędu. Daje commit scalający, w którym brakuje czyjejś zmiany. Wychodzi po tygodniach, jako „ten błąd wrócił”.

## Szukanie po treści: `git log -S` i `-G`

```bash
git log -S'discount out of range' --oneline              # commity, w których liczba wystąpień tekstu się zmieniła (dodanie/usunięcie)
git log -G'percent\s*>\s*50' --oneline                     # commity, w których zmieniła się linia pasująca do regexa
git log -S'...' -p                                        # od razu z diffem
```

**Pułapka z merge'ami:**

- `git log` domyślnie **nie pokazuje diffów merge'y**, więc `-S` nie znajdzie merge'a, w którym tekst zniknął. Dodaj `-m` (diff względem każdego rodzica) albo `--first-parent -m` (względem pierwszego): `git log -m --first-parent -S'...' --oneline`.
- Z podaną ścieżką (`git log -S'...' -- Cart.java`) działa **upraszczanie historii**: jeśli wynik merge'a jest identyczny z jednym z rodziców, git idzie tylko tą stroną. Gdy konflikt rozwiązano, biorąc w całości wersję z feature, git w ogóle nie zajrzy na stronę `main` i **nie pokaże commita z poprawką**. Pomaga `--full-history`.

## Co zrobiono z konfliktem: `git show --remerge-diff`

Zwykły `git show <merge>` pokazuje tzw. combined diff: tylko fragmenty, które różnią się od **obu** rodziców. Jeśli konflikt rozwiązano, biorąc jedną stronę, nic nie zobaczysz.

```bash
git log --merges --oneline
git show --remerge-diff <merge>      # git 2.36+
```

`--remerge-diff` od nowa wykonuje merge (z konfliktami) i pokazuje różnicę między tym automatycznym wynikiem a tym, co zostało zacommitowane. Widać dokładnie, które linie z której strony zostały usunięte przy rozwiązywaniu:

```diff
     public void applyDiscount(int percent) {
-<<<<<<< 3c1d9e0 (Update docs)
-        if (percent < 0 || percent > 50) {
-            throw new IllegalArgumentException("discount out of range: " + percent);
-        }
-        this.discount = percent;
-=======
         this.discount = percent;
         this.discountAppliedAt = Instant.now();
->>>>>>> 8b72f4a (Remember when the discount was applied)
     }
```

To najlepsze narzędzie do **przeglądu merge'y** (także cudzych: „pokaż, jak rozwiązałeś konflikt”). Działa też w `git log --remerge-diff`.

## Kiedy się zepsuło: `git bisect`

Gdy wiesz, że kiedyś działało, a teraz nie:

```bash
git bisect start
git bisect bad                    # HEAD jest zły
git bisect good <sha>             # ten commit był dobry
# git przełącza na commit w połowie; testujesz i mówisz:
git bisect good    # albo    git bisect bad
# ... aż git wypisze "<sha> is the first bad commit"
git bisect reset                  # powrót na gałąź
```

Automatycznie, jeśli masz skrypt testowy (kod wyjścia 0 = dobry, 1-127 = zły, 125 = „nie da się sprawdzić, pomiń”):

```bash
git bisect start HEAD <dobry-sha>
git bisect run ./test.sh
git bisect reset
```

Bisect wskaże pierwszy zły commit, także commit scalający. Dlatego każdy commit na `main` (zwłaszcza merge) powinien się budować (ćwiczenie 06): merge, który się nie kompiluje, psuje bisect.

## Naprawa w opublikowanej historii

`main` jest wypchnięty, inni na nim pracują: **nie przepisuj historii** (bez `reset`, `rebase`, `commit --amend` starych commitów, `push --force`). Naprawiasz **nowym commitem**:

| Sposób | Kiedy |
|---|---|
| `git cherry-pick -x <commit-z-poprawką>` | poprawka da się nałożyć (może dać konflikt i wciągnąć rzeczy, które już są, np. test) |
| ręczne odtworzenie zmiany | kod się od tamtej pory zmienił (najczęstsze) |
| `git revert -m 1 <merge>` | trzeba wycofać **całą** gałąź (np. zepsuła produkcję). Uwaga: ponowne scalenie wymaga revertu revertu (rozdział 05) |

W opisie naprawy zostaw ślad dla następnej osoby:

```
Restore discount range validation lost in merge 5d0e7a2

The fix from 2f9c41b (BUG-88) was dropped when the conflict in Order.java
was resolved by taking the feature/discount-timestamp version.

Refs: BUG-88
```

## Ratunek, gdy coś zniknęło lokalnie: reflog

`git reflog` to dziennik, gdzie wskazywał `HEAD` (i każda gałąź: `git reflog show feature/x`). Commity po `reset --hard`, nieudanym rebase czy usuniętej gałęzi dalej tam są (domyślnie 90 dni):

```bash
git reflog
git reset --hard HEAD@{3}            # albo: git branch ratunek <sha>
```

## Pytania sprawdzające

1. Dlaczego `git log -S'tekst' -- plik` może nie pokazać commita, który dodał tekst?
2. Co pokazuje `git show --remerge-diff <merge>`, czego nie pokazuje zwykły `git show <merge>`?
3. Jaki kod wyjścia powinien zwracać skrypt dla `git bisect run`, gdy commit się nie kompiluje?
4. Poprawka zginęła w merge'u na `main`, który jest opublikowany. Jak ją przywrócić? Czego nie robić?
5. Do czego służy `git reflog`?
