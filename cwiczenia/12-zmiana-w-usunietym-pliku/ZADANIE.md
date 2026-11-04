# 12. Zmiana w pliku, który druga gałąź usunęła (modify/delete)

Poziom: **średni** · Operacja: **merge, git rm** · Teoria: [06](../../teoria/06-nietypowe-konflikty.md)

## Uruchomienie

```bash
./cwiczenia/12-zmiana-w-usunietym-pliku/setup.sh
cd cwiczenia/12-zmiana-w-usunietym-pliku/repo
bash ../check.sh
```

## Sytuacja

- Na `main` Piotr usunął `LegacyDiscountService` i zastąpił go `DiscountPolicy` (lista reguł, klient dostaje najlepszy pasujący rabat). `Checkout` używa już nowej klasy.
- Na `feature/senior-discount` Ania dodała do **starej** klasy rabat 15% dla seniorów (65+).

**Scal `feature/senior-discount` do `main`.**

## Oczekiwane

- Merge do `main`, `LegacyDiscountService.java` **nadal usunięty**.
- Reguła seniora przeniesiona do `DiscountPolicy`: 65+ ma 15%, student 10%, student-senior 15% (lepszy rabat), 64 lata: 0%.
- `Checkout` liczy z rabatem seniora.

## Wskazówki

- Git zgłosi `CONFLICT (modify/delete)`. Zostawi w katalogu roboczym zmodyfikowaną wersję pliku. Plik bez znaczników konfliktu, kompiluje się... i jest martwym kodem, bo nikt go nie woła.
- Rozwiązanie ma dwie części: usunięcie pliku (`git rm <plik>`) **i** przeniesienie zmiany do nowego miejsca.
- Co dokładnie zmieniła feature? `git diff main...feature/senior-discount` (trzy kropki: od bazy) albo `git log -p MERGE_HEAD --not HEAD`.

## Pytania dodatkowe

1. Co oznaczają w `git status` skróty `DU`, `UD`, `AA`, `DD`, `UU`?
2. Co by się stało, gdybyś zrobił po prostu `git add .`? Czy testy z tego repo by to wykryły? A testy w prawdziwym projekcie?
3. Jak ułatwić życie innym przy usuwaniu klasy, którą ktoś może jeszcze zmieniać? (komunikacja, `@Deprecated` przez jedno wydanie, małe PR-y)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
