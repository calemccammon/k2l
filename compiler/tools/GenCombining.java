import java.text.Normalizer;
import java.util.function.IntPredicate;

/**
 * Prints the two code point sets behind the Lithuanian, Turkish and Azeri case rules of --strings utf16 (see Utf16Locale.lua):
 * the characters with canonical combining class 230 ("above") and those with any other non-zero class, as alternating run
 * lengths in base 36 (the format of Unicode.lua). The JDK has no public API for combining classes, so a class is found
 * by how the canonical ordering of NFD moves the character past probes of known class.
 *
 * Run from the repository root with a JDK 21:  java compiler/tools/GenCombining.java
 */
public class GenCombining {
    static final int MAX = 0x110000;

    static final String CCC1 = "̴";
    static final String CCC7 = "़";
    static final String CCC230 = "̀";

    static boolean swaps(String text) {
        return !Normalizer.normalize(text, Normalizer.Form.NFD).equals(text);
    }

    /** The class of a mark that does not decompose: 0 (not found), 230, or -1 for any other non-zero class. */
    static int combiningClass(int cp) {
        int type = Character.getType(cp);
        if (type != Character.NON_SPACING_MARK && type != Character.ENCLOSING_MARK && type != Character.COMBINING_SPACING_MARK) return 0;
        String x = new String(Character.toChars(cp));
        if (!Normalizer.normalize(x, Normalizer.Form.NFD).equals(x)) return 0;
        boolean above1 = swaps("a" + x + CCC1);
        boolean below7 = swaps("a" + CCC7 + x);
        if (!above1 && !below7) return 0;
        boolean above230 = swaps("a" + x + CCC230);
        boolean below230 = swaps("a" + CCC230 + x);
        return above230 || below230 ? -1 : 230;
    }

    static String ranges(IntPredicate in) {
        StringBuilder sb = new StringBuilder();
        boolean state = false;
        int run = 0;
        for (int cp = 0; cp < MAX; cp++) {
            boolean v = in.test(cp);
            if (v != state) {
                sb.append(Integer.toString(run, 36)).append(',');
                run = 0;
                state = v;
            }
            run++;
        }
        sb.append(Integer.toString(run, 36));
        return sb.toString();
    }

    public static void main(String[] args) {
        int[] classes = new int[MAX];
        for (int cp = 0; cp < MAX; cp++) classes[cp] = combiningClass(cp);
        System.out.println("above = \"" + ranges(cp -> classes[cp] == 230) + "\"");
        System.out.println("other = \"" + ranges(cp -> classes[cp] == -1) + "\"");
    }
}
