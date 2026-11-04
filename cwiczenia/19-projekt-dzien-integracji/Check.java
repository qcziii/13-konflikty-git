import java.util.List;
import shop.*;

public class Check {
    public static void main(String[] args) {
        Order order = new Order("A1", List.of(new Order.Line("KUB", 2, 25_00)));
        T.eq("Order.total() zwraca Money (PR money-type)", new Money(50_00), () -> order.total());
        T.eq("potwierdzenie bez kuponu, kwota jako Money.format()", "Zamowienie A1 przyjete, do zaplaty 50,00 zl",
                () -> new OrderService().place(order));
        T.eq("potwierdzenie z kuponem RABAT5 (PR coupons)", "Zamowienie A1 przyjete, do zaplaty 45,00 zl",
                () -> new OrderService().place(order, "RABAT5"));
        T.eq("nieznany kupon nic nie daje", "Zamowienie A1 przyjete, do zaplaty 50,00 zl",
                () -> new OrderService().place(order, "XYZ"));
        T.eq("newsletter (PR newsletter)", 1, () -> {
            Newsletter n = new Newsletter();
            n.subscribe("Ala@example.com");
            n.subscribe(" ala@example.com");
            return n.count();
        });
    }
}
