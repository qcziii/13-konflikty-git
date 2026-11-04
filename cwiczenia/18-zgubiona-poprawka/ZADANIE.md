# 18. Śledztwo: poprawka zginęła w merge'u

Poziom: **trudny** · Operacja: **log -S, bisect, show --remerge-diff, nowy commit** · Teoria: [09](../../teoria/09-sledztwo-po-zlym-merge.md)

## Uruchomienie

```bash
./cwiczenia/18-zgubiona-poprawka/setup.sh
cd cwiczenia/18-zgubiona-poprawka/repo
bash ../check.sh
```

## Sytuacja

Zgłoszenie z produkcji: „Znowu da się dodać do koszyka -3 sztuki i zamówienie ma ujemną sumę. Przecież BUG-104 był poprawiony!”. Test `./test.sh` faktycznie nie przechodzi.

Ktoś kiedyś poprawił ten błąd, a potem poprawka zniknęła. `main` jest opublikowany: **nie wolno przepisywać historii** (reset, rebase, amend starych commitów, force push).

**Znajdź, który commit wprowadził poprawkę i w którym commicie zginęła. Przywróć ją nowym commitem**, nie tracąc niczego, co weszło później.

## Oczekiwane

- Nowy commit (albo kilka) na `main`, historia nieprzepisana, bez nowych merge'y i bez revertu merge'a.
- Ujemna i zerowa ilość jest odrzucana (`IllegalArgumentException`), a rabat hurtowy, ignorowanie wielkości liter, `itemCount()` i `clear()` dalej działają.
- W **opisie** nowego commita podajesz skrót SHA (min. 7 znaków) commita z oryginalną poprawką **i** commita, w którym poprawka zginęła.

## Wskazówki

- Szukanie po treści: `git log -S'quantity must be positive' --oneline` (commity, które dodały albo usunęły ten tekst).
- Uwaga: `git log -S'...' -- src/shop/Cart.java` (z podaną ścieżką) **może nie pokazać** poprawki. Domyślne upraszczanie historii przy merge'ach odrzuca gałąź, z której plik „nie pochodzi”. Pomaga `--full-history`, a dla merge'y `-m` albo `--first-parent -m`.
- Gdzie zginęła? `git log --merges --oneline`, potem `git show --remerge-diff <merge>`: git odtwarza konflikt i pokazuje, jak go rozwiązano (git 2.36+).
- Automatycznie: `git bisect start HEAD <dobry-commit>`, `git bisect run ./test.sh`, na koniec `git bisect reset`.
- Przywrócenie: `git cherry-pick <poprawka>` (może dać konflikt i wciągnąć też test, który już jest) albo ręcznie. **Nie** `git revert` merge'a: zniknąłby rabat hurtowy.

## Pytania dodatkowe

1. Co robi `git show --remerge-diff` i dlaczego zwykły `git show <merge>` nie pokazał tej utraty?
2. Jak zapobiegać takim stratom? (testy do każdej poprawki, CI na wyniku merge'a, review merge'y z konfliktem)
3. Jak w opisie commita wskazać zgłoszenie i commit, żeby ktoś za rok to znalazł? (`Refs: BUG-104`, `Fixes:`)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
