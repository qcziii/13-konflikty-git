# 05. Bez bazy ani rusz: zdiff3

Poziom: **średni** · Operacja: **merge z merge.conflictStyle=zdiff3** · Teoria: [02](../../teoria/02-anatomia-konfliktu.md), [07](../../teoria/07-strategie-i-rerere.md)

## Uruchomienie

```bash
./cwiczenia/05-baza-diff3/setup.sh
cd cwiczenia/05-baza-diff3/repo
bash ../check.sh
```

## Sytuacja

`feature/reports` dodaje eksport raportów (`EXPORT_REPORTS`) dla ról MANAGER i ADMIN oraz limit wierszy raportu. Na `main` w międzyczasie wszedł commit „Update roles and limits (SEC-311)”. **Scal `feature/reports` do `main`.**

Zgłoszenie SEC-311 (zespół bezpieczeństwa): „Uprawnienie `DELETE_USERS` odebrać wszystkim rolom. Sesja maksymalnie 15 minut. Zmiany nie wolno cofnąć przy żadnym merge'u”.

## Najpierw spróbuj „po staremu”

Zrób merge z domyślnymi ustawieniami i spójrz na konflikt w `Roles.java`. Po jednej stronie ADMIN ma `READ, WRITE`, po drugiej `READ, WRITE, DELETE_USERS, EXPORT_REPORTS`. Kto dodał `DELETE_USERS`? Kto je usunął? Z samych dwóch stron nie da się tego stwierdzić.

Przerwij (`git merge --abort`), włącz pokazywanie bazy i scal jeszcze raz:

```bash
git config merge.conflictStyle zdiff3     # w tym repo; na stałe: git config --global ...
```

## Oczekiwane

- `merge.conflictStyle` = `zdiff3` (albo `diff3`).
- Merge `feature/reports` do `main`.
- ADMIN: `READ, WRITE, EXPORT_REPORTS` (bez `DELETE_USERS`), MANAGER: `READ, WRITE, EXPORT_REPORTS`.
- `limits.properties`: `session.timeout-minutes=15` (SEC-311 wygrywa z feature), `report.max-rows=5000`, `upload.max-mb=10`.

## Wskazówki

- W stylu zdiff3 między `|||||||` a `=======` jest **baza**: wersja ze wspólnego przodka. Porównaj każdą stronę z bazą: co zmieniła każda gałąź?
- Ta sama informacja bez zmiany ustawień: `git show :1:src/shop/Roles.java` (baza), `:2:` (ours), `:3:` (theirs). Albo `git log --merge -p -- src/shop/Roles.java`.
- Przy `session.timeout-minutes` obie strony zmieniły tę samą wartość na różne. Tu git nie pomoże: decyzję podejmuje człowiek (tu: zgłoszenie SEC-311). W prawdziwym projekcie: zapytaj autorów obu zmian.

## Pytania dodatkowe

1. Czym różni się `diff3` od `zdiff3`?
2. Jak zobaczyć bazę merge'a? (`git merge-base main feature/reports`, potem `git show <sha>:ścieżka`)
3. Dlaczego zespół bezpieczeństwa napisał „nie wolno cofnąć przy żadnym merge'u”? Jak taki błąd wykryć później? (ćwiczenie 18)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`. Warto zostawić `zdiff3` w konfiguracji globalnej na stałe.
