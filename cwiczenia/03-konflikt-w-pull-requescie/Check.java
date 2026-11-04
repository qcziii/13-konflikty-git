import shop.*;

// Behaviour expected on the PR branch after merging main: discount codes + cart limit + stream total.
public class Check {
    public static void main(String[] args) {
        T.eq("suma koszyka bez kodu", 300_00L, () -> {
            Cart c = new Cart();
            c.add(100_00);
            c.add(200_00);
            return c.total();
        });
        T.eq("kod WIOSNA10 daje 10% rabatu (zmiana z PR-a)", 270_00L, () -> {
            Cart c = new Cart();
            c.add(100_00);
            c.add(200_00);
            c.applyCode("WIOSNA10");
            return c.total();
        });
        T.throwsException("51. produkt w koszyku: IllegalStateException (zmiana z main)", IllegalStateException.class, () -> {
            Cart c = new Cart();
            for (int i = 0; i <= Cart.MAX_ITEMS; i++) {
                c.add(1_00);
            }
        });
        T.that("Cart.total() liczy sumę streamem jak na main (bez starej pętli for)",
                () -> T.file("src/shop/Cart.java").contains("mapToLong") && !T.file("src/shop/Cart.java").contains("for (long price"),
                "zostaw implementację total() z main i tylko dołóż rabat");
        String props = T.file("config/application.properties");
        T.that("application.properties: discount.codes.enabled=true (PR)", () -> props.contains("discount.codes.enabled=true"), "brak");
        T.that("application.properties: cart.max-items=50 (main)", () -> props.contains("cart.max-items=50"), "brak");
    }
}
