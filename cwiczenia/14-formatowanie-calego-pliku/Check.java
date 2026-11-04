import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("stawka podstawowa 23%", 23, () -> Tax.STANDARD_RATE);
        T.eq("stawka obniżona 8%", 8, () -> Tax.REDUCED_RATE);
        T.eq("brutto od 100 zł", 123_00L, () -> Tax.gross(100_00));
        T.that("dozwolone tylko stawki 0, 5, 8, 23", () -> Tax.isValidRate(5) && Tax.isValidRate(0) && !Tax.isValidRate(22),
                "isValidRate nie ma zmiany z feature");
        T.eq("faktura", "netto 10000, VAT 2300, brutto 12300", () -> Invoice.summary(100_00));
    }
}
