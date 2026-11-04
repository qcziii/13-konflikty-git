# 03. „This branch has conflicts”: aktualizacja gałęzi pull requesta

Poziom: **łatwy/średni** · Operacja: **fetch + merge main do feature + push** · Teoria: [08](../../teoria/08-praca-w-zespole.md), [03](../../teoria/03-rozwiazywanie-krok-po-kroku.md)

## Uruchomienie

```bash
./cwiczenia/03-konflikt-w-pull-requescie/setup.sh
cd cwiczenia/03-konflikt-w-pull-requescie/repo
bash ../check.sh
```

Setup tworzy dwa repozytoria: `origin.git` udaje GitHuba (to jest `origin` Twojego klona), a `repo` to Twój lokalny klon.

## Sytuacja

Wypchnąłeś gałąź `feature/discount-codes` i otworzyłeś pull request. Zanim ktoś go przejrzał, do `main` na GitHubie trafił PR Piotra (limit 50 produktów w koszyku, liczenie sumy streamem). Teraz GitHub pokazuje przy Twoim PR: **„This branch has conflicts that must be resolved”**.

Zasady zespołu:

- na `main` nikt nie pushuje bezpośrednio, wszystko przez PR,
- gałęzi PR-a **nie przepisujemy** (bez rebase i force push), bo recenzenci mają już na niej komentarze i ktoś mógł ją pobrać. Konflikt rozwiązujemy, **scalając aktualny `main` do gałęzi PR-a**.

## Oczekiwane

- `origin/main` nietknięty.
- `origin/feature/discount-codes` zawiera aktualny `origin/main` (konflikt PR-a zniknął), stare commity PR-a są w historii, na czubku jest commit scalający.
- Kod na gałęzi PR-a ma obie funkcje: kody rabatowe (Twoje) i limit koszyka + sumę streamem (Piotra). W `application.properties` są oba nowe klucze.
- Lokalna gałąź = gałąź na origin.

## Wskazówki

- Twoje lokalne `main` i `origin/main` są **nieaktualne**: nie wiedzą o PR Piotra, dopóki nie zrobisz `git fetch`. Zobacz, co mówi `git merge main` przed fetchem, i dlaczego.
- Scalaj `origin/main` (albo najpierw zaktualizuj lokalne `main`).
- W `Cart.total()` nie wybieraj strony: weź implementację z `main` (stream) i dołóż do niej rabat.
- Na koniec `git push` (zwykły, bez `--force`: nie przepisujesz historii, tylko dokładasz commit).

## Pytania dodatkowe

1. Czym różni się `git fetch` od `git pull`? Co dokładnie aktualizuje `git fetch`?
2. GitHub ma przycisk „Resolve conflicts” w przeglądarce. Co on robi w gicie (jaki commit powstaje i na której gałęzi)? Kiedy nie zadziała?
3. Jakie są wady i zalety „merge main do feature” w porównaniu z „rebase feature na main” przy aktualizacji PR-a?
4. Po scaleniu PR-a do `main` (merge commit) historia `main` będzie miała dwa merge'e. Jak je zobaczyć? (`git log --graph --oneline`)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
