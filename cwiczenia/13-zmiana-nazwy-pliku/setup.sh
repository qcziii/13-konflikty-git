#!/usr/bin/env bash
# Exercise 13: rename/rename conflict: both branches renamed the same class to different names.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 13-zmiana-nazwy-pliku: przygotowanie piaskownicy"
new_sandbox

write src/shop/Formatter.java <<'EOF'
package shop;

public class Formatter {
    /** 1234 -> "12,34" (amount in grosze). */
    public static String format(long cents) {
        return (cents / 100) + "," + String.format("%02d", cents % 100);
    }

    /** 23 -> "23%". */
    public static String formatPercent(int percent) {
        return percent + "%";
    }
}
EOF
write src/shop/Receipt.java <<'EOF'
package shop;

public class Receipt {
    public static String total(long cents) {
        return "SUMA " + Formatter.format(cents);
    }
}
EOF
commit "Add formatter"

git checkout -q -b feature/invoice
git mv src/shop/Formatter.java src/shop/MoneyFormatter.java
write src/shop/MoneyFormatter.java <<'EOF'
package shop;

public class MoneyFormatter {
    /** 1234 -> "12,34" (amount in grosze). */
    public static String format(long cents) {
        return (cents / 100) + "," + String.format("%02d", cents % 100);
    }

    /** 23 -> "23%". */
    public static String formatPercent(int percent) {
        return percent + "%";
    }

    /** 1234 -> "12,34 zł". */
    public static String formatWithCurrency(long cents) {
        return format(cents) + " zł";
    }
}
EOF
write src/shop/Receipt.java <<'EOF'
package shop;

public class Receipt {
    public static String total(long cents) {
        return "SUMA " + MoneyFormatter.format(cents);
    }
}
EOF
write src/shop/Invoice.java <<'EOF'
package shop;

public class Invoice {
    public static String line(String item, long cents, int vatRate) {
        return item + " " + MoneyFormatter.formatWithCurrency(cents) + " (VAT " + MoneyFormatter.formatPercent(vatRate) + ")";
    }
}
EOF
commit "Add invoices, rename Formatter to MoneyFormatter"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
git mv src/shop/Formatter.java src/shop/PriceFormatter.java
write src/shop/PriceFormatter.java <<'EOF'
package shop;

public class PriceFormatter {
    /** 1234 -> "12,34" (amount in grosze). */
    public static String format(long cents) {
        return (cents / 100) + "," + String.format("%02d", cents % 100);
    }

    /** 23 -> "23%". */
    public static String formatPercent(int percent) {
        return percent + "%";
    }
}
EOF
write src/shop/Receipt.java <<'EOF'
package shop;

public class Receipt {
    public static String total(long cents) {
        return "SUMA " + PriceFormatter.format(cents);
    }
}
EOF
commit "Rename Formatter to PriceFormatter (naming convention)"
state_set main_start "$(git rev-parse HEAD)"

setup_done
