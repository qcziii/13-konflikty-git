# 17. Rerere: rozwiąż raz, git zapamięta

Poziom: **średni** · Operacja: **rerere, próbny merge, reset** · Teoria: [07](../../teoria/07-strategie-i-rerere.md)

## Uruchomienie

```bash
./cwiczenia/17-rerere/setup.sh
cd cwiczenia/17-rerere/repo
bash ../check.sh
```

## Sytuacja

`feature/new-menu` to długo żyjąca gałąź (nowe menu sklepu). Zespół co jakiś czas robi **próbny merge** do `main`, żeby sprawdzić, czy wszystko się skleja, i cofa go, bo funkcja jeszcze nie jest gotowa. Za każdym razem te same konflikty w `Menu.java`. Rerere (**re**use **re**corded **re**solution) zapamiętuje, jak rozwiązałeś konflikt, i przy następnym takim samym konflikcie robi to sam.

## Kroki

1. Włącz rerere: `git config rerere.enabled true` (na stałe: `--global`).
2. Próbny merge `feature/new-menu` do `main`. Rozwiąż konflikty: menu `Start, Kategorie, Produkty, Promocje, Koszyk, Pomoc`, stopka `(c) 2026 Sklep Kursanta | Regulamin | Kontakt`. Zacommituj (git wypisze `Recorded resolution for ...`). Potem **cofnij** próbny merge: `git reset --hard HEAD~1`.
3. „Następnego dnia”: uruchom `bash ../dzien2.sh`. Ania dorzuci commit na `feature/new-menu`.
4. Prawdziwy merge `feature/new-menu` do `main`. Zobacz komunikat `Resolved 'src/shop/Menu.java' using previous resolution`. Sprawdź wynik, `git add`, commit.

## Oczekiwane

- `rerere.enabled = true`, w `.git/rr-cache` jest zapamiętane rozwiązanie.
- Na `main` jest **jeden** merge (próbny cofnięty), jego drugi rodzic to aktualna `feature/new-menu` (z commitem Ani).
- Menu, stopka i strona pomocy jak wyżej.

## Wskazówki

- Rerere wpisuje rozwiązanie do pliku, ale **nie** oznacza go jako rozwiązanego (dopóki nie ustawisz `rerere.autoUpdate`). Zawsze przejrzyj wynik: rerere nie wie, czy kontekst się nie zmienił.
- Co zapamiętał: `git rerere status`, `git rerere diff`. Zapomnieć złe rozwiązanie: `git rerere forget <plik>`.
- Rerere działa też przy rebase i cherry-pick. Najbardziej się przydaje przy wielokrotnym rebase długiej gałęzi i przy „merge do testów, potem rebase”.

## Pytania dodatkowe

1. Po czym rerere rozpoznaje „ten sam konflikt”? (podpowiedź: zawartość `.git/rr-cache/<hash>/preimage`)
2. Kiedy rerere może zaszkodzić?
3. Czy rozwiązania z rerere są udostępniane zespołowi przez `git push`? Jak można je przenieść?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
