#!/usr/bin/env bash
# Exercise 09: rebase a shared, already pushed branch onto main and push it without losing a colleague's commit.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 09-rebase-i-force-with-lease: przygotowanie piaskownicy (repo + udawany GitHub w origin.git)"
new_sandbox

write src/shop/Features.java <<'EOF'
package shop;

public class Features {
    public static final boolean NEW_CHECKOUT = false;
}
EOF
write src/shop/Products.java <<'EOF'
package shop;

import java.util.List;

public class Products {
    public static final List<String> ALL = List.of("Kubek", "Kubek termiczny", "Talerz", "Miska",
            "Lampka", "Lampa stojaca", "Dywan", "Poduszka", "Koc", "Kubek do kawy", "Kubek z nadrukiem",
            "Kubek szklany", "Kubek emaliowany", "Kubek dla dzieci", "Kubek XXL", "Kubek mini",
            "Kubek podrozny", "Kubek ceramiczny");
}
EOF
commit "Add product list and feature flags"

git checkout -q -b feature/search
as_student
write src/shop/Features.java <<'EOF'
package shop;

public class Features {
    public static final boolean NEW_CHECKOUT = false;
    public static final boolean SEARCH = true;
}
EOF
write src/shop/SearchService.java <<'EOF'
package shop;

import java.util.List;

public class SearchService {
    public static List<String> search(List<String> products, String query) {
        String q = query.toLowerCase();
        return products.stream().filter(p -> p.toLowerCase().contains(q)).toList();
    }
}
EOF
commit "Add product search by name"
write src/shop/SearchService.java <<'EOF'
package shop;

import java.util.List;

public class SearchService {
    public static final int MAX_RESULTS = 10;

    public static List<String> search(List<String> products, String query) {
        String q = query.toLowerCase();
        return products.stream().filter(p -> p.toLowerCase().contains(q)).limit(MAX_RESULTS).toList();
    }
}
EOF
commit "Limit search results to 10"
git checkout -q main

publish_to_origin main feature/search
git checkout -q feature/search
state_set student_tip "$(git rev-parse HEAD)"

# The student has not fetched since. Meanwhile Ania pushes to the same branch...
colleague "Ania Nowak" anowak <<'EOF'
git checkout -q feature/search
write src/shop/SearchService.java <<'X'
package shop;

import java.util.List;

public class SearchService {
    public static final int MAX_RESULTS = 10;

    public static List<String> search(List<String> products, String query) {
        if (query == null || query.isBlank()) {
            return List.of();
        }
        String q = query.strip().toLowerCase();
        return products.stream().filter(p -> p.toLowerCase().contains(q)).limit(MAX_RESULTS).toList();
    }
}
X
commit "Ignore blank search queries"
git push -q origin feature/search
EOF
# ...and Piotr pushes to main.
colleague "Piotr Zielinski" pzielinski <<'EOF'
write src/shop/Features.java <<'X'
package shop;

public class Features {
    public static final boolean NEW_CHECKOUT = false;
    public static final boolean RECOMMENDATIONS = true;
}
X
commit "Enable recommendations"
git push -q origin main
EOF
state_set origin_main "$(git --git-dir="$ORIGIN" rev-parse main)"
state_set ania_tip "$(git --git-dir="$ORIGIN" rev-parse feature/search)"

setup_done
