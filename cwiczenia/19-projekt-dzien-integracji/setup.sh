#!/usr/bin/env bash
# Exercise 19 (project): integration day: merge three pull requests into main, in order.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 19-projekt-dzien-integracji: przygotowanie piaskownicy"
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
write CHANGELOG.md <<'EOF'
# Changelog

## Unreleased

## 1.0.0
- First release
EOF
write src/shop/Order.java <<'EOF'
package shop;

import java.util.List;

public record Order(String id, List<Line> lines) {
    public record Line(String sku, int quantity, long unitPrice) {
    }

    /** Total in grosze. */
    public long total() {
        return lines.stream().mapToLong(l -> l.quantity() * l.unitPrice()).sum();
    }
}
EOF
write src/shop/OrderService.java <<'EOF'
package shop;

public class OrderService {
    public String place(Order order) {
        long total = order.total();
        return Notifications.confirmation(order.id(), total);
    }
}
EOF
write src/shop/Notifications.java <<'EOF'
package shop;

public class Notifications {
    public static String confirmation(String orderId, long total) {
        return "Zamowienie " + orderId + " przyjete, do zaplaty " + total + " gr";
    }
}
EOF
commit "Release 1.0.0"
base=$(git rev-parse HEAD)

# PR 1: newsletter
git checkout -q -b feature/newsletter
as "Ola Wisniewska" owisniewska
write src/shop/Newsletter.java <<'EOF'
package shop;

import java.util.LinkedHashSet;
import java.util.Set;

public class Newsletter {
    private final Set<String> subscribers = new LinkedHashSet<>();

    public boolean subscribe(String email) {
        return subscribers.add(email.strip().toLowerCase());
    }

    public int count() {
        return subscribers.size();
    }
}
EOF
sed -e 's/^## Unreleased$/## Unreleased\
- Newsletter signup/' CHANGELOG.md > c.tmp && mv c.tmp CHANGELOG.md
commit "Add newsletter signup"
state_set pr1 "$(git rev-parse HEAD)"

# PR 2: Money type
git checkout -q -b feature/money-type "$base"
as "Piotr Zielinski" pzielinski
write src/shop/Money.java <<'EOF'
package shop;

/** Amount of money in grosze. */
public record Money(long grosze) {
    public Money plus(Money other) {
        return new Money(grosze + other.grosze);
    }

    public Money minus(Money other) {
        return new Money(grosze - other.grosze);
    }

    /** 4500 -> "45,00 zl". */
    public String format() {
        return grosze / 100 + "," + String.format("%02d", Math.abs(grosze % 100)) + " zl";
    }
}
EOF
write src/shop/Order.java <<'EOF'
package shop;

import java.util.List;

public record Order(String id, List<Line> lines) {
    public record Line(String sku, int quantity, long unitPrice) {
    }

    public Money total() {
        return new Money(lines.stream().mapToLong(l -> l.quantity() * l.unitPrice()).sum());
    }
}
EOF
write src/shop/OrderService.java <<'EOF'
package shop;

public class OrderService {
    public String place(Order order) {
        Money total = order.total();
        return Notifications.confirmation(order.id(), total);
    }
}
EOF
write src/shop/Notifications.java <<'EOF'
package shop;

public class Notifications {
    public static String confirmation(String orderId, Money total) {
        return "Zamowienie " + orderId + " przyjete, do zaplaty " + total.format();
    }
}
EOF
sed -e 's/^## Unreleased$/## Unreleased\
- Money type for amounts/' CHANGELOG.md > c.tmp && mv c.tmp CHANGELOG.md
commit "Introduce Money type for amounts"
state_set pr2 "$(git rev-parse HEAD)"

# PR 3: coupons
git checkout -q -b feature/coupons "$base"
as "Ania Nowak" anowak
write src/shop/Coupons.java <<'EOF'
package shop;

public class Coupons {
    /** Discount for the coupon code, in grosze (0 for unknown or missing codes). */
    public static long discount(String code) {
        if ("RABAT5".equals(code)) {
            return 5_00;
        }
        return 0;
    }
}
EOF
write src/shop/OrderService.java <<'EOF'
package shop;

public class OrderService {
    public String place(Order order) {
        return place(order, null);
    }

    public String place(Order order, String couponCode) {
        long total = order.total() - Coupons.discount(couponCode);
        return "Zamowienie " + order.id() + " przyjete, do zaplaty " + total + " gr";
    }
}
EOF
git rm -q src/shop/Notifications.java
sed -e 's/^## Unreleased$/## Unreleased\
- Discount coupons/' CHANGELOG.md > c.tmp && mv c.tmp CHANGELOG.md
commit "Add discount coupons, inline order confirmation (remove Notifications)"
state_set pr3 "$(git rev-parse HEAD)"

git checkout -q main
state_set main_start "$(git rev-parse HEAD)"

setup_done
