# 13. Ta sama klasa przemianowana na dwie różne nazwy (rename/rename)

Poziom: **średni** · Operacja: **merge, git rm, git mv** · Teoria: [06](../../teoria/06-nietypowe-konflikty.md)

## Uruchomienie

```bash
./cwiczenia/13-zmiana-nazwy-pliku/setup.sh
cd cwiczenia/13-zmiana-nazwy-pliku/repo
bash ../check.sh
```

## Sytuacja

- Na `main` Piotr przemianował `Formatter` na `PriceFormatter` (konwencja nazw zespołu).
- Na `feature/invoice` Ania przemianowała tę samą klasę na `MoneyFormatter`, dodała metodę `formatWithCurrency` i nową klasę `Invoice`, która z niej korzysta.

Zespół ustalił: **obowiązuje nazwa z main, `PriceFormatter`**. **Scal `feature/invoice` do `main`.**

## Oczekiwane

- Merge do `main`.
- Jest tylko `PriceFormatter.java` (nie ma `Formatter.java` ani `MoneyFormatter.java`) i ma metodę `formatWithCurrency` z feature.
- Nigdzie w kodzie nie ma odwołań do `MoneyFormatter`. `Receipt` i `Invoice` działają.

## Wskazówki

- `git status` pokaże kilka rodzajów wpisów naraz (`both deleted`, `added by us`, `added by them`, `both modified`). Każdy trzeba rozwiązać osobno: `git add` albo `git rm`.
- Znaczniki konfliktu przy zmianie nazwy są dłuższe (`<<<<<<<<` 8 znaków) i mają nazwę pliku: `<<<<<<<< HEAD:src/shop/PriceFormatter.java`.
- Zmiana nazwy pliku to dla gita usunięcie + dodanie podobnego pliku. Git **zgaduje** zmianę nazwy po podobieństwie treści (domyślnie 50%). Zobacz: `git log --stat --follow -- src/shop/PriceFormatter.java` i `git diff -M main feature/invoice --stat`.
- Nie zapomnij o klasach, które **dopiero przyszły** z feature (`Invoice`): nie mają konfliktu, ale używają nazwy `MoneyFormatter`. Kompilator powie Ci prawdę.

## Pytania dodatkowe

1. Dlaczego git nie przechowuje informacji „ten plik zmienił nazwę”? Jakie to ma zalety i wady?
2. Co robi opcja `-X find-renames=30%` przy merge'u i kiedy się przydaje?
3. Jak zmniejszyć ryzyko takich konfliktów? (zmiana nazwy w osobnym, małym PR-ze, szybko scalonym; bez mieszania jej ze zmianami treści)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
