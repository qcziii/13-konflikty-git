# 02. Anatomia konfliktu

Ćwiczenia: [01](../cwiczenia/01-pierwszy-konflikt/ZADANIE.md), [02](../cwiczenia/02-obie-zmiany-zostaja/ZADANIE.md), [05](../cwiczenia/05-baza-diff3/ZADANIE.md), [08](../cwiczenia/08-ours-theirs-w-rebase/ZADANIE.md)

## Co git robi, gdy trafi na konflikt

1. Scala wszystko, co się da, i dodaje to do indeksu.
2. Pliki z konfliktem zostawia w katalogu roboczym ze **znacznikami konfliktu**, a w indeksie zapisuje je jako **nierozwiązane** (trzy wersje naraz).
3. Zapisuje w `.git/` stan operacji (`MERGE_HEAD`, `MERGE_MSG`), żeby wiedzieć, że merge trwa.
4. Zatrzymuje się i czeka na Ciebie.

```
$ git merge feature/express-delivery
Auto-merging src/shop/ShippingPolicy.java
CONFLICT (content): Merge conflict in src/shop/ShippingPolicy.java
Automatic merge failed; fix conflicts and then commit the result.
```

## Znaczniki konfliktu

Domyślny styl (`merge`):

```java
<<<<<<< HEAD
    public static final long FREE_SHIPPING_THRESHOLD = 150_00;
    public static final long STANDARD_FEE = 15_00;
=======
    public static final long FREE_SHIPPING_THRESHOLD = 200_00;
    public static final long STANDARD_FEE = 12_00;
    public static final long EXPRESS_FEE = 30_00;
>>>>>>> feature/express-delivery
```

- od `<<<<<<< HEAD` do `=======`: wersja **ours** (bieżąca gałąź),
- od `=======` do `>>>>>>> feature/...`: wersja **theirs** (wciągana).

Brakuje tu najważniejszej informacji: **jak było w bazie**. Czy `200_00` to stara wartość, czy nowa? Z dwóch stron tego nie wiesz.

## Styl zdiff3: pokaż bazę

```bash
git config --global merge.conflictStyle zdiff3     # git 2.35+; starszy: diff3
```

```java
<<<<<<< HEAD
    public static final Set<String> ADMIN = Set.of("READ", "WRITE");
||||||| 171835c
    public static final Set<String> ADMIN = Set.of("READ", "WRITE", "DELETE_USERS");
=======
    public static final Set<String> ADMIN = Set.of("READ", "WRITE", "DELETE_USERS", "EXPORT_REPORTS");
>>>>>>> feature/reports
```

Między `|||||||` a `=======` jest baza. Teraz widać: `HEAD` **usunął** `DELETE_USERS`, feature **dodała** `EXPORT_REPORTS`. Poprawny wynik: `READ, WRITE, EXPORT_REPORTS`. Bez bazy łatwo wziąć wersję feature „bo ma więcej” i przywrócić usunięte uprawnienie (ćwiczenie 05).

Metoda na każdy konflikt: **porównaj każdą stronę z bazą, nazwij intencję każdej zmiany, potem napisz wynik, który realizuje obie**.

`zdiff3` różni się od `diff3` tym, że wspólne linie na początku i końcu konfliktu wyciąga poza znaczniki (konflikt jest krótszy). Warto ustawić globalnie na stałe.

Dłuższe znaczniki (`<<<<<<<<`, 8 znaków i nazwa pliku) zobaczysz przy konfliktach ze zmianą nazwy pliku (ćwiczenie 13), a przy stashu etykiety `Updated upstream` / `Stashed changes` (ćwiczenie 11).

## Trzy wersje w indeksie (stage 1, 2, 3)

Nierozwiązany plik ma w indeksie trzy wpisy:

```
$ git ls-files -u
100644 b8a4fd8... 1	src/shop/Roles.java      # baza
100644 5239463... 2	src/shop/Roles.java      # ours
100644 7c1e2aa... 3	src/shop/Roles.java      # theirs
```

Każdą wersję możesz obejrzeć bez ruszania pliku:

```bash
git show :1:src/shop/Roles.java     # baza
git show :2:src/shop/Roles.java     # ours (HEAD)
git show :3:src/shop/Roles.java     # theirs
```

`git add plik` zastępuje trzy wpisy jednym (stage 0): od tej chwili plik jest **rozwiązany**. Git nie sprawdza, czy w środku zostały znaczniki: `git add` pliku z `<<<<<<<` też go „rozwiąże”.

## `git status` w trakcie konfliktu

```
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:
	modified:   src/shop/Checkout.java          <- scalone automatycznie

Unmerged paths:
  (use "git add <file>..." to mark resolution)
	both modified:   src/shop/ShippingPolicy.java
```

Skróty w `git status --short`:

| Skrót | Znaczenie |
|---|---|
| `UU` | both modified: obie strony zmieniły treść |
| `AA` | both added: obie dodały plik o tej samej ścieżce |
| `DU` | deleted by us: my usunęliśmy, oni zmienili |
| `UD` | deleted by them: oni usunęli, my zmieniliśmy |
| `DD` | both deleted (np. przy rename/rename) |
| `AU` / `UA` | added by us / added by them |

## Cała wersja z jednej strony

```bash
git checkout --ours   plik     # albo: git restore --ours plik
git checkout --theirs plik     # albo: git restore --theirs plik
git add plik
```

Przydaje się przy plikach binarnych i generowanych (rozdział 06). W kodzie rzadko: zwykle gubi zmiany drugiej strony.

**Uwaga, pułapka:** w **rebase** i przy `git stash pop` znaczenie się odwraca (rozdział 04): „ours” to gałąź, na którą nakładasz, a „theirs” to Twój commit.

| Operacja | ours (`HEAD`, `:2:`) | theirs (`:3:`) |
|---|---|---|
| `git merge X` stojąc na `main` | `main` | `X` |
| `git rebase main` stojąc na `feature` | `main` + już nałożone commity | nakładany commit z `feature` |
| `git cherry-pick C` stojąc na `main` | `main` | commit `C` |
| `git stash pop` | aktualny `HEAD` (Updated upstream) | zmiany ze stasha |

## Diff w trakcie konfliktu

```bash
git diff                 # tzw. combined diff: dwie kolumny +/-, pierwsza = ours, druga = theirs
git diff --ours          # wynik vs ours  (= git diff HEAD w trakcie merge'a, tylko pliki z konfliktem)
git diff --theirs        # wynik vs theirs
git diff --base          # wynik vs baza
git log --merge -p plik  # commity z obu stron, które dotknęły pliku z konfliktem
```

## Pytania sprawdzające

1. Co jest między `|||||||` a `=======` w stylu zdiff3? Dlaczego to najważniejsza część konfliktu?
2. Jak obejrzeć wersję pliku z bazy bez zmieniania ustawień i bez ruszania pliku?
3. Co robi `git add` z plikiem w konflikcie? Czy sprawdza znaczniki?
4. Co oznacza `UD` w `git status --short`?
5. Stoisz na `feature` i robisz `git rebase main`. Która wersja to „ours”?
