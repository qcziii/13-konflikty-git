#!/usr/bin/env bash
# Exercise 18: a bug fix was lost in a badly resolved merge long ago; find it and restore it.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 18-zgubiona-poprawka: przygotowanie piaskownicy"
new_sandbox

write test.sh <<'EOF'
#!/usr/bin/env bash
# Compiles src/ and tests/ and runs all tests. Exit code 0 = all green (usable with git bisect run).
cd "$(dirname "$0")" || exit 125
rm -rf out
javac -d out $(find src tests -name '*.java') > /dev/null 2>&1 || { echo "COMPILATION FAILED"; exit 125; }
java -cp out CartTest
EOF
chmod +x test.sh
write .gitignore <<'EOF'
out/
EOF
write src/shop/Cart.java <<'EOF'
package shop;

import java.util.LinkedHashMap;
import java.util.Map;

public class Cart {
    private final Map<String, Integer> quantities = new LinkedHashMap<>();
    private final Map<String, Long> prices = new LinkedHashMap<>();

    public void add(String item, long unitPrice, int quantity) {
        quantities.merge(item, quantity, Integer::sum);
        prices.put(item, unitPrice);
    }

    public long total() {
        long sum = 0;
        for (var e : quantities.entrySet()) {
            sum += prices.get(e.getKey()) * e.getValue();
        }
        return sum;
    }
}
EOF
write tests/CartTest.java <<'EOF'
import shop.Cart;

public class CartTest {
    static int failures = 0;

    static void check(String name, boolean condition) {
        System.out.println((condition ? "  ok   " : "  FAIL ") + name);
        if (!condition) {
            failures++;
        }
    }

    public static void main(String[] args) {
        Cart cart = new Cart();
        cart.add("kubek", 25_00, 2);
        check("total of 2 cups", cart.total() == 50_00);
        CartTestExtra.run();
        System.out.println(failures == 0 ? "ALL TESTS PASSED" : failures + " TEST(S) FAILED");
        System.exit(failures == 0 ? 0 : 1);
    }
}
EOF
write tests/CartTestExtra.java <<'EOF'
public class CartTestExtra {
    static void run() {
    }
}
EOF
commit "Add cart with tests"

git checkout -q -b feature/bulk-discount
as "Ola Wisniewska" owisniewska
write src/shop/Cart.java <<'EOF'
package shop;

import java.util.LinkedHashMap;
import java.util.Map;

public class Cart {
    public static final int BULK_QUANTITY = 10;

    private final Map<String, Integer> quantities = new LinkedHashMap<>();
    private final Map<String, Long> prices = new LinkedHashMap<>();

    public void add(String item, long unitPrice, int quantity) {
        String key = item.strip().toLowerCase();
        quantities.merge(key, quantity, Integer::sum);
        prices.put(key, unitPrice);
    }

    /** 10 or more pieces of the same item: 5% off that item. */
    public long total() {
        long sum = 0;
        for (var e : quantities.entrySet()) {
            long line = prices.get(e.getKey()) * e.getValue();
            if (e.getValue() >= BULK_QUANTITY) {
                line -= line * 5 / 100;
            }
            sum += line;
        }
        return sum;
    }
}
EOF
commit "Add 5% bulk discount from 10 pieces, ignore case of item names"

git checkout -q main
as "Ania Nowak" anowak
write src/shop/Cart.java <<'EOF'
package shop;

import java.util.LinkedHashMap;
import java.util.Map;

public class Cart {
    private final Map<String, Integer> quantities = new LinkedHashMap<>();
    private final Map<String, Long> prices = new LinkedHashMap<>();

    public void add(String item, long unitPrice, int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("quantity must be positive: " + quantity);
        }
        quantities.merge(item, quantity, Integer::sum);
        prices.put(item, unitPrice);
    }

    public long total() {
        long sum = 0;
        for (var e : quantities.entrySet()) {
            sum += prices.get(e.getKey()) * e.getValue();
        }
        return sum;
    }
}
EOF
write tests/CartTestExtra.java <<'EOF'
import shop.Cart;

public class CartTestExtra {
    static void run() {
        boolean thrown = false;
        try {
            new Cart().add("kubek", 25_00, -3);
        } catch (IllegalArgumentException e) {
            thrown = true;
        }
        CartTest.check("negative quantity is rejected", thrown);
    }
}
EOF
commit "Fix: reject non-positive quantity (negative totals in orders, BUG-104)"
state_set fix "$(git rev-parse HEAD)"

as "Piotr Zielinski" pzielinski
write README.md <<'EOF'
# Sklep

Run tests: ./test.sh
EOF
commit "Add README"

as "Ola Wisniewska" owisniewska
git merge -q feature/bulk-discount > /dev/null 2>&1 && die "setup: merge miał mieć konflikt"
git checkout -q --theirs src/shop/Cart.java
git add src/shop/Cart.java
tick; git commit -q --no-edit
state_set bad_merge "$(git rev-parse HEAD)"

as "Piotr Zielinski" pzielinski
write src/shop/Cart.java <<'EOF'
package shop;

import java.util.LinkedHashMap;
import java.util.Map;

public class Cart {
    public static final int BULK_QUANTITY = 10;

    private final Map<String, Integer> quantities = new LinkedHashMap<>();
    private final Map<String, Long> prices = new LinkedHashMap<>();

    public void add(String item, long unitPrice, int quantity) {
        String key = item.strip().toLowerCase();
        quantities.merge(key, quantity, Integer::sum);
        prices.put(key, unitPrice);
    }

    /** 10 or more pieces of the same item: 5% off that item. */
    public long total() {
        long sum = 0;
        for (var e : quantities.entrySet()) {
            long line = prices.get(e.getKey()) * e.getValue();
            if (e.getValue() >= BULK_QUANTITY) {
                line -= line * 5 / 100;
            }
            sum += line;
        }
        return sum;
    }

    public int itemCount() {
        return quantities.values().stream().mapToInt(Integer::intValue).sum();
    }

    public void clear() {
        quantities.clear();
        prices.clear();
    }
}
EOF
commit "Add itemCount() and clear()"
as "Ania Nowak" anowak
write README.md <<'EOF'
# Sklep

Run tests: ./test.sh

Every pull request needs a green ./test.sh.
EOF
commit "Document test requirement"
git branch -q -D feature/bulk-discount
state_set main_start "$(git rev-parse HEAD)"

setup_done
