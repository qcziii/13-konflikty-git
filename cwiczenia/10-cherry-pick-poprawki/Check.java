import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("VAT 23% od 2,50 zł = 0,58 zł (zaokrąglenie połówek w górę, poprawka)", 58L, () -> Vat.vat(2_50, 23));
        T.eq("VAT 23% od 0,02 zł = 0 gr", 0L, () -> Vat.vat(2, 23));
        T.eq("VAT 8% od 10,00 zł = 0,80 zł", 80L, () -> Vat.vat(10_00, 8));
        T.eq("gross() z main dalej działa i też zaokrągla", 3_08L, () -> Vat.gross(2_50));
        T.that("dokumentacja i nazwa parametru rate z main zostały",
                () -> T.file("src/shop/Vat.java").contains("@param rate") && T.file("src/shop/Vat.java").contains("int rate)"),
                "refaktoryzacja z main zginęła");
    }
}
