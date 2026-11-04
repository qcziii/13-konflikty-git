# 05. Cherry-pick, stash i revert: konflikty poza merge'em

Ćwiczenia: [10](../cwiczenia/10-cherry-pick-poprawki/ZADANIE.md), [11](../cwiczenia/11-stash-pop-z-konfliktem/ZADANIE.md), [18](../cwiczenia/18-zgubiona-poprawka/ZADANIE.md)

Wszystkie te operacje w środku robią merge trójstronny. Konflikty wyglądają i rozwiązuje się je tak samo jak przy `git merge`. Różnią się baza i znaczenie stron.

## Cherry-pick

`git cherry-pick C` bierze **zmianę** wprowadzoną przez commit `C` (różnicę `C^` → `C`) i nakłada ją na `HEAD` jako nowy commit.

Merge trójstronny z: baza = `C^` (rodzic `C`), ours = `HEAD`, theirs = `C`.

```bash
git cherry-pick -x <sha>          # -x dopisuje do opisu "(cherry picked from commit <sha>)"
git cherry-pick -x A^..B          # zakres: od A do B włącznie
# konflikt:
git add plik
git cherry-pick --continue
git cherry-pick --skip | --abort
```

Typowe użycie: poprawka z gałęzi release na `main` albo odwrotnie (ćwiczenie 10). Zasady:

- **przenoś ideę poprawki, nie plik**: kod na `main` mógł się zmienić, więc `--theirs` na całym pliku zwykle cofa refaktoryzację z main,
- **`-x`** zostawia ślad, skąd commit pochodzi; przy przeglądzie, `git log --grep`, przy szukaniu, czy poprawka już jest na gałęzi,
- `git cherry-pick` merge'a wymaga `-m 1` (którą stronę traktować jako bazę). Zwykle lepiej wybrać konkretne commity.

Czy poprawka jest już na gałęzi? `git log --cherry-pick --oneline main...release/1.4` (porównuje treść zmian, nie SHA), `git cherry main release/1.4`.

## Stash

`git stash` zapisuje niezacommitowane zmiany (katalog roboczy i indeks) jako specjalne commity i przywraca czysty `HEAD`. `git stash pop` próbuje je nałożyć z powrotem: baza = commit, na którym zrobiłeś stash, ours = aktualny `HEAD`, theirs = zmiany ze stasha.

```bash
git stash push -m "opłata za opakowanie"   # -u: także nowe, nieśledzone pliki
git stash list
git stash show -p stash@{0}
git stash pop                    # apply + drop (drop tylko gdy bez konfliktu!)
git stash apply                  # bez usuwania
git stash drop stash@{0}
git stash branch nowa-galaz      # stash na nowej gałęzi od commita, na którym był zrobiony: bez konfliktu
```

Konflikt przy `pop` (ćwiczenie 11):

```
<<<<<<< Updated upstream
        return amount + SERVICE_FEE;
=======
        return amount + 2_00 + PACKAGING_FEE;
>>>>>>> Stashed changes
```

Po konflikcie:

1. Wpis **zostaje** w `git stash list` („The stash entry is kept in case you need it again”). Po rozwiązaniu usuń go sam: `git stash drop`.
2. Plik jest w indeksie jako nierozwiązany. Chcesz mieć zmiany dalej niezacommitowane i niedodane: rozwiąż plik i `git restore --staged plik` (albo `git add` + `git restore --staged`).
3. Coś poszło źle? Wpis ze stasha dalej jest: `git checkout -- plik` / `git restore plik`, i spróbuj jeszcze raz.

Skróty: `git pull --autostash`, `git rebase --autostash`, `git config --global rebase.autoStash true`.

Zgubiony stash (`drop` za wcześnie): SHA jest wypisane przy `drop` („Dropped stash@{0} (abc123...)”), `git stash apply abc123`. Bez SHA: `git fsck --unreachable | grep commit`, a potem `git show` po kolei.

## Revert

`git revert C` tworzy nowy commit, który **odwraca** zmianę `C`. Merge trójstronny z: baza = `C`, ours = `HEAD`, theirs = `C^`. Konflikt, gdy linie zmienione w `C` zmieniły się później.

```bash
git revert <sha>
git revert -m 1 <merge>     # cofnięcie merge'a względem pierwszego rodzica (main)
git revert --continue | --abort
```

Revert to sposób na cofnięcie czegoś w **opublikowanej** historii bez jej przepisywania.

**Uwaga na revert merge'a:** po `git revert -m 1 M` git uważa, że commity z gałęzi „są już w main” (bo są przodkami). Ponowny `git merge feature` po poprawkach **nie wciągnie** starych commitów, tylko nowe. Żeby przywrócić funkcję, trzeba zrobić revert revertu (`git revert <sha-revertu>`). Dlatego revert merge'a to ostateczność, nie sposób na „wyjęcie jednej zmiany” (ćwiczenie 18).

## Pytania sprawdzające

1. Co jest bazą merge'a trójstronnego przy `git cherry-pick C`?
2. Po co opcja `-x`?
3. Co dzieje się z wpisem w schowku, gdy `git stash pop` kończy się konfliktem?
4. Jak po rozwiązaniu konfliktu ze stasha zostawić zmiany niedodane do indeksu?
5. Dlaczego po `git revert -m 1 <merge>` ponowny merge tej samej gałęzi nie przywraca jej zmian?
