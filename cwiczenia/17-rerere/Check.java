import java.util.List;
import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("menu: kategorie i pomoc (feature) + promocje (main)",
                List.of("Start", "Kategorie", "Produkty", "Promocje", "Koszyk", "Pomoc"), () -> Menu.mainItems());
        T.eq("stopka: rok (main) + linki (feature)", "(c) 2026 Sklep Kursanta | Regulamin | Kontakt", () -> Menu.footer());
        T.eq("strona pomocy z e-mailem (commit Ani z dnia 2)", "Masz pytanie? Napisz do nas: pomoc@sklep.example", () -> Help.text());
    }
}
