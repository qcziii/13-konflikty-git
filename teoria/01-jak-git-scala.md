# 01. Jak git scala zmiany

Ćwiczenia: [01](../cwiczenia/01-pierwszy-konflikt/ZADANIE.md), [02](../cwiczenia/02-obie-zmiany-zostaja/ZADANIE.md), [06](../cwiczenia/06-cichy-konflikt/ZADANIE.md)

## Commit to zdjęcie, nie zmiana

Każdy commit przechowuje **cały stan projektu** (drzewo plików) i wskaźnik na rodzica (albo rodziców). „Zmiana” wprowadzona przez commit to tylko różnica między nim a rodzicem, liczona w locie przez `git diff` czy `git show`.

```
A ── B ── C          main
      \
       D ── E        feature
```

Gałąź to ruchoma etykieta na commit. `main` wskazuje `C`, `feature` wskazuje `E`. `HEAD` mówi, na której gałęzi teraz stoisz.

## Merge trójstronny (three-way merge)

Przy `git merge feature` (stojąc na `main`) git potrzebuje trzech wersji:

| Nazwa | Co to | W przykładzie |
|---|---|---|
| **baza** (merge base) | ostatni wspólny przodek obu gałęzi | `B` |
| **ours** | to, na czym stoisz (`HEAD`) | `C` |
| **theirs** | to, co wciągasz | `E` |

Dla każdego fragmentu każdego pliku git porównuje obie strony z bazą:

| ours vs baza | theirs vs baza | wynik |
|---|---|---|
| bez zmian | bez zmian | baza |
| zmienione | bez zmian | ours |
| bez zmian | zmienione | theirs |
| zmienione tak samo | zmienione tak samo | ta zmiana (raz) |
| zmienione | zmienione **inaczej** | **KONFLIKT** |

Bazę widzisz komendą `git merge-base main feature`.

Bez bazy (scalanie dwóch wersji „na oko”) nie da się odróżnić „ja dodałem linię” od „ty usunąłeś linię”. Dlatego git zawsze patrzy na trzy wersje, a Ty też powinieneś (rozdział 02, `zdiff3`).

## Kiedy git uzna zmiany za kolidujące

Git porównuje **linie**. Konflikt powstaje, gdy zmienione fragmenty po obu stronach **nachodzą na siebie albo się stykają**. Dwie zmiany w sąsiednich liniach to konflikt (ćwiczenie 01), choć dotyczą różnych rzeczy. Dwie zmiany oddzielone choćby jedną niezmienioną linią zwykle scalają się same.

Dwie osoby dopisujące coś „na końcu listy” prawie zawsze dają konflikt (ćwiczenie 02): obie zmieniają to samo miejsce względem bazy.

## Fast-forward

Jeśli `main` nie ma nic nowego od rozgałęzienia, merge nie jest potrzebny: git po prostu przesuwa etykietę `main` na `E` (fast-forward). Nie powstaje commit scalający i nie ma konfliktów. `git merge --no-ff` wymusza commit scalający nawet wtedy (wiele zespołów tak scala PR-y, żeby w historii było widać, co weszło razem).

## Commit scalający

Wynik merge'a z rozgałęzionej historii to nowy commit z **dwoma rodzicami**:

```
A ── B ── C ── M     main
      \       /
       D ── E        feature
```

Pierwszy rodzic (`M^1`) to gałąź, na której stałeś (`C`), drugi (`M^2`) to wciągnięta (`E`). Kolejność ma znaczenie: `git log --first-parent` pokazuje historię „głównej linii”, `git revert -m 1 M` cofa merge względem pierwszego rodzica.

## Konflikt tekstowy a konflikt w kodzie

Git nie rozumie Javy. „Merge bez konfliktu” znaczy tylko: **żadne linie nie kolidują**. Kod może się mimo to nie kompilować albo działać źle (ćwiczenie 06):

- gałąź A zmienia nazwę metody i poprawia wszystkie wywołania, gałąź B dodaje nowe wywołanie starej nazwy,
- gałąź A dodaje wartość do enuma, gałąź B dodaje `switch` po wszystkich wartościach,
- gałąź A zmienia znaczenie parametru (złotówki na grosze), gałąź B dopisuje wywołanie ze starym znaczeniem.

Taki „cichy konflikt” (semantic conflict) wykrywa tylko kompilator i testy. Dlatego **po każdym merge'u: build i testy**, zanim wypchniesz.

## Najważniejsze komendy

```bash
git log --oneline --graph --all          # obraz gałęzi
git merge-base main feature              # baza
git diff main...feature                  # co zmieniła feature od bazy (trzy kropki!)
git diff main..feature                   # różnica między czubkami (dwie kropki)
git merge feature                        # scal feature do bieżącej gałęzi
git merge --no-ff feature                # zawsze z commitem scalającym
git merge --no-commit feature            # scal, ale zatrzymaj się przed commitem
```

## Pytania sprawdzające

1. Jakie trzy wersje pliku bierze pod uwagę merge? Która z nich nie jest czubkiem żadnej gałęzi?
2. Obie gałęzie zmieniły tę samą linię na **ten sam** tekst. Czy będzie konflikt?
3. Kiedy merge kończy się fast-forwardem? Czy wtedy może być konflikt?
4. Czym się różni `git diff main..feature` od `git diff main...feature`?
5. Merge przeszedł bez konfliktu. Czy to znaczy, że kod jest poprawny? Podaj przykład, kiedy nie.
