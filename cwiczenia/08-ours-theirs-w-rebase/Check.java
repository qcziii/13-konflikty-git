import shop.*;

public class Check {
    public static void main(String[] args) {
        T.eq("formalne powitanie (feature) + przycięte imię (main)", "Dzień dobry, Ola!", () -> Greeter.greet("  Ola "));
    }
}
