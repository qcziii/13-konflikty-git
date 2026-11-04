# 14. Ktoś przeformatował cały plik

Poziom: **średni** · Operacja: **merge, -X ignore-space-change, formatowanie przed merge'em** · Teoria: [06](../../teoria/06-nietypowe-konflikty.md), [07](../../teoria/07-strategie-i-rerere.md)

## Uruchomienie

```bash
./cwiczenia/14-formatowanie-calego-pliku/setup.sh
cd cwiczenia/14-formatowanie-calego-pliku/repo
bash ../check.sh
```

## Sytuacja

- Na `main` Piotr uruchomił nowy formatter zespołu (`./format.sh`: tabulatory na 4 spacje) na całym kodzie. Commit: „no functional changes”.
- Na `feature/new-rates` (Twoja gałąź) zmieniłeś stawki VAT (23% i 8%) i walidację stawek. Pisałeś jeszcze tabulatorami.

**Scal `feature/new-rates` do `main`.**

## Oczekiwane

- Merge na `main` (pierwszy rodzic: poprzedni `main`), zawiera `feature/new-rates`.
- Nowe stawki i walidacja z feature.
- **Formatowanie z main zachowane**: w kodzie nie ma ani jednego tabulatora.

## Wskazówki

- Zrób zwykły merge i zobacz, jak duży jest konflikt. Ile linii naprawdę zmieniłeś?
- Spróbuj `git merge -X ignore-space-change feature/new-rates` (albo `ignore-all-space`). Konfliktu nie ma... sprawdź wynik (`cat -A src/shop/Tax.java | head`, `bash ../check.sh`). Opcja ignoruje różnice w białych znakach przy **dopasowywaniu** zmian, ale wynik może wziąć linie z białymi znakami drugiej strony.
- Sposób, który działa zawsze: **przed merge'em przepuść swoją gałąź przez ten sam formatter** (osobny commit), wtedy różnice w formatowaniu znikają po obu stronach i zostaje mały konflikt tylko w liniach, które naprawdę zmieniłeś.
- Inna droga: `-X ignore-space-change`, a potem `./format.sh` i `git commit --amend` na merge'u.

## Pytania dodatkowe

1. Jak zespół powinien wprowadzać formatter, żeby nie zablokować wszystkich otwartych PR-ów? (jeden commit na raz, ogłoszenie, `.git-blame-ignore-revs`)
2. Co robi plik `.git-blame-ignore-revs` i jak go włączyć (`blame.ignoreRevsFile`)?
3. Konflikty końców linii (CRLF/LF) wyglądają podobnie: cały plik „zmieniony”. Jak im zapobiega `.gitattributes` (`* text=auto eol=lf`)?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
