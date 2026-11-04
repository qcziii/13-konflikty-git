import java.util.List;
import shop.*;

// Expected after the merge: gift cards (feature) work with the fee-aware total (main).
public class Check {
    public static void main(String[] args) {
        T.eq("opłata za kartę podarunkową = 0", 0L, () -> PaymentFees.fee(PaymentMethod.valueOf("GIFT_CARD")));
        T.eq("opłata kartą dalej 1 zł", 1_00L, () -> PaymentFees.fee(PaymentMethod.CARD));
        T.eq("faktura liczy sumę z opłatą (totalFor z main): karta",
                "Do zaplaty: 5100 gr (CARD)",
                () -> InvoiceService.invoiceLine(new Order(List.of(20_00L, 30_00L), PaymentMethod.CARD)));
        T.eq("faktura: karta podarunkowa", "Do zaplaty: 5000 gr (GIFT_CARD)",
                () -> InvoiceService.invoiceLine(new Order(List.of(20_00L, 30_00L), PaymentMethod.valueOf("GIFT_CARD"))));
        T.eq("Checkout bez zmian", "Razem: 5100",
                () -> Checkout.summary(new Order(List.of(20_00L, 30_00L), PaymentMethod.CARD)));
        T.that("nie przywrócono starej metody calculate() (main ją celowo usunął)",
                () -> java.util.Arrays.stream(PriceCalculator.class.getDeclaredMethods()).noneMatch(m -> m.getName().equals("calculate")),
                "PriceCalculator.calculate() dalej istnieje: popraw wywołanie w InvoiceService zamiast przywracać starą metodę");
    }
}
