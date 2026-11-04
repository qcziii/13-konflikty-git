# 16. Konflikt w pliku generowanym (lock)

Poziom: **średni** · Operacja: **merge, regeneracja pliku** · Teoria: [06](../../teoria/06-nietypowe-konflikty.md)

## Uruchomienie

```bash
./cwiczenia/16-plik-generowany-lock/setup.sh
cd cwiczenia/16-plik-generowany-lock/repo
bash ../check.sh
```

## Sytuacja

Projekt trzyma zależności w `deps.txt`, a `deps.lock` generuje z niego `tools/lock.sh` (dokładnie jak `package-lock.json` z `package.json` w npm, `poetry.lock`, `Cargo.lock`, `gradle.lockfile`). Pliku lock **nigdy nie edytuje się ręcznie**.

- `main`: sterownik PostgreSQL, podbicie slf4j do 2.0.17.
- `feature/guava` (Twoja): Guava, podbicie jackson-databind do 2.18.3 (poprawka bezpieczeństwa).

**Scal `feature/guava` do `main`.**

## Oczekiwane

- Merge do `main`.
- `deps.txt` ma dokładnie 5 zależności: slf4j 2.0.17, jackson-databind 2.18.3, junit, postgresql, guava.
- `deps.lock` jest dokładnie tym, co generuje `tools/lock.sh` z `deps.txt` (sumy kontrolne się zgadzają).

## Wskazówki

- Konflikt jest w obu plikach. Rozwiąż **źródło** (`deps.txt`): uważnie, obie strony podbiły różne wersje w tych samych liniach. Potem **wygeneruj** lock od nowa (`./tools/lock.sh`) i dodaj oba pliki.
- Ręczne sklejenie locka „obie strony bez znaczników” wygląda dobrze, ale sumy kontrolne (`integrity`) się nie zgadzają. W npm skończyłoby się to dziwnymi błędami instalacji.
- W npm: rozwiąż `package.json`, potem `npm install` (npm sam naprawia konflikt w `package-lock.json`). W Maven nie ma locka, ale konflikty w `pom.xml` rozwiązuje się tak samo starannie.

## Pytania dodatkowe

1. Dlaczego lock w ogóle trzyma się w repozytorium, skoro da się go wygenerować?
2. Które pliki w Twoim projekcie są generowane? Które z nich powinny być w `.gitignore`, a które w repo?
3. Co robi w `.gitattributes` linia `package-lock.json merge=binary` (albo `-merge`) i czy to dobry pomysł?

## Kiedy skończysz

`check.sh`: `WYNIK: wszystkie sprawdzenia przeszły`.
