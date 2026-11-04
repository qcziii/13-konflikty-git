# 04. Wczorajszy merge: przerwij i zacznij od nowa

Poziom: **łatwy/średni** · Operacja: **merge --abort, restore --merge** · Teoria: [03](../../teoria/03-rozwiazywanie-krok-po-kroku.md)

## Uruchomienie

```bash
./cwiczenia/04-przerwij-i-zacznij-od-nowa/setup.sh
cd cwiczenia/04-przerwij-i-zacznij-od-nowa/repo
bash ../check.sh
```

## Sytuacja

Wczoraj wieczorem zacząłeś scalać `feature/categories` (kategorie produktów) do `main` (na którym Piotr dodał SKU). Coś poklikałeś w IDE, coś dodałeś do indeksu, coś poprawiłeś ręcznie, i zostawiłeś. Dziś nie pamiętasz, co już jest dobrze, a co nie. `git status` mówi, że został jeden nierozwiązany plik. Kusi, żeby go poprawić i zacommitować.

**Nie ufaj temu, co zostało.** Doprowadź merge do końca tak, żeby obie zmiany były na `main`.

## Oczekiwane

- Merge `feature/categories` do `main` (rodzice: `main` sprzed merge'a i `feature/categories`).
- `Product` ma pola w kolejności `sku, name, price, category`.
- `Catalog` ma i `findBySku` (z main), i `byCategory` (z feature).

## Wskazówki

- `git status` pokazuje tylko to, co **różni się** od HEAD. Jeśli w trakcie merge'a ktoś rozwiązał plik, wybierając w całości wersję z HEAD, i dodał go do indeksu, `git status` nic o nim nie powie. Sprawdź `git diff HEAD MERGE_HEAD --stat`: które pliki feature w ogóle zmieniała?
- Dwie drogi: przerwać cały merge (`git merge --abort`) i zacząć od zera albo odtworzyć konflikt w jednym pliku (`git restore --merge <plik>`, starsza forma: `git checkout -m <plik>`). Spróbuj obu (setup.sh przywraca stan wyjściowy).
- `git merge --abort` przywraca stan sprzed merge'a. Co z niezacommitowanymi zmianami sprzed merge'a? (dlatego merge zaczynamy na czystym katalogu roboczym)

## Pytania dodatkowe

1. Skąd git wie, że trwa merge? Jakie pliki w `.git/` to oznaczają? (`ls .git`)
2. Co robi `git restore --merge plik`, a co `git restore plik` w trakcie konfliktu?
3. Jak sprawdzić, które pliki po merge'u różnią się od wersji z obu gałęzi? (`git diff HEAD`, `git diff MERGE_HEAD`)
4. Kiedy `git merge --abort` nie da rady przywrócić stanu? (dokumentacja: `git merge --help`, sekcja o niezacommitowanych zmianach)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
