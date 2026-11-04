#!/usr/bin/env bash
# Exercise 03: a pull request has conflicts with main; update the PR branch by merging main into it.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 03-konflikt-w-pull-requescie: przygotowanie piaskownicy (repo + udawany GitHub w origin.git)"
new_sandbox

write src/shop/Cart.java <<'EOF'
package shop;

import java.util.ArrayList;
import java.util.List;

public class Cart {
    private final List<Long> prices = new ArrayList<>();

    public void add(long price) {
        prices.add(price);
    }

    /** Sum of all prices, in grosze. */
    public long total() {
        long sum = 0;
        for (long price : prices) {
            sum += price;
        }
        return sum;
    }
}
EOF
write config/application.properties <<'EOF'
shop.name=Sklep Kursanta
shop.currency=PLN
EOF
commit "Add cart"

# The student's pull request branch (already pushed earlier).
git checkout -q -b feature/discount-codes
as_student
write src/shop/Cart.java <<'EOF'
package shop;

import java.util.ArrayList;
import java.util.List;

public class Cart {
    private final List<Long> prices = new ArrayList<>();
    private String discountCode;

    public void add(long price) {
        prices.add(price);
    }

    public void applyCode(String code) {
        this.discountCode = code;
    }

    /** Sum of all prices, in grosze. */
    public long total() {
        long sum = 0;
        for (long price : prices) {
            sum += price;
        }
        return applyDiscount(sum);
    }

    private long applyDiscount(long sum) {
        if ("WIOSNA10".equals(discountCode)) {
            return sum - sum / 10;
        }
        return sum;
    }
}
EOF
commit "Add discount codes"
write config/application.properties <<'EOF'
shop.name=Sklep Kursanta
shop.currency=PLN
discount.codes.enabled=true
EOF
commit "Enable discount codes in config"
state_set feature_start "$(git rev-parse HEAD)"
git checkout -q main

publish_to_origin main feature/discount-codes
git checkout -q feature/discount-codes

# Meanwhile a colleague's pull request is merged into main on "GitHub".
colleague "Piotr Zielinski" pzielinski <<'EOF'
git checkout -q -b feature/cart-limit
write src/shop/Cart.java <<'X'
package shop;

import java.util.ArrayList;
import java.util.List;

public class Cart {
    public static final int MAX_ITEMS = 50;

    private final List<Long> prices = new ArrayList<>();

    public void add(long price) {
        if (prices.size() >= MAX_ITEMS) {
            throw new IllegalStateException("Cart is full");
        }
        prices.add(price);
    }

    /** Sum of all prices, in grosze. */
    public long total() {
        return prices.stream().mapToLong(Long::longValue).sum();
    }
}
X
write config/application.properties <<'X'
shop.name=Sklep Kursanta
shop.currency=PLN
cart.max-items=50
X
commit "Limit cart to 50 items"
git checkout -q main
merge_no_ff feature/cart-limit "Merge pull request #12 from pzielinski/feature/cart-limit"
git push -q origin main
EOF
state_set origin_main "$(git --git-dir="$ORIGIN" rev-parse main)"

setup_done
