# 11. Niezacommitowane zmiany, pull i konflikt przy stash pop

Poziom: **łatwy/średni** · Operacja: **stash, pull, stash pop** · Teoria: [05](../../teoria/05-cherry-pick-stash-revert.md)

## Uruchomienie

```bash
./cwiczenia/11-stash-pop-z-konfliktem/setup.sh
cd cwiczenia/11-stash-pop-z-konfliktem/repo
bash ../check.sh
```

## Sytuacja

Jesteś w połowie pracy nad opłatą za opakowanie: zmiany w `Pricing.java` **nie są zacommitowane** (to jeszcze nie jest coś, co chcesz commitować). Piotr pisze: „wypchnąłem zmianę opłaty serwisowej, pobierz zanim pójdziesz dalej”.

**Pobierz zmiany z `origin/main` i zachowaj swoją pracę w toku, dalej niezacommitowaną.**

## Oczekiwane

- `main` = aktualny `origin/main` (Twoich commitów brak).
- Twoje zmiany są w katalogu roboczym (niezacommitowane), połączone ze zmianą Piotra: `withService(10 zł) = 10 + 3 (serwis) + 1 (opakowanie) = 14 zł`.
- Nic nie jest dodane do indeksu, schowek (`git stash list`) pusty, brak znaczników konfliktu.

## Wskazówki

- Zobacz, co powie `git pull` przy niezacommitowanych zmianach w tym samym pliku.
- `git stash` (albo `git stash push -m "opis"`) chowa zmiany, `git stash pop` przywraca. Przy konflikcie `pop` **nie usuwa** wpisu ze schowka („The stash entry is kept in case you need it again”). Po rozwiązaniu sam zdecyduj, czy go usunąć (`git stash drop`).
- Znaczniki konfliktu ze stasha to `Updated upstream` (to, co przyszło z pull) i `Stashed changes` (Twoje).
- Po rozwiązaniu konfliktu ze stasha plik jest w indeksie jako nierozwiązany. `git add` oznaczy go jako rozwiązany, ale doda do indeksu: `git restore --staged <plik>` cofa to bez utraty zmian.
- Skrót na przyszłość: `git pull --autostash` (albo `git config --global rebase.autoStash true` przy `pull.rebase=true`).

## Pytania dodatkowe

1. Gdzie fizycznie jest przechowywany stash? (`git log --oneline --graph stash@{0}`: to zwykłe commity)
2. Czy `git stash` chowa nowe, nieśledzone pliki? Jak to zmienić?
3. Przypadkiem zrobiłeś `git stash drop` za wcześnie. Jak odzyskać zmiany? (podpowiedź: `git fsck --unreachable | grep commit`, SHA wypisane przy drop)
4. Kiedy zamiast stasha lepiej zrobić commit „WIP” na osobnej gałęzi?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
