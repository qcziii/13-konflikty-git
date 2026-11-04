# 10. Poprawka z gałęzi release na main: cherry-pick z konfliktem

Poziom: **średni** · Operacja: **cherry-pick -x** · Teoria: [05](../../teoria/05-cherry-pick-stash-revert.md)

## Uruchomienie

```bash
./cwiczenia/10-cherry-pick-poprawki/setup.sh
cd cwiczenia/10-cherry-pick-poprawki/repo
bash ../check.sh
```

## Sytuacja

Klient zgłosił błąd w 1.4: VAT jest ucinany zamiast zaokrąglany (2,50 zł × 23% = 0,575 zł, a faktura pokazuje 0,57 zamiast 0,58). Ania poprawiła to na gałęzi `release/1.4` i wydała 1.4.1 (commit z poprawką + commit podbijający wersję).

Na `main` trwa praca nad 2.0: `Vat.java` został w międzyczasie przerobiony (dokumentacja, inna nazwa parametru, nowa metoda `gross`). **Przenieś na `main` samą poprawkę.**

## Oczekiwane

- Na `main` doszedł **dokładnie jeden** zwykły commit (nie merge).
- Opis commita: oryginalny tytuł + linia `(cherry picked from commit <pełne SHA poprawki>)` (opcja `-x`).
- `version.txt` na `main` dalej `2.0.0-SNAPSHOT`.
- VAT zaokrąglany (połówki w górę), refaktoryzacja z `main` zachowana (`rate`, `@param`, `gross()`).
- `release/1.4` nietknięta.

## Wskazówki

- Znajdź commit z poprawką: `git log --oneline release/1.4`, `git log main..release/1.4`.
- Dlaczego nie `git merge release/1.4`? Co jeszcze by przyszło?
- Konflikt w cherry-pick rozwiązujesz jak w merge: `git add`, potem `git cherry-pick --continue`. HEAD = `main`, druga strona = poprawka.
- Najczęstszy błąd: wziąć całą wersję pliku z poprawki (`--theirs`) i zgubić refaktoryzację z main. Przenieś **ideę** poprawki do nowego kodu.
- Zapomniałeś `-x`? `git commit --amend` i dopisz linię ręcznie.

## Pytania dodatkowe

1. Po co `-x`? Kto i kiedy skorzysta z tej adnotacji?
2. Co się stanie, jeśli później ktoś zrobi merge `release/1.4` do `main`? Czy poprawka pojawi się dwa razy? Czy będzie konflikt? (spróbuj na kopii: `git switch -c test main && git merge release/1.4`)
3. Lepsza praktyka w wielu zespołach: poprawka najpierw na `main`, potem cherry-pick na release. Dlaczego?
4. Jak przenieść kilka commitów naraz? (`git cherry-pick A..B`, uwaga na zakres)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
