import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.function.Function;
import java.util.function.IntPredicate;
import java.util.function.IntUnaryOperator;

/**
 * Generates compiler/src/main/resources/dev/k2l/lualib/Unicode.lua (the character tables behind --strings utf16) and
 * UnicodeCategories.lua (the general category of every code point, for the regex classes such as \p{Lu}) from the running
 * JDK, so that classification and case mapping match what Kotlin/JVM does on that JDK. The hand-written lookup code is
 * compiler/tools/unicode_template.lua and unicode_categories_template.lua.
 *
 * Run from the repository root with a JDK 21:  java compiler/tools/GenUnicode.java
 */
public class GenUnicode {
    static final int MAX = 0x110000;

    /** Alternating run lengths (not in set, in set, not in set, ...) in base 36, comma separated. */
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

    /** The letter of each Character.getType value (0 to 30) in the category runs, as Regex.lua's CATEGORY_LETTERS. */
    static final String CATEGORY_LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ_+*/=";

    /** Runs of code points of one general category: each the run's length in base 36 (none for 1) and its category letter. */
    static String categories() {
        StringBuilder sb = new StringBuilder();
        int cp = 0;
        while (cp < MAX) {
            int type = Character.getType(cp);
            int end = cp + 1;
            while (end < MAX && Character.getType(end) == type) {
                end++;
            }
            if (end - cp > 1) {
                sb.append(Integer.toString(end - cp, 36));
            }
            sb.append(CATEGORY_LETTERS.charAt(type));
            cp = end;
        }
        return sb.toString();
    }

    /** Runs "start,count,stride,delta": count code points start, start + stride, ... each mapping to itself + delta. */
    static String mapping(IntUnaryOperator f) {
        List<String> runs = new ArrayList<>();
        int cp = 0;
        while (cp < MAX) {
            if (f.applyAsInt(cp) == cp) {
                cp++;
                continue;
            }
            int delta = f.applyAsInt(cp) - cp;
            int stride = 1;
            if (!(cp + 1 < MAX && f.applyAsInt(cp + 1) - (cp + 1) == delta) && cp + 2 < MAX
                && f.applyAsInt(cp + 2) - (cp + 2) == delta && f.applyAsInt(cp + 1) == cp + 1) {
                stride = 2;
            }
            int last = cp;
            int count = 1;
            while (last + stride < MAX && f.applyAsInt(last + stride) - (last + stride) == delta
                && (stride == 1 || f.applyAsInt(last + 1) == last + 1)) {
                last += stride;
                count++;
            }
            runs.add(Integer.toString(cp, 36) + "," + count + "," + stride + "," + delta);
            cp = last + 1;
        }
        return String.join(";", runs);
    }

    /** Code points whose full (String-level) mapping differs from the simple one: hex "cp:cp.cp". */
    static String full(IntUnaryOperator simple, Function<String, String> fullMap) {
        List<String> entries = new ArrayList<>();
        for (int cp = 0; cp < MAX; cp++) {
            if (cp >= 0xD800 && cp <= 0xDFFF) {
                continue;
            }
            String m = fullMap.apply(new String(Character.toChars(cp)));
            if (!m.equals(new String(Character.toChars(simple.applyAsInt(cp))))) {
                StringBuilder sb = new StringBuilder(Integer.toString(cp, 16)).append(':');
                m.codePoints().forEach(c -> sb.append(Integer.toString(c, 16)).append('.'));
                sb.setLength(sb.length() - 1);
                entries.add(sb.toString());
            }
        }
        return String.join(";", entries);
    }

    /** What String.toLowerCase's final-sigma rule counts as a cased letter. */
    static boolean isCased(int cp) {
        if (cp >= 0xD800 && cp <= 0xDFFF) {
            return false;
        }
        return (new String(Character.toChars(cp)) + "Σ").toLowerCase(Locale.ROOT).endsWith("ς");
    }

    public static void main(String[] args) throws IOException {
        int mark = (1 << Character.NON_SPACING_MARK) | (1 << Character.COMBINING_SPACING_MARK) | (1 << Character.ENCLOSING_MARK);
        int punct = (1 << Character.CONNECTOR_PUNCTUATION) | (1 << Character.DASH_PUNCTUATION) | (1 << Character.START_PUNCTUATION)
            | (1 << Character.END_PUNCTUATION) | (1 << Character.INITIAL_QUOTE_PUNCTUATION) | (1 << Character.FINAL_QUOTE_PUNCTUATION)
            | (1 << Character.OTHER_PUNCTUATION);
        int symbol = (1 << Character.MATH_SYMBOL) | (1 << Character.CURRENCY_SYMBOL) | (1 << Character.MODIFIER_SYMBOL)
            | (1 << Character.OTHER_SYMBOL);
        StringBuilder out = new StringBuilder();
        out.append("-- GENERATED by compiler/tools/GenUnicode.java from JDK ").append(System.getProperty("java.version"))
            .append(" (Unicode tables for --strings utf16); do not edit.\n");
        out.append("-- Sets are alternating run lengths (outside, inside, ...) in base 36; case mappings are runs of\n");
        out.append("-- start,count,stride,delta; special mappings are cp:cp.cp lists in hex.\n");
        out.append("local __K2L_Unicode = {}\n\ndo\n");
        out.append("    local sets = {\n");
        String[][] sets = {
            {"letter", ranges(Character::isLetter)},
            {"digit", ranges(Character::isDigit)},
            {"upper", ranges(Character::isUpperCase)},
            {"lower", ranges(Character::isLowerCase)},
            {"title", ranges(Character::isTitleCase)},
            {"space", ranges(cp -> Character.isWhitespace(cp) || Character.isSpaceChar(cp))},
            {"cased", ranges(GenUnicode::isCased)},
            {"mark", ranges(cp -> ((1 << Character.getType(cp)) & mark) != 0)},
            {"punct", ranges(cp -> ((1 << Character.getType(cp)) & punct) != 0)},
            {"symbol", ranges(cp -> ((1 << Character.getType(cp)) & symbol) != 0)},
        };
        for (String[] s : sets) {
            out.append("        ").append(s[0]).append(" = \"").append(s[1]).append("\",\n");
        }
        out.append("    }\n    local maps = {\n");
        out.append("        upper = \"").append(mapping(Character::toUpperCase)).append("\",\n");
        out.append("        lower = \"").append(mapping(Character::toLowerCase)).append("\",\n");
        out.append("        title = \"").append(mapping(Character::toTitleCase)).append("\",\n");
        out.append("    }\n    local special = {\n");
        out.append("        upper = \"").append(full(Character::toUpperCase, s -> s.toUpperCase(Locale.ROOT))).append("\",\n");
        out.append("        lower = \"").append(full(Character::toLowerCase, s -> s.toLowerCase(Locale.ROOT))).append("\",\n");
        out.append("    }\n\n");
        out.append(Files.readString(Path.of("compiler/tools/unicode_template.lua")));
        out.append("end\n");
        Files.writeString(Path.of("compiler/src/main/resources/dev/k2l/lualib/Unicode.lua"), out.toString());

        StringBuilder cats = new StringBuilder("-- requires: Regex\n");
        cats.append("-- GENERATED by compiler/tools/GenUnicode.java from JDK ").append(System.getProperty("java.version"))
            .append(" (general categories for --strings utf16 regexes); do not edit.\n");
        cats.append("-- Runs of code points of one category from U+0000 on: the run's length in base 36 (none for 1), then the\n");
        cats.append("-- letter of its Character.getType value in Regex.lua's CATEGORY_LETTERS.\n");
        cats.append("do\n    local runs = \"").append(categories()).append("\"\n\n");
        cats.append(Files.readString(Path.of("compiler/tools/unicode_categories_template.lua")));
        cats.append("end\n");
        Files.writeString(Path.of("compiler/src/main/resources/dev/k2l/lualib/UnicodeCategories.lua"), cats.toString());
    }
}
