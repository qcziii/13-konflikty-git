#!/usr/bin/env bash
# Exercise 07: rebase a 3-commit feature branch onto main; conflicts in two commits.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 07-rebase-z-konfliktami: przygotowanie piaskownicy"
new_sandbox

write src/shop/Customer.java <<'EOF'
package shop;

public class Customer {
    private final String name;
    private final String email;

    public Customer(String name, String email) {
        this.name = name;
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public String toString() {
        return name + " <" + email + ">";
    }
}
EOF
commit "Add customer"

git checkout -q -b feature/loyalty-points
as_student
write src/shop/Customer.java <<'EOF'
package shop;

public class Customer {
    private final String name;
    private final String email;
    private int points;

    public Customer(String name, String email) {
        this.name = name;
        this.email = email;
        this.points = 0;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public int getPoints() {
        return points;
    }

    public void addPoints(int amount) {
        if (amount < 0) {
            throw new IllegalArgumentException("amount must not be negative");
        }
        points += amount;
    }

    @Override
    public String toString() {
        return name + " <" + email + ">";
    }
}
EOF
commit "Add loyalty points to customer"
write src/shop/LoyaltyService.java <<'EOF'
package shop;

public class LoyaltyService {
    /** One point for every full 10 zl of the order (amounts in grosze). */
    public static void award(Customer customer, long orderValue) {
        customer.addPoints((int) (orderValue / 10_00));
    }
}
EOF
commit "Add loyalty service"
sed -e 's/        return name + " <" + email + ">";/        return name + " <" + email + "> [" + points + " pkt]";/' src/shop/Customer.java > Customer.tmp && mv Customer.tmp src/shop/Customer.java
commit "Show loyalty points in customer description"
state_set feature_old_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
write src/shop/Customer.java <<'EOF'
package shop;

public class Customer {
    private final String name;
    private final String email;

    public Customer(String name, String email) {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("invalid email: " + email);
        }
        this.name = name;
        this.email = email.trim().toLowerCase();
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    @Override
    public String toString() {
        return name + " <" + email + ">";
    }
}
EOF
commit "Validate and normalize customer email"
sed -e 's/        return name + " <" + email + ">";/        return name + " (" + email + ")";/' src/shop/Customer.java > Customer.tmp && mv Customer.tmp src/shop/Customer.java
commit "Show customer as 'name (email)'"
state_set main_start "$(git rev-parse HEAD)"
git checkout -q feature/loyalty-points

setup_done
