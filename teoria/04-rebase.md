# 04. Rebase i konflikty

Ćwiczenia: [07](../cwiczenia/07-rebase-z-konfliktami/ZADANIE.md), [08](../cwiczenia/08-ours-theirs-w-rebase/ZADANIE.md), [09](../cwiczenia/09-rebase-i-force-with-lease/ZADANIE.md)

## Co robi rebase

```
przed:                         po git rebase main (stojąc na feature):
A ── B ── C        main        A ── B ── C              main
      \                                   \
       D ── E      feature                 D' ── E'     feature
```

Rebase **nie przesuwa** commitów `D` i `E`. Tworzy nowe `D'` i `E'`: po kolei bierze zmianę każdego commita i nakłada ją na nową bazę (tak jak cherry-pick). Nowe commity mają te same opisy i autorów, ale inne SHA (inny rodzic = inny commit). Stare `D`, `E` dalej istnieją (`git reflog`, `ORIG_HEAD`), dopóki git ich nie posprząta.

Skutki:

- historia jest liniowa, bez commitów scalających,
- konflikt może wystąpić **przy każdym** nakładanym commicie osobno, a nie raz, jak przy merge'u,
- gałąź po rebase to **inna historia**: jeśli była wypchnięta, push wymaga wymuszenia (`--force-with-lease`).

## Konflikt w trakcie rebase

```
$ git rebase main
Rebasing (1/3)
CONFLICT (content): Merge conflict in src/shop/Customer.java
error: could not apply aab0b19... Add loyalty points to customer
```

```bash
git status                     # "interactive rebase in progress; onto 3f2a..." + który commit
# rozwiąż konflikt tak, jak powinien wyglądać TEN commit
git add plik
git rebase --continue          # NIE git commit
git rebase --skip              # pomiń ten commit (gdy jego zmiana jest już w main)
git rebase --abort             # wróć do stanu sprzed rebase
```

Rozwiązujesz konflikt **dla jednego commita**. Nie dokładaj do commita 1 rzeczy, które zrobisz w commicie 3: każdy commit po rebase powinien się kompilować i mieć sens sam w sobie (ćwiczenie 07). Kontrola:

```bash
git rebase main --exec "mvn -q -o compile"        # komenda po każdym nałożonym commicie
```

## Ours i theirs są odwrotnie

Rebase to seria cherry-picków **na `main`**. W trakcie nakładania commita:

- `HEAD` = `main` + commity już nałożone, czyli **„ours”**, górna część konfliktu (`<<<<<<< HEAD`),
- nakładany commit z Twojej gałęzi = **„theirs”**, dolna część (`>>>>>>> aab0b19 (Add loyalty points...)`).

```bash
git checkout --theirs plik     # w REBASE: wersja z MOJEGO commita
git checkout --ours plik       # w REBASE: wersja z main
```

To samo dotyczy `git rebase -X ours` / `-X theirs`. Najprostsza obrona: przed `git add` sprawdź wynik (`git diff --cached plik`). Jeśli po `--continue` git pisze, że commit jest pusty i go pomija, to znak, że wybrałeś stronę `main` i Twój commit właśnie zniknął (ćwiczenie 08).

## Kiedy rebase, kiedy merge

**Złota zasada:** nie rób rebase commitów, które ktoś inny już ma (wypchniętych na wspólną gałąź), chyba że zespół tak umówił i wszyscy wiedzą, jak się zachować.

| Sytuacja | Lepiej |
|---|---|
| lokalna gałąź, jeszcze nie wypchnięta, przed PR-em | rebase (czysta historia) |
| gałąź PR-a, na której są komentarze recenzentów i nikt inny nie pracuje | zależy od zespołu; merge `main` do gałęzi jest bezpieczny zawsze |
| gałąź, na której pracuje kilka osób | merge, albo rebase tylko po uzgodnieniu i z `--force-with-lease` |
| `main` / `develop` / release | **nigdy** rebase |

## Force push bezpiecznie

Po rebase wypchniętej gałęzi zwykły `git push` zostanie odrzucony (historia na serwerze nie jest przodkiem Twojej).

```bash
git push --force                              # nadpisuje bez pytania. Unikać
git push --force-with-lease                   # odmawia, jeśli na serwerze jest coś innego niż moje origin/<gałąź>
git push --force-with-lease --force-if-includes   # dodatkowo: to, co jest na serwerze, musiało być kiedyś w mojej gałęzi
```

**Pułapka (ćwiczenie 09):** `--force-with-lease` porównuje serwer z Twoim `origin/<gałąź>`. `git fetch` (także robiony w tle przez IDE) aktualizuje `origin/<gałąź>`, więc po fetchu „lease” przejdzie, nawet jeśli nowego commita kolegi nie masz w swojej gałęzi. `--force-if-includes` (git 2.30+) zamyka tę dziurę. Alias:

```bash
git config --global alias.pushf "push --force-with-lease --force-if-includes"
```

Bezpieczna kolejność przy wspólnej gałęzi:

```bash
git fetch
git switch feature/x
git pull --rebase                    # najpierw cudze commity z TEJ gałęzi
git rebase origin/main               # potem przeniesienie na main
git pushf
```

## Rebase interaktywny (w skrócie)

`git rebase -i main` pozwala przed przeniesieniem zmienić kolejność, połączyć (`squash`, `fixup`), poprawić opis (`reword`) albo usunąć commity. Konflikty rozwiązuje się tak samo. Zmiana kolejności commitów, które dotykają tych samych linii, sama w sobie powoduje konflikty.

`git commit --fixup <sha>` + `git rebase -i --autosquash main` to wygodny sposób na poprawki do wcześniejszych commitów gałęzi.

## Pytania sprawdzające

1. Dlaczego commity po rebase mają inne SHA?
2. Co robi `git rebase --continue`, a co `git rebase --skip`? Kiedy `--skip` jest bezpieczny?
3. W trakcie rebase chcesz wziąć cały plik z **własnego** commita. `--ours` czy `--theirs`?
4. Jak sprawdzić, że każdy commit po rebase się kompiluje?
5. Dlaczego `--force-with-lease` po `git fetch` może nadpisać cudzy commit? Co pomaga?
