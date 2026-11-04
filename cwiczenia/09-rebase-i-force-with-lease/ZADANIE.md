# 09. Rebase wspólnej gałęzi i bezpieczny force push

Poziom: **średni/trudny** · Operacja: **fetch, rebase, push --force-with-lease** · Teoria: [04](../../teoria/04-rebase.md), [08](../../teoria/08-praca-w-zespole.md)

## Uruchomienie

```bash
./cwiczenia/09-rebase-i-force-with-lease/setup.sh
cd cwiczenia/09-rebase-i-force-with-lease/repo
bash ../check.sh
```

`origin.git` udaje GitHuba, `repo` to Twój klon.

## Sytuacja

Pracujesz z Anią na gałęzi `feature/search` (wyszukiwarka produktów). Twoje dwa commity są już wypchnięte. Ten zespół wymaga **liniowej historii**: przed merge'em PR-a gałąź trzeba przenieść (rebase) na aktualny `main` i wypchnąć z wymuszeniem.

Nie wiesz jednak, że od Twojego ostatniego `git fetch`:

- Ania wypchnęła na `feature/search` swój commit „Ignore blank search queries”,
- Piotr wypchnął commit na `main`.

**Przenieś `feature/search` na aktualny `origin/main` i wypchnij tak, żeby nikt nic nie stracił.**

## Oczekiwane

- `origin/feature/search` zaczyna się od aktualnego `origin/main`, historia liniowa, `origin/main` nietknięty.
- Na gałęzi są dokładnie 3 commity: Twoje dwa i commit Ani.
- Kod: wyszukiwanie bez względu na wielkość liter, limit 10 wyników, puste zapytanie nic nie zwraca (Ania); obie flagi w `Features`.
- Lokalna gałąź = `origin/feature/search`.

## Wskazówki

- `git push --force` nadpisuje gałąź na serwerze bez pytania. Commit Ani przepadłby po cichu.
- `git push --force-with-lease` odmawia, jeśli gałąź na serwerze jest inna niż Twoje `origin/feature/search`. **Ale** `git fetch` aktualizuje `origin/feature/search`, więc po fetchu „lease” przejdzie, nawet jeśli nie wciągnąłeś commita Ani! Sprawdź to (setup.sh przywraca stan).
- Dlatego: najpierw wciągnij zmiany z gałęzi (`git pull --rebase` albo `git merge --ff-only origin/feature/search`), dopiero potem rebase na `origin/main`.
- `git push --force-with-lease --force-if-includes` dodatkowo sprawdza, czy to, co jest na serwerze, było kiedyś w Twojej lokalnej gałęzi (git 2.30+). Warto mieć alias.
- Straciłeś commit Ani? Nie panikuj: on dalej istnieje (w `origin.git` jako obiekt, u Ani lokalnie, w Twoim `git reflog origin/feature/search`, jeśli go pobrałeś). Odzyskaj i powtórz.

## Pytania dodatkowe

1. Dokładnie: co sprawdza `--force-with-lease` bez argumentu, a co `--force-with-lease=feature/search:<sha>`?
2. Dlaczego niektóre IDE robią `git fetch` w tle co kilka minut i co to oznacza dla `--force-with-lease`?
3. Jak skonfigurować `git pull`, żeby domyślnie robił rebase? (`pull.rebase`) Jakie są wady?
4. Kiedy zespół powinien zabronić force push na gałęzi (branch protection)?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
