#!/usr/bin/env bash
# Exercise 12: modify/delete conflict: main moved the logic to a new class, feature changed the old file.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 12-zmiana-w-usunietym-pliku: przygotowanie piaskownicy"
new_sandbox

write src/shop/Customer.java <<'EOF'
package shop;

public record Customer(String name, int age, boolean student) {
}
EOF
write src/shop/LegacyDiscountService.java <<'EOF'
package shop;

public class LegacyDiscountService {
    /** Discount in percent for the customer. */
    public int discountPercent(Customer customer) {
        if (customer.student()) {
            return 10;
        }
        return 0;
    }
}
EOF
write src/shop/Checkout.java <<'EOF'
package shop;

public class Checkout {
    private final LegacyDiscountService discounts = new LegacyDiscountService();

    public long total(Customer customer, long amount) {
        return amount - amount * discounts.discountPercent(customer) / 100;
    }
}
EOF
commit "Add discounts"

git checkout -q -b feature/senior-discount
write src/shop/LegacyDiscountService.java <<'EOF'
package shop;

public class LegacyDiscountService {
    public static final int SENIOR_AGE = 65;

    /** Discount in percent for the customer. */
    public int discountPercent(Customer customer) {
        if (customer.age() >= SENIOR_AGE) {
            return 15;
        }
        if (customer.student()) {
            return 10;
        }
        return 0;
    }
}
EOF
commit "Add 15% senior discount"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
git rm -q src/shop/LegacyDiscountService.java
write src/shop/DiscountPolicy.java <<'EOF'
package shop;

import java.util.List;
import java.util.function.Predicate;

/** Discount rules. The customer gets the best matching discount. Replaces LegacyDiscountService. */
public class DiscountPolicy {
    record Rule(Predicate<Customer> applies, int percent) {
    }

    private static final List<Rule> RULES = List.of(
            new Rule(Customer::student, 10));

    public static int discountPercent(Customer customer) {
        return RULES.stream().filter(r -> r.applies().test(customer)).mapToInt(Rule::percent).max().orElse(0);
    }
}
EOF
write src/shop/Checkout.java <<'EOF'
package shop;

public class Checkout {
    public long total(Customer customer, long amount) {
        return amount - amount * DiscountPolicy.discountPercent(customer) / 100;
    }
}
EOF
commit "Replace LegacyDiscountService with rule-based DiscountPolicy"
state_set main_start "$(git rev-parse HEAD)"

setup_done
