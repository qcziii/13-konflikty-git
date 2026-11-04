#!/usr/bin/env bash
# Exercise 14: main reformatted the whole code (tabs -> spaces), feature changed a few lines.
EX_DIR=$(cd "$(dirname "$0")" && pwd)
source "$EX_DIR/../../scripts/lib.sh"
echo "Ćwiczenie 14-formatowanie-calego-pliku: przygotowanie piaskownicy"
new_sandbox

TAB=$(printf '\t')
write format.sh <<'EOF'
#!/usr/bin/env bash
# Team formatter: replaces leading tabs with 4 spaces in all Java files (src/).
cd "$(dirname "$0")" || exit 1
for f in $(find src -name '*.java'); do
  awk '{ while (match($0, /^ *\t/)) { $0 = substr($0, 1, RLENGTH - 1) "    " substr($0, RLENGTH + 1) } print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "formatted"
EOF
chmod +x format.sh
# Code written with tabs (the old convention).
write src/shop/Tax.java <<EOF
package shop;

public class Tax {
${TAB}public static final int STANDARD_RATE = 22;
${TAB}public static final int REDUCED_RATE = 7;

${TAB}/** VAT in grosze, rounded half up. */
${TAB}public static long vat(long net, int rate) {
${TAB}${TAB}return (net * rate + 50) / 100;
${TAB}}

${TAB}public static long gross(long net) {
${TAB}${TAB}return net + vat(net, STANDARD_RATE);
${TAB}}

${TAB}public static long grossReduced(long net) {
${TAB}${TAB}return net + vat(net, REDUCED_RATE);
${TAB}}

${TAB}public static boolean isValidRate(int rate) {
${TAB}${TAB}if (rate < 0) {
${TAB}${TAB}${TAB}return false;
${TAB}${TAB}}
${TAB}${TAB}return rate <= 100;
${TAB}}
}
EOF
write src/shop/Invoice.java <<EOF
package shop;

public class Invoice {
${TAB}public static String summary(long net) {
${TAB}${TAB}long vat = Tax.vat(net, Tax.STANDARD_RATE);
${TAB}${TAB}return "netto " + net + ", VAT " + vat + ", brutto " + (net + vat);
${TAB}}
}
EOF
commit "Add tax calculations"

git checkout -q -b feature/new-rates
as_student
sed -e 's/STANDARD_RATE = 22;/STANDARD_RATE = 23;/' -e 's/REDUCED_RATE = 7;/REDUCED_RATE = 8;/' src/shop/Tax.java > t.tmp && mv t.tmp src/shop/Tax.java
commit "Update VAT rates to 23% and 8%"
write src/shop/Tax.java <<EOF
package shop;

public class Tax {
${TAB}public static final int STANDARD_RATE = 23;
${TAB}public static final int REDUCED_RATE = 8;
${TAB}public static final int ZERO_RATE = 0;

${TAB}/** VAT in grosze, rounded half up. */
${TAB}public static long vat(long net, int rate) {
${TAB}${TAB}return (net * rate + 50) / 100;
${TAB}}

${TAB}public static long gross(long net) {
${TAB}${TAB}return net + vat(net, STANDARD_RATE);
${TAB}}

${TAB}public static long grossReduced(long net) {
${TAB}${TAB}return net + vat(net, REDUCED_RATE);
${TAB}}

${TAB}public static boolean isValidRate(int rate) {
${TAB}${TAB}if (rate < 0) {
${TAB}${TAB}${TAB}return false;
${TAB}${TAB}}
${TAB}${TAB}return rate == ZERO_RATE || rate == REDUCED_RATE || rate == STANDARD_RATE || rate == 5;
${TAB}}
}
EOF
commit "Accept only legal VAT rates"
state_set feature_tip "$(git rev-parse HEAD)"

git checkout -q main
as "Piotr Zielinski" pzielinski
./format.sh > /dev/null
commit "Reformat code: 4 spaces instead of tabs (no functional changes)"
state_set main_start "$(git rev-parse HEAD)"

setup_done
