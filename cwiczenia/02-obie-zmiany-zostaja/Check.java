import java.util.Arrays;
import java.util.List;
import shop.*;

// Behaviour expected on main after the merge: BLIK (main) and PAYPAL (feature) both exist.
public class Check {
    public static void main(String[] args) {
        T.eq("metody płatności w kolejności CASH, CARD, BLIK, PAYPAL",
                List.of("CASH", "CARD", "BLIK", "PAYPAL"),
                () -> Arrays.stream(PaymentMethod.values()).map(Enum::name).toList());
        T.eq("opłata BLIK 0,50 zł", 50L, () -> PaymentMethod.valueOf("BLIK").fee());
        T.eq("opłata PayPal 2,50 zł", 2_50L, () -> PaymentMethod.valueOf("PAYPAL").fee());
        T.eq("opłata kartą 1 zł (bez zmian)", 1_00L, () -> PaymentMethod.CARD.fee());
        String props = T.file("resources/messages.properties");
        for (String line : List.of("payment.cash=Gotowka", "payment.card=Karta platnicza",
                "payment.blik=BLIK", "payment.paypal=PayPal")) {
            T.that("messages.properties zawiera " + line,
                    () -> props != null && props.lines().anyMatch(line::equals), "brak tej linii");
        }
        T.that("messages.properties: każdy klucz tylko raz",
                () -> props != null && props.lines().filter(l -> !l.isBlank()).map(l -> l.split("=")[0])
                        .distinct().count() == props.lines().filter(l -> !l.isBlank()).count(),
                "jakiś klucz jest zduplikowany");
    }
}
