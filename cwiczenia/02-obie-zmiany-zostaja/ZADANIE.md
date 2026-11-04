# 02. Obie zmiany zostają: dwie nowe metody płatności w tym samym miejscu

Poziom: **łatwy** · Operacja: **merge** · Teoria: [02](../../teoria/02-anatomia-konfliktu.md), [03](../../teoria/03-rozwiazywanie-krok-po-kroku.md)

## Uruchomienie

```bash
./cwiczenia/02-obie-zmiany-zostaja/setup.sh
cd cwiczenia/02-obie-zmiany-zostaja/repo
bash ../check.sh
```

## Sytuacja

- Na `main` Piotr dodał płatność **BLIK** (opłata 0,50 zł).
- Na `feature/paypal` Ania dodała płatność **PayPal** (opłata 2,50 zł).

Oboje dopisali swoje rzeczy na końcu tych samych list: w enumie `PaymentMethod`, w `switch` i w `messages.properties`. **Scal `feature/paypal` do `main`.**

## Oczekiwane

- Merge na `main` (rodzice: poprzedni `main` i `feature/paypal`).
- Metody płatności w kolejności `CASH, CARD, BLIK, PAYPAL`, każda z właściwą opłatą.
- `messages.properties` ma klucze wszystkich czterech metod, każdy raz.

## Wskazówki

- To najczęstszy konflikt w praktyce: dwie osoby dopisują coś „na końcu listy”. Rozwiązanie prawie nigdy nie brzmi „moje albo twoje”, tylko „obie, w ustalonej kolejności”.
- Uważaj na składnię: po złożeniu obu stron enum musi mieć przecinki i jeden średnik na końcu listy stałych.
- Zanim zacommitujesz, skompiluj: `javac -d /tmp/out $(find src -name '*.java')` (w Git Bash na Windows też działa). Konflikt rozwiązany „na oko” często się nie kompiluje.
- Sprawdź, czy nie zostały znaczniki: `git diff --check` albo `grep -rn '<<<<<<<\|>>>>>>>' .`

## Pytania dodatkowe

1. Dlaczego `git checkout --ours .` albo `--theirs .` byłoby tu złym rozwiązaniem? Co konkretnie by zginęło?
2. Jak zespół może z góry zmniejszyć liczbę takich konfliktów? (podpowiedź: sortowanie alfabetyczne, przecinek po ostatnim elemencie, jedna rzecz na linię)
3. Do czego służy atrybut `merge=union` w `.gitattributes` i dlaczego nie nadaje się do pliku `PaymentMethod.java`?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
