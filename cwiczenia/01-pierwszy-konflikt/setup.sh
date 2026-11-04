#!/usr/bin/env bash
# Exercise 01: first merge conflict (two edits in neighbouring lines).
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 01-pierwszy-konflikt: przygotowanie piaskownicy"
new_sandbox

write src/shop/ShippingPolicy.java <<'EOF'
package shop;

public class ShippingPolicy {
    // All amounts in grosze (1 zl = 100 gr).
    public static final long FREE_SHIPPING_THRESHOLD = 200_00;
    public static final long STANDARD_FEE = 15_00;

    /** Standard shipping fee for an order of the given value. */
    public static long fee(long orderValue) {
        if (orderValue >= FREE_SHIPPING_THRESHOLD) {
            return 0;
        }
        return STANDARD_FEE;
    }
}
EOF
write src/shop/Checkout.java <<'EOF'
package shop;

public class Checkout {
    public static long total(long orderValue) {
        return orderValue + ShippingPolicy.fee(orderValue);
    }
}
EOF
commit "Add shipping policy"

git checkout -q -b feature/express-delivery
write src/shop/ShippingPolicy.java <<'EOF'
package shop;

public class ShippingPolicy {
    // All amounts in grosze (1 zl = 100 gr).
    public static final long FREE_SHIPPING_THRESHOLD = 200_00;
    public static final long STANDARD_FEE = 12_00;
    public static final long EXPRESS_FEE = 30_00;

    /** Standard shipping fee for an order of the given value. */
    public static long fee(long orderValue) {
        if (orderValue >= FREE_SHIPPING_THRESHOLD) {
            return 0;
        }
        return STANDARD_FEE;
    }

    /** Express shipping is never free, but costs half above the threshold. */
    public static long expressFee(long orderValue) {
        if (orderValue >= FREE_SHIPPING_THRESHOLD) {
            return EXPRESS_FEE / 2;
        }
        return EXPRESS_FEE;
    }
}
EOF
commit "Add express delivery, lower standard fee to 12 zl"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
sed -i.bak 's/FREE_SHIPPING_THRESHOLD = 200_00/FREE_SHIPPING_THRESHOLD = 150_00/' src/shop/ShippingPolicy.java && rm -f src/shop/ShippingPolicy.java.bak
commit "Lower free shipping threshold to 150 zl (spring promo)"
state_set main_start "$(git rev-parse HEAD)"

setup_done
