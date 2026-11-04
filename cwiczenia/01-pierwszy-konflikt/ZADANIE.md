# 01. Pierwszy konflikt: dwie zmiany w sąsiednich liniach

Poziom: **łatwy** · Operacja: **merge** · Teoria: [01](../../teoria/01-jak-git-scala.md), [02](../../teoria/02-anatomia-konfliktu.md), [03](../../teoria/03-rozwiazywanie-krok-po-kroku.md)

## Uruchomienie

```bash
./cwiczenia/01-pierwszy-konflikt/setup.sh      # tworzy piaskownicę cwiczenia/01-pierwszy-konflikt/repo
cd cwiczenia/01-pierwszy-konflikt/repo
# ... praca ...
bash ../check.sh                               # sprawdzenie (można wiele razy)
```

## Sytuacja

W sklepie są dwie gałęzie:

- `main`: marketing obniżył próg darmowej dostawy z 200 zł na **150 zł** (promocja wiosenna).
- `feature/express-delivery`: Ania dodała dostawę ekspresową (**30 zł**, od progu połowa ceny) i przy okazji obniżyła zwykłą dostawę z 15 zł na **12 zł**.

Obie zmiany są uzgodnione z biznesem i mają trafić do `main`. Twoje zadanie: **scal `feature/express-delivery` do `main`**.

## Oczekiwane

- Jesteś na `main`, ostatni commit to commit scalający (merge) z dwoma rodzicami: poprzedni `main` i `feature/express-delivery`.
- Próg darmowej dostawy 150 zł, dostawa standardowa 12 zł, ekspres 30 zł (od progu 15 zł).
- Żadnych znaczników konfliktu, czysty `git status`.

## Wskazówki

- Zanim zaczniesz: `git log --oneline --graph --all`. Zobacz, skąd wychodzą gałęzie i co jest na każdej.
- `git merge feature/express-delivery` zatrzyma się na konflikcie. Przeczytaj, co wypisze: którego pliku dotyczy.
- `git status` w trakcie konfliktu podpowiada, co zrobić dalej. Czytaj go po każdym kroku.
- Między `<<<<<<< HEAD` a `=======` jest wersja z gałęzi, na której stoisz (`main`), między `=======` a `>>>>>>>` wersja z gałęzi, którą wciągasz.
- Pomyśl, **dlaczego** git nie scalił tego sam, choć każda gałąź zmieniła inną linię.
- Po rozwiązaniu: `git add <plik>`, potem `git commit` (albo `git merge --continue`). Edytor otworzy się z gotowym opisem merge'a: wystarczy zapisać i zamknąć.

## Pytania dodatkowe

1. Dlaczego zmiany w dwóch **różnych**, ale **sąsiednich** liniach dały konflikt? Czy zmiany oddalone o kilka linii też by go dały?
2. Co pokazuje `git diff` w trakcie konfliktu, a co `git diff HEAD`? Co znaczą dwie kolumny `+`/`-` na początku linii?
3. Jak wyświetlić wersję pliku z `main`, z feature i z bazy, nie ruszając pliku w katalogu roboczym? (podpowiedź: `git show :1:ścieżka`)
4. Co by się stało, gdybyś zrobił `git add` pliku ze znacznikami konfliktu i `git commit`? Czy git by Cię powstrzymał?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Chcesz od nowa? Uruchom `setup.sh` jeszcze raz.
