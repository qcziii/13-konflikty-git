#!/usr/bin/env bash
# Exercise 11: pull with uncommitted local changes; stash pop ends with a conflict.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 11-stash-pop-z-konfliktem: przygotowanie piaskownicy (repo + udawany GitHub w origin.git)"
new_sandbox

write src/shop/Pricing.java <<'EOF'
package shop;

public class Pricing {
    /** Order amount plus the service fee, in grosze. */
    public static long withService(long amount) {
        return amount + 2_00;
    }
}
EOF
write src/shop/Receipt.java <<'EOF'
package shop;

public class Receipt {
    public static String line(String item, long amount) {
        return item + ": " + Pricing.withService(amount);
    }
}
EOF
commit "Add pricing"
publish_to_origin main

colleague "Piotr Zielinski" pzielinski <<'EOF'
write src/shop/Pricing.java <<'X'
package shop;

public class Pricing {
    public static final long SERVICE_FEE = 3_00;

    /** Order amount plus the service fee, in grosze. */
    public static long withService(long amount) {
        return amount + SERVICE_FEE;
    }
}
X
commit "Raise service fee to 3 zl and extract constant"
write src/shop/Receipt.java <<'X'
package shop;

public class Receipt {
    public static String line(String item, long amount) {
        return item + ": " + Pricing.withService(amount) + " gr";
    }
}
X
commit "Show currency on receipt"
git push -q origin main
EOF
state_set origin_main "$(git --git-dir="$ORIGIN" rev-parse main)"

# The student's work in progress: not committed yet.
write src/shop/Pricing.java <<'EOF'
package shop;

public class Pricing {
    public static final long PACKAGING_FEE = 1_00;

    /** Order amount plus the service fee, in grosze. */
    public static long withService(long amount) {
        return amount + 2_00 + PACKAGING_FEE;
    }
}
EOF

setup_done
