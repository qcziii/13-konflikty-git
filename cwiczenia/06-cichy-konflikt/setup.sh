#!/usr/bin/env bash
# Exercise 06: a merge without textual conflicts that breaks the build (semantic conflict).
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 06-cichy-konflikt: przygotowanie piaskownicy"
new_sandbox

write build.sh <<'EOF'
#!/usr/bin/env bash
# Compiles the project (javac). Run after every merge.
cd "$(dirname "$0")" && rm -rf out && javac -d out $(find src -name '*.java') && echo "BUILD OK"
EOF
chmod +x build.sh
write .gitignore <<'EOF'
out/
EOF
write src/shop/PaymentMethod.java <<'EOF'
package shop;

public enum PaymentMethod {
    CASH,
    CARD
}
EOF
write src/shop/Order.java <<'EOF'
package shop;

import java.util.List;

public record Order(List<Long> itemPrices, PaymentMethod payment) {
}
EOF
write src/shop/PriceCalculator.java <<'EOF'
package shop;

public class PriceCalculator {
    /** Sum of the items, in grosze. */
    public static long calculate(Order order) {
        return order.itemPrices().stream().mapToLong(Long::longValue).sum();
    }
}
EOF
write src/shop/Checkout.java <<'EOF'
package shop;

public class Checkout {
    public static String summary(Order order) {
        return "Razem: " + PriceCalculator.calculate(order);
    }
}
EOF
git update-index --chmod=+x build.sh 2> /dev/null
commit "Add orders and price calculator"

git checkout -q -b feature/gift-cards
write src/shop/PaymentMethod.java <<'EOF'
package shop;

public enum PaymentMethod {
    CASH,
    CARD,
    GIFT_CARD
}
EOF
write src/shop/InvoiceService.java <<'EOF'
package shop;

public class InvoiceService {
    public static String invoiceLine(Order order) {
        return "Do zaplaty: " + PriceCalculator.calculate(order) + " gr (" + order.payment() + ")";
    }
}
EOF
commit "Add gift card payments and invoices"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
write src/shop/PaymentFees.java <<'EOF'
package shop;

public class PaymentFees {
    /** Fee for the payment method, in grosze. */
    public static long fee(PaymentMethod method) {
        return switch (method) {
            case CASH -> 0;
            case CARD -> 1_00;
        };
    }
}
EOF
write src/shop/PriceCalculator.java <<'EOF'
package shop;

public class PriceCalculator {
    /** Sum of the items plus the payment fee, in grosze. */
    public static long totalFor(Order order) {
        long items = order.itemPrices().stream().mapToLong(Long::longValue).sum();
        return items + PaymentFees.fee(order.payment());
    }
}
EOF
write src/shop/Checkout.java <<'EOF'
package shop;

public class Checkout {
    public static String summary(Order order) {
        return "Razem: " + PriceCalculator.totalFor(order);
    }
}
EOF
commit "Include payment fee in total, rename calculate() to totalFor()"
state_set main_start "$(git rev-parse HEAD)"

setup_done
