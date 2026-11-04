#!/usr/bin/env bash
# Exercise 10: bring a single hotfix from the release branch to main with cherry-pick (with a conflict).
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 10-cherry-pick-poprawki: przygotowanie piaskownicy"
new_sandbox

write version.txt <<'EOF'
1.4.0
EOF
write src/shop/Vat.java <<'EOF'
package shop;

public class Vat {
    /** VAT amount in grosze for a net amount in grosze. */
    public static long vat(long net, int ratePercent) {
        return net * ratePercent / 100;
    }
}
EOF
commit "Release 1.4.0"
git branch release/1.4

as "Piotr Zielinski" pzielinski
write version.txt <<'EOF'
2.0.0-SNAPSHOT
EOF
commit "Start 2.0 development"
write src/shop/Vat.java <<'EOF'
package shop;

public class Vat {
    public static final int STANDARD_RATE = 23;

    /**
     * VAT amount for a net amount.
     *
     * @param net  net amount in grosze
     * @param rate VAT rate in percent
     */
    public static long vat(long net, int rate) {
        return net * rate / 100;
    }

    /** Gross amount (net + VAT) with the standard rate. */
    public static long gross(long net) {
        return net + vat(net, STANDARD_RATE);
    }
}
EOF
commit "Add gross() and document Vat"
state_set main_start "$(git rev-parse HEAD)"

git checkout -q release/1.4
as "Ania Nowak" anowak
write src/shop/Vat.java <<'EOF'
package shop;

public class Vat {
    /** VAT amount in grosze for a net amount in grosze. */
    public static long vat(long net, int ratePercent) {
        // round half up to a full grosz instead of truncating
        return (net * ratePercent + 50) / 100;
    }
}
EOF
commit "Fix VAT rounding: round half up instead of truncating (BUG-77)"
state_set fix "$(git rev-parse HEAD)"
write version.txt <<'EOF'
1.4.1
EOF
commit "Release 1.4.1"
state_set release_tip "$(git rev-parse HEAD)"
git checkout -q main

setup_done
