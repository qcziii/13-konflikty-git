#!/usr/bin/env bash
# Exercise 04: a merge left half-resolved (one file resolved wrongly and staged, one file garbled).
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 04-przerwij-i-zacznij-od-nowa: przygotowanie piaskownicy"
new_sandbox

write src/shop/Product.java <<'EOF'
package shop;

public record Product(String name, long price) {
}
EOF
write src/shop/Catalog.java <<'EOF'
package shop;

import java.util.ArrayList;
import java.util.List;

public class Catalog {
    private final List<Product> products = new ArrayList<>();

    public void add(Product product) {
        products.add(product);
    }

    public List<Product> all() {
        return List.copyOf(products);
    }
}
EOF
commit "Add product catalog"

git checkout -q -b feature/categories
write src/shop/Product.java <<'EOF'
package shop;

public record Product(String name, long price, String category) {
}
EOF
write src/shop/Catalog.java <<'EOF'
package shop;

import java.util.ArrayList;
import java.util.List;

public class Catalog {
    private final List<Product> products = new ArrayList<>();

    public void add(Product product) {
        products.add(product);
    }

    public List<Product> all() {
        return List.copyOf(products);
    }

    public List<Product> byCategory(String category) {
        return products.stream().filter(p -> p.category().equals(category)).toList();
    }
}
EOF
commit "Add product categories"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
write src/shop/Product.java <<'EOF'
package shop;

public record Product(String sku, String name, long price) {
}
EOF
write src/shop/Catalog.java <<'EOF'
package shop;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class Catalog {
    private final List<Product> products = new ArrayList<>();

    public void add(Product product) {
        products.add(product);
    }

    public List<Product> all() {
        return List.copyOf(products);
    }

    public Optional<Product> findBySku(String sku) {
        return products.stream().filter(p -> p.sku().equals(sku)).findFirst();
    }
}
EOF
commit "Add SKU to products"
state_set main_start "$(git rev-parse HEAD)"

# "Yesterday": the merge was started and left in a bad state.
as_student
git merge feature/categories > /dev/null 2>&1
git checkout -q --ours src/shop/Catalog.java
git add src/shop/Catalog.java
write src/shop/Product.java <<'EOF'
package shop;

<<<<<<< HEAD
public record Product(String sku, String name, long price) {
public record Product(String name, long price, String category) {
>>>>>>> feature/categories
}
EOF

setup_done
