import java.util.Set;
import java.util.TreeSet;
import shop.*;

// Expected after the merge: main removed DELETE_USERS from ADMIN (security fix),
// feature added EXPORT_REPORTS to MANAGER and ADMIN. Both intentions must survive.
public class Check {
    public static void main(String[] args) {
        T.eq("ADMIN: READ, WRITE, EXPORT_REPORTS (bez DELETE_USERS!)",
                new TreeSet<>(Set.of("READ", "WRITE", "EXPORT_REPORTS")), () -> new TreeSet<>(Roles.ADMIN));
        T.eq("MANAGER: READ, WRITE, EXPORT_REPORTS", new TreeSet<>(Set.of("READ", "WRITE", "EXPORT_REPORTS")),
                () -> new TreeSet<>(Roles.MANAGER));
        T.eq("CLERK bez zmian", Set.of("READ"), () -> Roles.CLERK);
        String limits = T.file("config/limits.properties");
        T.that("session.timeout-minutes=15 (main skrócił z 30, feature wydłużył do 60: wygrywa bezpieczeństwo, patrz ZADANIE)",
                () -> limits.lines().anyMatch("session.timeout-minutes=15"::equals), "inna wartość albo brak");
        T.that("report.max-rows=5000 (z feature)", () -> limits.lines().anyMatch("report.max-rows=5000"::equals), "brak");
        T.that("upload.max-mb=10 (bez zmian)", () -> limits.lines().anyMatch("upload.max-mb=10"::equals), "brak");
    }
}
