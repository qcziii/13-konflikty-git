import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("opłata za opakowanie 1 zł (Twoja praca w toku)", 1_00L, () -> Pricing.PACKAGING_FEE);
        T.eq("opłata serwisowa 3 zł (kolega)", 3_00L, () -> Pricing.SERVICE_FEE);
        T.eq("withService(10 zł) = 10 + 3 + 1 = 14 zł", 14_00L, () -> Pricing.withService(10_00));
        T.eq("paragon z walutą (kolega)", "Kawa: 1400 gr", () -> Receipt.line("Kawa", 10_00));
    }
}
