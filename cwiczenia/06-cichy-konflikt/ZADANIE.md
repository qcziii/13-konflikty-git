# 06. Cichy konflikt: merge bez konfliktu, a projekt się nie kompiluje

Poziom: **średni** · Operacja: **merge --no-commit / commit --amend** · Teoria: [01](../../teoria/01-jak-git-scala.md), [03](../../teoria/03-rozwiazywanie-krok-po-kroku.md)

## Uruchomienie

```bash
./cwiczenia/06-cichy-konflikt/setup.sh
cd cwiczenia/06-cichy-konflikt/repo
bash ../check.sh
```

## Sytuacja

- Na `main` Piotr zmienił nazwę `PriceCalculator.calculate()` na `totalFor()` (i dolicza teraz opłatę za płatność) oraz dodał klasę `PaymentFees` ze `switch` po wszystkich metodach płatności.
- Na `feature/gift-cards` Ania dodała płatność kartą podarunkową (`GIFT_CARD`) i fakturę (`InvoiceService`), która woła `PriceCalculator.calculate()`.

**Scal `feature/gift-cards` do `main`.** Opłata za kartę podarunkową wynosi 0 zł.

## Oczekiwane

- Na `main` jest merge `feature/gift-cards` i **ten sam commit scalający** się kompiluje (bez osobnego commita „fix build” po nim).
- `PaymentFees.fee(GIFT_CARD) == 0`, faktura liczy sumę metodą `totalFor` (z opłatą).
- Stara metoda `calculate()` nie wraca: main usunął ją celowo.

## Wskazówki

- Git scali to bez żadnego konfliktu. Konflikt tekstowy to nie jedyny rodzaj konfliktu: git porównuje linie, nie rozumie kodu.
- Po każdym merge'u: kompilacja i testy. Tu: `bash build.sh`.
- Jak poprawić, żeby poprawki były w samym merge'u? Dwie drogi:
  - `git merge --no-commit feature/gift-cards`, popraw, `git add`, `git commit`,
  - albo zwykły merge, potem popraw i `git commit --amend` (zmienia ostatni commit; wolno, bo merge nie jest jeszcze nigdzie wypchnięty).
- Zmiana w merge'u, której nie ma w żadnym z rodziców, to tzw. „evil merge”. Tu jest konieczna i w porządku, ale opisz ją w treści commita.

## Pytania dodatkowe

1. Dlaczego commit scalający, który się nie kompiluje, to problem nawet wtedy, gdy następny commit wszystko naprawia? (podpowiedź: `git bisect`, `git checkout <sha>`, `git revert -m`)
2. Jakie inne zmiany mogą dać „cichy konflikt”? Wymień trzy (np. zmiana kontraktu metody, nowa wartość enuma, zmiana w konfiguracji).
3. Jak CI chroni przed takim błędem, jeśli PR był zielony przed zmianą na `main`? (GitHub: „Require branches to be up to date before merging”, merge queue)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
