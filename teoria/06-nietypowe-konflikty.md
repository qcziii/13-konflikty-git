# 06. Nietypowe konflikty: pliki usunięte, przemianowane, binarne, generowane, formatowanie

Ćwiczenia: [12](../cwiczenia/12-zmiana-w-usunietym-pliku/ZADANIE.md), [13](../cwiczenia/13-zmiana-nazwy-pliku/ZADANIE.md), [14](../cwiczenia/14-formatowanie-calego-pliku/ZADANIE.md), [15](../cwiczenia/15-pliki-binarne/ZADANIE.md), [16](../cwiczenia/16-plik-generowany-lock/ZADANIE.md)

## Modify/delete

Jedna strona usunęła plik, druga go zmieniła.

```
CONFLICT (modify/delete): src/shop/LegacyDiscountService.java deleted in HEAD and modified in feature/senior-discount.
Version feature/senior-discount of src/shop/LegacyDiscountService.java left in tree.
```

Git zostawia zmodyfikowaną wersję **bez znaczników**. Możliwe decyzje:

- plik ma zostać usunięty (najczęściej, bo usunięcie było celowe): `git rm plik`, **i przenieś zmianę tam, gdzie teraz jest ta logika** (ćwiczenie 12). Samo `git rm` gubi pracę drugiej strony,
- plik ma zostać: `git add plik` (np. ktoś usunął go przez pomyłkę).

Co zmieniła druga strona: `git diff main...feature -- plik` albo `git log -p MERGE_HEAD --not HEAD -- plik`.

## Zmiana nazwy (rename)

Git **nie zapisuje** zmian nazw. Commit to zdjęcie drzewa plików. Przy merge'u (i `git log --follow`, `git diff -M`) git **wykrywa** zmianę nazwy, szukając pary „usunięty plik + nowy plik o podobnej treści” (domyślnie co najmniej 50% podobieństwa).

- **rename + modify**: jedna strona zmieniła nazwę, druga treść. Zwykle git sam przeniesie zmianę treści do nowego pliku. Bez konfliktu.
- **rename + duża zmiana treści**: podobieństwo spada poniżej progu, git widzi „usunięty + nowy” i robi z tego modify/delete. Pomaga `git merge -X find-renames=30%`.
- **rename/rename** (ćwiczenie 13): obie strony zmieniły nazwę tego samego pliku na różne. `git status` pokaże `both deleted` dla starej nazwy i `added by us` / `added by them` dla nowych. Zespół musi wybrać jedną nazwę: `git rm` zbędnej, zachowaj treść z obu stron, popraw odwołania (kompilator je wskaże).
- **rename/delete**, **rename/add**, **directory rename**: rzadsze warianty tego samego problemu.

Profilaktyka: zmiana nazwy pliku lub pakietu w **osobnym, małym PR-ze**, scalonym szybko, bez mieszania ze zmianami treści.

## Pliki binarne

Obrazki, PDF, `.docx`, `.xlsx`, `.jar`: git nie scali ich linia po linii.

```
warning: Cannot merge binary files: assets/logo.png (HEAD vs. feature/rebranding)
CONFLICT (content): Merge conflict in assets/logo.png
```

W katalogu roboczym zostaje wersja **ours**, bez znaczników. `git add` od razu „rozwiązuje” konflikt na korzyść bieżącej gałęzi (ćwiczenie 15). Wybór:

```bash
git checkout --theirs assets/logo.png && git add assets/logo.png
git show :3:assets/logo.png > /tmp/logo-theirs.png     # podgląd przed decyzją
```

Jeśli obie wersje mają coś cennego, scalić może tylko człowiek w odpowiednim programie (grafik, autor dokumentu). Duże binaria w repo: Git LFS, a dla plików, których nie da się scalać, blokady (`git lfs lock`).

## Pliki generowane (lock, wygenerowany kod)

`package-lock.json`, `yarn.lock`, `poetry.lock`, `Cargo.lock`, `gradle.lockfile`, wygenerowane klasy, zminifikowane pliki, snapshoty testów.

**Nie scalaj ręcznie.** Rozwiąż **źródło** (`package.json`, `deps.txt`, schemat), potem **wygeneruj** plik od nowa i dodaj oba (ćwiczenie 16):

```bash
# rozwiąż package.json
npm install                       # npm sam naprawia konflikt w package-lock.json
git add package.json package-lock.json
```

Ręcznie sklejony lock wygląda dobrze, ale sumy kontrolne, wersje zależności przechodnich czy pole `integrity` nie będą się zgadzać.

Pliki generowane, których nie trzeba trzymać w repo (np. `target/`, `build/`, `dist/`), powinny być w `.gitignore`: wtedy nie ma o co się kłócić.

## Formatowanie i białe znaki

Ktoś przeformatował cały plik (spacje, wcięcia, kolejność importów), ktoś inny zmienił jedną linię: konflikt na cały plik (ćwiczenie 14).

- **Najlepiej: ten sam formatter na swojej gałęzi przed merge'em** (osobny commit). Różnice formatowania znikają po obu stronach, zostaje konflikt tylko tam, gdzie naprawdę coś zmieniłeś.
- `git merge -X ignore-space-change` (`-X ignore-all-space`, `-X ignore-space-at-eol`): dopasowuje zmiany, ignorując białe znaki. **Ale** w liniach, które zmieniła tylko jedna strona, wynik może wziąć białe znaki drugiej strony: po cichu przywraca stare formatowanie. Po takim merge'u uruchom formatter jeszcze raz.
- Końce linii (CRLF/LF) to ten sam problem: plik zapisany na Windows z CRLF „zmienia” wszystkie linie. Zapobiega temu `.gitattributes` w repo:

```gitattributes
* text=auto eol=lf
*.bat text eol=crlf
*.png binary
```

Masowe formatowanie w zespole: jeden commit, ogłoszony, wszyscy scalają swoje PR-y przed nim albo formatują po nim. Commit formatujący dopisz do `.git-blame-ignore-revs` i ustaw `git config blame.ignoreRevsFile .git-blame-ignore-revs`, żeby `git blame` go pomijał.

## `.gitattributes` i sterowniki merge

```gitattributes
CHANGELOG.md     merge=union      # bierze linie z obu stron bez znaczników (kolejność dowolna!)
*.png            binary           # nie próbuj diffu ani merge'a tekstowego
package-lock.json  -merge         # zawsze konflikt, zawsze ours w katalogu roboczym (jak binarny)
messages_*.properties merge=ours  # wymaga zdefiniowania sterownika:
```

```bash
git config merge.ours.driver true     # "sterownik", który zawsze zostawia naszą wersję
```

`merge=union` nadaje się tylko do plików, w których każda linia jest niezależna (lista, changelog). W kodzie da złą składnię. Sterowniki z `git config` nie są wypychane z repo: każdy członek zespołu musi je ustawić u siebie.

## Pytania sprawdzające

1. Git zgłosił modify/delete. Kiedy odpowiedzią jest `git rm`, a kiedy `git add`? Czego nie wolno zapomnieć przy `git rm`?
2. Dlaczego git może nie wykryć zmiany nazwy pliku? Co wtedy zobaczysz?
3. Co jest w katalogu roboczym po konflikcie pliku binarnego?
4. Jak poprawnie rozwiązać konflikt w `package-lock.json`?
5. Dlaczego `-X ignore-space-change` może zepsuć formatowanie i jak się przed tym zabezpieczyć?
