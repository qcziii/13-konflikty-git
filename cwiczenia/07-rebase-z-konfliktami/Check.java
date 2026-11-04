import shop.*;

// Expected after the rebase: email validation/normalization and new toString from main + loyalty points.
public class Check {
    public static void main(String[] args) {
        T.throwsException("e-mail bez @ jest odrzucany (main)", IllegalArgumentException.class, () -> new Customer("Ala", "ala"));
        T.eq("e-mail jest normalizowany (main)", "ala@example.com", () -> new Customer("Ala", " Ala@Example.com ").getEmail());
        T.eq("nowy klient ma 0 punktów (feature)", 0, () -> new Customer("Ala", "ala@example.com").getPoints());
        T.eq("toString: 'imię (email) [N pkt]' (format z main + punkty z feature)", "Ala (ala@example.com) [12 pkt]", () -> {
            Customer c = new Customer("Ala", "ALA@example.com");
            LoyaltyService.award(c, 125_50);
            return c.toString();
        });
        T.throwsException("ujemne punkty są odrzucane (feature)", IllegalArgumentException.class,
                () -> new Customer("Ala", "ala@example.com").addPoints(-1));
    }
}
