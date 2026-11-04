# 19. Projekt: dzień integracji, trzy pull requesty

Poziom: **trudny** · Operacja: **wszystko razem** · Teoria: wszystkie rozdziały, zwłaszcza [08](../../teoria/08-praca-w-zespole.md)

## Uruchomienie

```bash
./cwiczenia/19-projekt-dzien-integracji/setup.sh
cd cwiczenia/19-projekt-dzien-integracji/repo
bash ../check.sh
```

## Sytuacja

Przed wydaniem 1.1 trzy zatwierdzone pull requesty czekają na scalenie do `main`. Wszystkie wyszły z wydania 1.0.0 i nic o sobie nie wiedzą:

1. `feature/newsletter` (Ola): zapisy na newsletter.
2. `feature/money-type` (Piotr): typ `Money` zamiast gołych `long`, `Order.total()` zwraca `Money`.
3. `feature/coupons` (Ania): kupony rabatowe; przy okazji usunęła `Notifications` i potwierdzenie zamówienia buduje w `OrderService`.

Każdy dopisał swój wpis do `CHANGELOG.md`. **Scal je do `main` w tej kolejności (1, 2, 3)**, każdy osobnym commitem scalającym (`--no-ff`).

## Oczekiwane

- Na `main` (first-parent) dokładnie 3 nowe commity: merge 1, merge 2, merge 3, w tej kolejności.
- **Każdy** merge się kompiluje (`bash build.sh`).
- `Notifications.java` usunięty (decyzja z PR 3), `Order.total()` zwraca `Money`, potwierdzenie: `Zamowienie A1 przyjete, do zaplaty 45,00 zl` (z kuponem `RABAT5`), bez kuponu 50,00 zl.
- `CHANGELOG.md`: w sekcji `Unreleased` trzy wpisy w kolejności scalania.

## Wskazówki

- Przed każdym merge'em: co ten PR zmienia i co już jest na `main`? `git diff main...feature/x --stat`.
- Merge 2 i 3 dadzą różne rodzaje konfliktów naraz: treść, modify/delete, a w 3 także konflikt „cichy” (kod Ani nie zna typu `Money`). Kompilator po rozwiązaniu konfliktów tekstowych to obowiązkowy krok.
- Przy modify/delete (`Notifications`): obowiązuje decyzja z PR 3 (usunięty), ale formatowanie kwoty z PR 2 (`Money.format()`) ma przetrwać w nowym miejscu.
- Merge zepsuty? `git merge --abort` przed commitem, `git reset --hard HEAD~1` po commicie (dopóki nie wypchnięte).
- Dobra praktyka: po każdym merge'u `bash build.sh` i dopiero commit (albo `git merge --no-commit`).

## Pytania dodatkowe

1. Czy kolejność scalania ma znaczenie dla końcowego kodu? A dla tego, kto rozwiązuje konflikty?
2. Jak to wyglądałoby na GitHubie? Kto powinien rozwiązać konflikt PR 3: integrator czy Ania? (merge `main` do PR-a, jak w ćwiczeniu 03)
3. Jakie zasady w zespole zmniejszyłyby liczbę konfliktów w tym przykładzie?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`. Omów z prowadzącym każdy merge (`git show --remerge-diff <merge>` pokaże, jak rozwiązałeś konflikty).
