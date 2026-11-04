#!/usr/bin/env bash
# Exercise 05: a conflict that cannot be resolved correctly without seeing the merge base.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 05-baza-diff3: przygotowanie piaskownicy"
new_sandbox

write src/shop/Roles.java <<'EOF'
package shop;

import java.util.Set;

public class Roles {
    public static final Set<String> CLERK = Set.of("READ");
    public static final Set<String> MANAGER = Set.of("READ", "WRITE");
    public static final Set<String> ADMIN = Set.of("READ", "WRITE", "DELETE_USERS");

    public static boolean can(Set<String> role, String permission) {
        return role.contains(permission);
    }
}
EOF
write config/limits.properties <<'EOF'
upload.max-mb=10
session.timeout-minutes=30
EOF
commit "Add roles and limits"

git checkout -q -b feature/reports
write src/shop/Roles.java <<'EOF'
package shop;

import java.util.Set;

public class Roles {
    public static final Set<String> CLERK = Set.of("READ");
    public static final Set<String> MANAGER = Set.of("READ", "WRITE", "EXPORT_REPORTS");
    public static final Set<String> ADMIN = Set.of("READ", "WRITE", "DELETE_USERS", "EXPORT_REPORTS");

    public static boolean can(Set<String> role, String permission) {
        return role.contains(permission);
    }
}
EOF
write config/limits.properties <<'EOF'
upload.max-mb=10
session.timeout-minutes=60
report.max-rows=5000
EOF
commit "Add report export permission"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
write src/shop/Roles.java <<'EOF'
package shop;

import java.util.Set;

public class Roles {
    public static final Set<String> CLERK = Set.of("READ");
    public static final Set<String> MANAGER = Set.of("READ", "WRITE");
    public static final Set<String> ADMIN = Set.of("READ", "WRITE");

    public static boolean can(Set<String> role, String permission) {
        return role.contains(permission);
    }
}
EOF
write config/limits.properties <<'EOF'
upload.max-mb=10
session.timeout-minutes=15
EOF
commit "Update roles and limits (SEC-311)"
state_set main_start "$(git rev-parse HEAD)"

setup_done
