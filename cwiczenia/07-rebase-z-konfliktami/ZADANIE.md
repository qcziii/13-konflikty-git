# 07. Rebase z konfliktami w kilku commitach

Poziom: **średni** · Operacja: **rebase** · Teoria: [04](../../teoria/04-rebase.md)

## Uruchomienie

```bash
./cwiczenia/07-rebase-z-konfliktami/setup.sh
cd cwiczenia/07-rebase-z-konfliktami/repo
bash ../check.sh
```

## Sytuacja

Jesteś na swojej gałęzi `feature/loyalty-points` (punkty lojalnościowe, 3 commity). W tym czasie na `main` Piotr dodał walidację i normalizację e-maila klienta oraz zmienił format `toString()` na `imię (email)`.

Zespół chce **liniowej historii**: przed PR-em przenieś swoją gałąź na aktualny `main` (`git rebase main`). Gałąź nie była jeszcze nigdzie wypchnięta.

## Oczekiwane

- `feature/loyalty-points` zaczyna się od aktualnego `main`, bez commitów scalających, `main` nietknięty.
- Dalej **3 commity** z tymi samymi opisami, w tej samej kolejności.
- **Każdy** z trzech commitów się kompiluje i nie ma znaczników konfliktu (nie tylko ostatni).
- Wynik: walidacja i normalizacja e-maila (main), punkty (feature), `toString()` w formacie `Ala (ala@example.com) [12 pkt]`.

## Wskazówki

- Rebase przenosi commity **po jednym**. Konflikt może pojawić się przy każdym z nich, a za każdym razem rozwiązujesz go dla **tego** commita (nie dokładaj do commita 1 rzeczy z commita 3).
- W trakcie rebase: `git status` mówi, który commit jest nakładany („interactive rebase in progress; onto ...”, „Last command done”). Opis nakładanego commita widać też w znaczniku `>>>>>>> abc123 (Add loyalty points ...)`.
- Po rozwiązaniu: `git add`, potem `git rebase --continue` (nie `git commit`!). Pomyliłeś się? `git rebase --abort` wraca do stanu sprzed rebase.
- Sprawdzenie kompilacji każdego commita: `git rebase main --exec 'javac -d /tmp/out $(find src -name "*.java")'`, albo po fakcie: `git rebase --exec '...' main` (nic nie przeniesie, tylko wykona komendę po każdym commicie).
- Coś poszło źle po zakończonym rebase? Stara wersja gałęzi jest w `git reflog` (i w `ORIG_HEAD`): `git reset --hard ORIG_HEAD`.

## Pytania dodatkowe

1. Dlaczego po rebase commity mają nowe SHA, choć opisy są te same?
2. Co oznacza w trakcie rebase `HEAD` i `<<<<<<< HEAD`? (ćwiczenie 08 rozwija ten temat)
3. Kiedy rebase **nie** jest dobrym pomysłem? (ćwiczenia 03 i 09)
4. Co robi `git rebase --skip` i kiedy jest bezpieczny?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
