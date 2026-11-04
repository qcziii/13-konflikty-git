import java.util.List;
import shop.*;

// Behaviour expected after the merge: products have sku (main) and category (feature).
public class Check {
    public static void main(String[] args) {
        T.eq("Product ma pola w kolejności sku, name, price, category",
                List.of("sku", "name", "price", "category"),
                () -> java.util.Arrays.stream(Product.class.getRecordComponents()).map(c -> c.getName()).toList());
        Catalog catalog = new Catalog();
        catalog.add(new Product("A-1", "Kubek", 25_00, "kuchnia"));
        catalog.add(new Product("B-7", "Lampka", 80_00, "salon"));
        catalog.add(new Product("A-2", "Talerz", 15_00, "kuchnia"));
        T.eq("findBySku z main dalej działa", "Lampka", () -> catalog.findBySku("B-7").orElseThrow().name());
        T.eq("byCategory z feature działa", List.of("Kubek", "Talerz"),
                () -> catalog.byCategory("kuchnia").stream().map(Product::name).toList());
        T.eq("all() bez zmian", 3, () -> catalog.all().size());
    }
}
