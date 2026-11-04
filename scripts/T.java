import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Objects;
import java.util.function.BooleanSupplier;
import java.util.function.Supplier;

// Tiny test helper used by the Check.java files of the exercises.
// Prints one line per test: OK|name or FAIL|name|message (read by scripts/lib.sh).
public final class T {
    private T() {
    }

    public static void eq(String name, Object expected, Supplier<Object> actual) {
        try {
            Object a = actual.get();
            if (Objects.equals(expected, a)) {
                ok(name);
            } else {
                fail(name, "oczekiwano: " + expected + ", jest: " + a);
            }
        } catch (Throwable t) {
            fail(name, "wyjątek " + t);
        }
    }

    public static void that(String name, BooleanSupplier condition, String messageIfFalse) {
        try {
            if (condition.getAsBoolean()) {
                ok(name);
            } else {
                fail(name, messageIfFalse);
            }
        } catch (Throwable t) {
            fail(name, "wyjątek " + t);
        }
    }

    public static void throwsException(String name, Class<? extends Throwable> type, Runnable code) {
        try {
            code.run();
            fail(name, "oczekiwano wyjątku " + type.getSimpleName() + ", a nic nie poleciało");
        } catch (Throwable t) {
            if (type.isInstance(t)) {
                ok(name);
            } else {
                fail(name, "oczekiwano " + type.getSimpleName() + ", poleciało " + t);
            }
        }
    }

    /** Content of a file of the checked tree, or null when it does not exist. */
    public static String file(String path) {
        try {
            Path p = Path.of(path);
            return Files.exists(p) ? Files.readString(p) : null;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static void ok(String name) {
        System.out.println("OK|" + name);
    }

    public static void fail(String name, String message) {
        System.out.println("FAIL|" + name + "|" + message.replace('\n', ' ').replace('|', '/'));
    }
}
