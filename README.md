# Konflikty w gicie: teoria i ćwiczenia

Rozszerzenie do repozytorium [07-crud-git-konflikty](https://github.com/qcziii/07-crud-git-konflikty): tam konflikt pojawiał się „przy okazji” CRUD-a, tutaj **cały kurs dotyczy wyłącznie rozwiązywania konfliktów**.

Repo ma dwie części:

1. **Teoria** (`teoria/`): 9 rozdziałów, od tego, jak git scala zmiany, po śledztwo, w którym merge'u zginęła poprawka. Każdy kończy się pytaniami sprawdzającymi. Do tego jednostronicowa [ściąga](SCIAGA.md).
2. **Ćwiczenia** (`cwiczenia/`): 19 sytuacji z prawdziwej pracy w zespole. Każde ćwiczenie ma `setup.sh`, który buduje **piaskownicę**: osobne repozytorium gita z gałęziami i historią przygotowaną tak, żeby powstał konkretny konflikt (czasem także udawany GitHub w `origin.git`). Rozwiązujesz konflikt zwykłymi komendami gita, a `check.sh` sprawdza wynik: historię (rodziców merge'a, liniowość po rebase, czy nic nie zostało nadpisane na „serwerze”) **i** kod (kompilacja, testy w Javie).

## Wymagania

- **git 2.36+** (`git --version`; potrzebne m.in. `zdiff3`, `--remerge-diff`, `--force-if-includes`)
- **JDK 21+** (`javac` w PATH): kod w piaskownicach to małe klasy w Javie, `check.sh` je kompiluje i testuje
- `bash` (na Windows: **Git Bash**)
- bez Mavena, bez internetu, bez konta na GitHubie

## Jak pracować

```bash
./cwiczenia/01-pierwszy-konflikt/setup.sh      # zbuduj piaskownicę (z katalogu głównego kursu)
cd cwiczenia/01-pierwszy-konflikt/repo         # to jest osobne repo gita: tu pracujesz
git log --oneline --graph --all                # rozejrzyj się
# ... merge / rebase / cherry-pick / ... według ZADANIE.md
bash ../check.sh                               # sprawdzenie, ile razy chcesz
```

Ćwiczenie jest rozwiązane, gdy `check.sh` wypisze `WYNIK: wszystkie sprawdzenia przeszły`. Chcesz zacząć od nowa? Uruchom `setup.sh` jeszcze raz: kasuje piaskownicę i buduje ją od zera (zawsze identyczną, z tymi samymi SHA commitów).

Piaskownice (`cwiczenia/*/repo`, `cwiczenia/*/origin.git`) są w `.gitignore` tego repozytorium: to, co w nich robisz, nie miesza się z repo kursu. Uważaj tylko, w którym katalogu wpisujesz komendy (`git rev-parse --show-toplevel` powie, w którym repo jesteś).

Pracować możesz w terminalu albo w IDE: otwórz katalog `cwiczenia/NN-.../repo` jako projekt w IntelliJ (albo VS Code) i używaj jego okna rozwiązywania konfliktów. Warto zrobić część ćwiczeń tak, a część tak.

## Teoria

| # | Rozdział | Ćwiczenia |
|---|---|---|
| 01 | [Jak git scala zmiany](teoria/01-jak-git-scala.md) (merge trójstronny, baza, fast-forward, konflikt tekstowy a cichy) | 01, 02, 06 |
| 02 | [Anatomia konfliktu](teoria/02-anatomia-konfliktu.md) (znaczniki, zdiff3, stage 1/2/3, `--ours`/`--theirs`) | 01, 02, 05, 08 |
| 03 | [Rozwiązywanie krok po kroku](teoria/03-rozwiazywanie-krok-po-kroku.md) (procedura, `--abort`, `restore --merge`, IntelliJ, mergetool) | 01-06 |
| 04 | [Rebase i konflikty](teoria/04-rebase.md) (konflikt na każdym commicie, odwrócone ours/theirs, `--force-with-lease`) | 07, 08, 09 |
| 05 | [Cherry-pick, stash, revert](teoria/05-cherry-pick-stash-revert.md) (konflikty poza merge'em) | 10, 11, 18 |
| 06 | [Nietypowe konflikty](teoria/06-nietypowe-konflikty.md) (modify/delete, rename, binarne, generowane, formatowanie, `.gitattributes`) | 12-16 |
| 07 | [Strategie i rerere](teoria/07-strategie-i-rerere.md) (`-X ours` a `-s ours`, opcje, rerere) | 05, 14, 17 |
| 08 | [Praca w zespole i pull requesty](teoria/08-praca-w-zespole.md) (fetch, konflikt w PR, CI, jak mieć mniej konfliktów) | 03, 09, 19 |
| 09 | [Śledztwo po złym merge'u](teoria/09-sledztwo-po-zlym-merge.md) (`log -S`, `--remerge-diff`, `bisect`, naprawa bez przepisywania historii, reflog) | 18 |

## Ćwiczenia

| # | Ćwiczenie | Operacja | Poziom |
|---|---|---|---|
| 01 | [Pierwszy konflikt: dwie zmiany w sąsiednich liniach](cwiczenia/01-pierwszy-konflikt/ZADANIE.md) | merge | łatwy |
| 02 | [Obie zmiany zostają: dwie nowe metody płatności](cwiczenia/02-obie-zmiany-zostaja/ZADANIE.md) | merge | łatwy |
| 03 | [„This branch has conflicts”: aktualizacja gałęzi PR-a](cwiczenia/03-konflikt-w-pull-requescie/ZADANIE.md) | fetch, merge main do PR, push | łatwy/średni |
| 04 | [Wczorajszy merge: przerwij i zacznij od nowa](cwiczenia/04-przerwij-i-zacznij-od-nowa/ZADANIE.md) | merge --abort, restore --merge | łatwy/średni |
| 05 | [Bez bazy ani rusz: zdiff3](cwiczenia/05-baza-diff3/ZADANIE.md) | merge, conflictStyle | średni |
| 06 | [Cichy konflikt: merge bez konfliktu, a build czerwony](cwiczenia/06-cichy-konflikt/ZADANIE.md) | merge --no-commit / amend | średni |
| 07 | [Rebase z konfliktami w kilku commitach](cwiczenia/07-rebase-z-konfliktami/ZADANIE.md) | rebase | średni |
| 08 | [„Ours” i „theirs” w rebase są odwrotnie](cwiczenia/08-ours-theirs-w-rebase/ZADANIE.md) | rebase, --ours/--theirs | średni |
| 09 | [Rebase wspólnej gałęzi i bezpieczny force push](cwiczenia/09-rebase-i-force-with-lease/ZADANIE.md) | rebase, push --force-with-lease | średni/trudny |
| 10 | [Poprawka z release na main: cherry-pick z konfliktem](cwiczenia/10-cherry-pick-poprawki/ZADANIE.md) | cherry-pick -x | średni |
| 11 | [Niezacommitowane zmiany, pull i konflikt przy stash pop](cwiczenia/11-stash-pop-z-konfliktem/ZADANIE.md) | stash | łatwy/średni |
| 12 | [Zmiana w pliku, który druga gałąź usunęła](cwiczenia/12-zmiana-w-usunietym-pliku/ZADANIE.md) | merge, modify/delete | średni |
| 13 | [Ta sama klasa przemianowana na dwie nazwy](cwiczenia/13-zmiana-nazwy-pliku/ZADANIE.md) | merge, rename/rename | średni |
| 14 | [Ktoś przeformatował cały plik](cwiczenia/14-formatowanie-calego-pliku/ZADANIE.md) | merge, białe znaki | średni |
| 15 | [Konflikt w plikach binarnych](cwiczenia/15-pliki-binarne/ZADANIE.md) | merge, binarne | łatwy |
| 16 | [Konflikt w pliku generowanym (lock)](cwiczenia/16-plik-generowany-lock/ZADANIE.md) | merge, regeneracja | średni |
| 17 | [Rerere: rozwiąż raz, git zapamięta](cwiczenia/17-rerere/ZADANIE.md) | rerere | średni |
| 18 | [Śledztwo: poprawka zginęła w merge'u](cwiczenia/18-zgubiona-poprawka/ZADANIE.md) | log -S, bisect, remerge-diff | trudny |
| 19 | [Projekt: dzień integracji, trzy pull requesty](cwiczenia/19-projekt-dzien-integracji/ZADANIE.md) | wszystko | trudny |

## Zasady

- Pracujesz **tylko w piaskownicy** (`cwiczenia/NN-.../repo`). Nie zmieniaj `setup.sh`, `check.sh`, `Check.java` ani `scripts/`.
- Wymagania z `ZADANIE.md` są częścią zadania (np. „bez force push”, „poprawki w samym merge'u”). `check.sh` je sprawdza.
- Zanim rozwiążesz konflikt, **powiedz, co zmieniła każda strona względem bazy**. Rozwiązanie „wezmę moje” albo „wezmę ich” to prawie zawsze utrata czyjejś pracy.
- Po każdym rozwiązaniu: kompilacja i testy (w piaskownicach jest `build.sh` albo `test.sh` tam, gdzie to ma sens), zanim commit.
- Czytaj, co wypisuje git (`git status` po każdym kroku). Git prawie zawsze podpowiada następną komendę.
- Każde `ZADANIE.md` ma pytania dodatkowe. Odpowiedz na nie, zanim uznasz ćwiczenie za skończone.

Wszystkie ćwiczenia naraz: `./scripts/check-all.sh` (sprawdza te, dla których zbudowałeś piaskownicę).
