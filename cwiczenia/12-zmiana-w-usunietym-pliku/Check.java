import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("senior (65+) ma 15% (reguła z feature przeniesiona do DiscountPolicy)", 15,
                () -> DiscountPolicy.discountPercent(new Customer("Jan", 70, false)));
        T.eq("64 lata: bez rabatu", 0, () -> DiscountPolicy.discountPercent(new Customer("Jan", 64, false)));
        T.eq("student 10%", 10, () -> DiscountPolicy.discountPercent(new Customer("Ola", 21, true)));
        T.eq("student-senior: lepszy rabat, 15%", 15, () -> DiscountPolicy.discountPercent(new Customer("Ewa", 66, true)));
        T.eq("Checkout liczy z rabatem seniora", 85_00L, () -> new Checkout().total(new Customer("Jan", 80, false), 100_00));
    }
}
