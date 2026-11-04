import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("PriceFormatter.format", "12,34", () -> PriceFormatter.format(12_34));
        T.eq("PriceFormatter.formatWithCurrency (metoda z feature)", "12,34 zł", () -> PriceFormatter.formatWithCurrency(12_34));
        T.eq("Receipt", "SUMA 5,00", () -> Receipt.total(5_00));
        T.eq("Invoice (z feature)", "Kubek 25,90 zł (VAT 23%)", () -> Invoice.line("Kubek", 25_90, 23));
    }
}
