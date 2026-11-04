#!/usr/bin/env bash
# Exercise 02: both sides added something in the same place, both must stay.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 02-obie-zmiany-zostaja: przygotowanie piaskownicy"
new_sandbox

write src/shop/PaymentMethod.java <<'EOF'
package shop;

public enum PaymentMethod {
    CASH,
    CARD;

    /** Fee charged by the payment operator, in grosze. */
    public long fee() {
        return switch (this) {
            case CASH -> 0;
            case CARD -> 1_00;
        };
    }
}
EOF
write resources/messages.properties <<'EOF'
payment.cash=Gotowka
payment.card=Karta platnicza
EOF
commit "Add payment methods"

git checkout -q -b feature/paypal
write src/shop/PaymentMethod.java <<'EOF'
package shop;

public enum PaymentMethod {
    CASH,
    CARD,
    PAYPAL;

    /** Fee charged by the payment operator, in grosze. */
    public long fee() {
        return switch (this) {
            case CASH -> 0;
            case CARD -> 1_00;
            case PAYPAL -> 2_50;
        };
    }
}
EOF
write resources/messages.properties <<'EOF'
payment.cash=Gotowka
payment.card=Karta platnicza
payment.paypal=PayPal
EOF
commit "Add PayPal payments"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
write src/shop/PaymentMethod.java <<'EOF'
package shop;

public enum PaymentMethod {
    CASH,
    CARD,
    BLIK;

    /** Fee charged by the payment operator, in grosze. */
    public long fee() {
        return switch (this) {
            case CASH -> 0;
            case CARD -> 1_00;
            case BLIK -> 50;
        };
    }
}
EOF
write resources/messages.properties <<'EOF'
payment.cash=Gotowka
payment.card=Karta platnicza
payment.blik=BLIK
EOF
commit "Add BLIK payments"
state_set main_start "$(git rev-parse HEAD)"

setup_done
