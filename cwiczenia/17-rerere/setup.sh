#!/usr/bin/env bash
# Exercise 17: rerere: resolve a conflict once in a trial merge, let git replay the resolution later.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 17-rerere: przygotowanie piaskownicy"
new_sandbox

write src/shop/Menu.java <<'EOF'
package shop;

import java.util.List;

public class Menu {
    public static List<String> mainItems() {
        return List.of("Start", "Produkty", "Koszyk");
    }

    public static String footer() {
        return "(c) Sklep Kursanta";
    }
}
EOF
commit "Add menu"

git checkout -q -b feature/new-menu
as_student
write src/shop/Menu.java <<'EOF'
package shop;

import java.util.List;

public class Menu {
    public static List<String> mainItems() {
        return List.of("Start", "Kategorie", "Produkty", "Koszyk", "Pomoc");
    }

    public static String footer() {
        return "(c) Sklep Kursanta | Regulamin | Kontakt";
    }
}
EOF
commit "New menu: categories, help, footer links"
write src/shop/Help.java <<'EOF'
package shop;

public class Help {
    public static String text() {
        return "Masz pytanie? Napisz do nas.";
    }
}
EOF
commit "Add help page"

git checkout -q main
as "Piotr Zielinski" pzielinski
write src/shop/Menu.java <<'EOF'
package shop;

import java.util.List;

public class Menu {
    public static List<String> mainItems() {
        return List.of("Start", "Produkty", "Promocje", "Koszyk");
    }

    public static String footer() {
        return "(c) 2026 Sklep Kursanta";
    }
}
EOF
commit "Add promotions to menu, year in footer"
state_set main_start "$(git rev-parse HEAD)"

setup_done
