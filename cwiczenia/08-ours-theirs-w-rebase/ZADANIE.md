# 08. „Ours” i „theirs” w rebase są odwrotnie

Poziom: **średni** · Operacja: **rebase + checkout --ours/--theirs** · Teoria: [04](../../teoria/04-rebase.md), [02](../../teoria/02-anatomia-konfliktu.md)

## Uruchomienie

```bash
./cwiczenia/08-ours-theirs-w-rebase/setup.sh
cd cwiczenia/08-ours-theirs-w-rebase/repo
bash ../check.sh
```

## Sytuacja

Jesteś na swojej gałęzi `feature/translations` z dwoma commitami:

1. nowy eksport tłumaczeń z narzędzia TransTool (`resources/messages_pl.properties`: polskie znaki, nowe klucze),
2. formalne powitanie w `Greeter`.

Na `main` w tym czasie ktoś ręcznie poprawił `messages_pl.properties` (hotfix) i dodał przycinanie imienia w `Greeter`.

**Przenieś swoją gałąź na `main` (rebase).** Zasady:

- `messages_pl.properties` jest generowany. Tłumacze uwzględnili w eksporcie hotfix z main, więc w razie konfliktu **plik ma być dokładnie taki jak w Twoim eksporcie** (z gałęzi feature), bajt w bajt.
- `Greeter` scal ręcznie: formalne powitanie (feature) + przycięte imię (main).

## Oczekiwane

- Rebase na `main`, historia liniowa, oba commity są (te same opisy).
- `messages_pl.properties` identyczny z eksportem TransTool z feature.
- `Greeter.greet("  Ola ")` zwraca `Dzień dobry, Ola!`.

## Wskazówki

- Cały plik z jednej strony konfliktu: `git checkout --ours <plik>` albo `git checkout --theirs <plik>` (nowsza forma: `git restore --ours/--theirs`). Ale **która to strona w rebase?**
- Rebase nakłada Twoje commity na `main`. „Ours” = gałąź, **na którą** nakładasz (czyli `main` + już przeniesione commity), „theirs” = **Twój** commit, który właśnie jest nakładany. Przy `merge` jest odwrotnie.
- Nie zgaduj: przed `git add` obejrzyj wynik (`git diff --cached` albo `head` pliku). Polskie znaki to łatwy test, która to wersja.
- Jeśli po rozwiązaniu commit wychodzi pusty, git przy `--continue` go pominie. To znak, że wybrałeś wersję z main i Twój commit zniknął z historii.

## Pytania dodatkowe

1. Dlaczego w rebase „ours” i „theirs” są zamienione? Wyjaśnij na tym, jak działa rebase (cherry-pick po kolei na nową bazę).
2. Co oznacza `-X ours` / `-X theirs` przy `git rebase` i dlaczego to też jest „odwrotnie”?
3. Gdyby `messages_pl.properties` zawsze miał wygrywać po stronie tłumaczy, jak to zautomatyzować? (`.gitattributes` i własny driver merge, teoria 06)

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
