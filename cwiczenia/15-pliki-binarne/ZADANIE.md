# 15. Konflikt w plikach binarnych (obrazki)

Poziom: **łatwy** · Operacja: **merge, checkout --ours/--theirs** · Teoria: [06](../../teoria/06-nietypowe-konflikty.md)

## Uruchomienie

```bash
./cwiczenia/15-pliki-binarne/setup.sh
cd cwiczenia/15-pliki-binarne/repo
bash ../check.sh
```

## Sytuacja

- `feature/rebranding` (Ola, dział graficzny): nowe niebieskie logo, nowy baner, nowy kolor marki w CSS.
- `main`: baner z nowym regulaminem promocji (wymóg działu prawnego, LEGAL-12) i poprawiona wysokość starego logo.

Ustalenia: **logo z rebrandingu**, **baner z main** (nowy baner graficy przygotują jeszcze raz, z nowym regulaminem). **Scal `feature/rebranding` do `main`.**

## Oczekiwane

- Merge do `main`.
- `assets/logo.png` = wersja z `feature/rebranding`, `assets/banner.png` = wersja z `main`.
- `theme.css` z nowym kolorem (git scali go sam).

## Wskazówki

- Git nie potrafi scalić plików binarnych: zgłosi `warning: Cannot merge binary files` i konflikt. W katalogu roboczym zostawi **Twoją** wersję (ours), bez żadnych znaczników. `git add .` od razu „rozwiąże” konflikt na korzyść `main`.
- Wybór całej wersji: `git checkout --theirs assets/logo.png` / `git checkout --ours assets/banner.png` (albo `git restore --theirs/--ours`). Potem `git add`.
- Podgląd wersji przed wyborem: `git show :2:assets/logo.png > /tmp/logo-ours.png`, `:3:` dla theirs, i otwórz w przeglądarce obrazków.
- Dla plików, które zawsze mają brać jedną stronę, można ustawić `.gitattributes` (np. `*.png binary`, własny driver `merge=ours`): teoria 06.

## Pytania dodatkowe

1. Skąd git wie, że plik jest binarny? (`*.png binary`, heurystyka bajtu zerowego)
2. Dlaczego duże pliki binarne w repozytorium to problem nie tylko przy konfliktach? Co daje Git LFS (i blokowanie plików, `git lfs lock`)?
3. Co zrobić z konfliktem w pliku `.docx` albo `.xlsx`? (to też ZIP-y: binarne dla gita)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
