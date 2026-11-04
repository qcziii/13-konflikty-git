import shop.*;

public class Check {
    public static void main(String[] args) {
        T.throwsException("ujemna ilość jest odrzucana (przywrócona poprawka)", IllegalArgumentException.class,
                () -> new Cart().add("kubek", 25_00, -3));
        T.throwsException("zerowa ilość jest odrzucana", IllegalArgumentException.class, () -> new Cart().add("kubek", 25_00, 0));
        T.eq("rabat hurtowy dalej działa (z merge'a)", 237_50L, () -> {
            Cart c = new Cart();
            c.add("kubek", 25_00, 10);
            return c.total();
        });
        T.eq("nazwy produktów bez względu na wielkość liter (z merge'a)", 3, () -> {
            Cart c = new Cart();
            c.add("Kubek", 25_00, 1);
            c.add("kubek ", 25_00, 2);
            return c.itemCount();
        });
        T.eq("itemCount() i clear() dalej działają (późniejsze commity)", 0, () -> {
            Cart c = new Cart();
            c.add("kubek", 25_00, 3);
            c.clear();
            return c.itemCount();
        });
    }
}
