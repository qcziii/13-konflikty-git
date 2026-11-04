import java.util.List;
import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("wyszukiwanie bez względu na wielkość liter", List.of("Lampka", "Lampa stojaca"),
                () -> SearchService.search(Products.ALL, "LAMP"));
        T.eq("najwyżej 10 wyników", 10, () -> SearchService.search(Products.ALL, "kubek").size());
        T.eq("puste zapytanie nic nie zwraca (commit Ani)", List.of(), () -> SearchService.search(Products.ALL, "   "));
        T.that("flaga SEARCH (feature) i RECOMMENDATIONS (main)",
                () -> T.file("src/shop/Features.java").contains("SEARCH = true")
                        && T.file("src/shop/Features.java").contains("RECOMMENDATIONS = true"), "brakuje którejś flagi");
    }
}
