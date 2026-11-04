import shop.*;

// Behaviour expected on main after the merge.
public class Check {
    public static void main(String[] args) {
        T.eq("próg darmowej dostawy 150 zł (zmiana z main)", 150_00L, () -> ShippingPolicy.FREE_SHIPPING_THRESHOLD);
        T.eq("dostawa standardowa 12 zł (zmiana z feature)", 12_00L, () -> ShippingPolicy.fee(149_99));
        T.eq("zamówienie za 150 zł ma darmową dostawę standardową", 0L, () -> ShippingPolicy.fee(150_00));
        T.eq("ekspres poniżej progu kosztuje 30 zł", 30_00L, () -> ShippingPolicy.expressFee(100_00));
        T.eq("ekspres od 150 zł kosztuje połowę (15 zł)", 15_00L, () -> ShippingPolicy.expressFee(150_00));
        T.eq("Checkout.total(100 zł) = 112 zł", 112_00L, () -> Checkout.total(100_00));
    }
}
