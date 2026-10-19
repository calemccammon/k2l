import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * Rewrites the generated blocks of the two lualib files behind the locale support, from the JDK's own (CLDR) data:
 * <ul>
 * <li>LocaleNames.lua: the English display names of languages, countries, scripts and variants ({@code Locale.displayName}).
 * <li>LocaleFormat.lua: the decimal separator, grouping separator, zero digit and grouping size of every locale, which is all
 * that {@code java.util.Formatter} takes from a locale. Entries equal to what their parent locale resolves to are left out.
 * </ul>
 * The data is checked against the JDK at the end: the table must resolve to the JDK's symbols for every available locale and
 * for every language with every country.
 *
 * Run from the repository root with a JDK 21:  java compiler/tools/GenLocale.java
 */
public class GenLocale {
    static final Path LUALIB = Path.of("compiler/src/main/resources/dev/k2l/lualib");
    static final String BEGIN = "-- BEGIN GENERATED";
    static final String END = "-- END GENERATED";

    static String letters(int length, int index) {
        char[] out = new char[length];
        for (int i = length - 1; i >= 0; i--) {
            out[i] = (char) ('a' + index % 26);
            index /= 26;
        }
        return new String(out);
    }

    // ------------------------------------------------------------------ names
    static String names(String title, Map<String, String> map) {
        StringBuilder sb = new StringBuilder("        " + title + " = [==[\n");
        for (Map.Entry<String, String> e : map.entrySet()) {
            if (e.getValue().contains("\n") || e.getValue().contains("]==]")) throw new IllegalStateException(e.getValue());
            sb.append(e.getKey()).append('=').append(e.getValue()).append('\n');
        }
        return sb.append("]==],\n").toString();
    }

    @SuppressWarnings("deprecation")
    static String nameBlock() {
        Locale en = Locale.ENGLISH;
        Map<String, String> languages = new TreeMap<>();
        for (int length = 2; length <= 3; length++) {
            int count = (int) Math.pow(26, length);
            for (int i = 0; i < count; i++) {
                String code = letters(length, i);
                String name = new Locale(code).getDisplayLanguage(en);
                if (!name.equals(code)) languages.put(code, name);
            }
        }
        Map<String, String> countries = new TreeMap<>();
        for (int i = 0; i < 26 * 26; i++) {
            String code = letters(2, i).toUpperCase();
            String name = new Locale("", code).getDisplayCountry(en);
            if (!name.equals(code)) countries.put(code, name);
        }
        for (int i = 0; i < 1000; i++) {
            String code = String.format("%03d", i);
            String name = new Locale("", code).getDisplayCountry(en);
            if (!name.equals(code)) countries.put(code, name);
        }
        Map<String, String> scripts = new TreeMap<>();
        for (int i = 0; i < 26 * 26 * 26 * 26; i++) {
            String code = letters(4, i);
            code = Character.toUpperCase(code.charAt(0)) + code.substring(1);
            String name = new Locale.Builder().setScript(code).build().getDisplayScript(en);
            if (!name.equals(code)) scripts.put(code, name);
        }
        Map<String, String> variants = new TreeMap<>();
        String[] candidates = {
            "1901", "1994", "1996", "1606NICT", "1694ACAD", "1959ACAD", "ALUKU", "AREVELA", "AREVMDA", "BAKU1926", "BISKE", "BOONT",
            "FONIPA", "FONUPA", "HEPBURN", "LIPAW", "MONOTON", "NEDIS", "NJIVA", "NULIK", "OSOJS", "PINYIN", "POLYTON", "POSIX",
            "REVISED", "RIGIK", "ROZAJ", "SAAHO", "SCOTLAND", "SCOUSE", "SOLBA", "TARASK", "UCCOR", "UCRCOR", "VALENCIA", "WADEGILES",
            "JP", "TH", "NY", "BASIC", "EMODENG", "AO1990", "ABL1943", "ALALC97", "BAUDDHA", "BISCAYAN", "FONKIRSH", "FONNAPA",
            "FONXSAMP", "GRCLASS", "GRITAL", "GRMISTR", "HEPBURN", "HOGNORSK", "ITIHASA", "IVANCHOV", "JAUER", "JYUTPING", "KKCOR",
            "KSCOR", "LAUKIKA", "LEMOSIN", "LENGADOC", "LIPAW", "LUNA1918", "METELKO", "MONOTON", "NDYUKA", "NITIJA", "NORTHERN",
            "OHIO", "OXENDICT", "PAMAKA", "PETR1708", "PINYIN", "PULAAR", "PUTER", "REVISED", "RUMGR", "SURMIRAN", "SURSILV",
            "SUTSILV", "SYNNEJYL", "TAILO", "TONGYONG", "TUNUMIIT", "UNIFON", "VAIDIKA", "VALLADER", "VECDRUKA", "VIVARAUP", "WADEGILE",
        };
        for (Locale available : Locale.getAvailableLocales()) {
            if (!available.getVariant().isEmpty()) variants.put(available.getVariant().toUpperCase(), null);
        }
        for (String v : candidates) variants.put(v, null);
        for (Map.Entry<String, String> e : variants.entrySet()) {
            String name = new Locale("en", "", e.getKey()).getDisplayVariant(en);
            e.setValue(name);
        }
        variants.entrySet().removeIf(e -> e.getValue().equals(e.getKey()) || e.getValue().isEmpty());
        System.err.println("names: " + languages.size() + " languages, " + countries.size() + " countries, " + scripts.size()
            + " scripts, " + variants.size() + " variants");
        return names("languages", languages) + names("countries", countries) + names("scripts", scripts) + names("variants", variants);
    }

    // ------------------------------------------------------------------ number symbols
    record Symbols(String decimal, String group, int zero, int size) {
        String encode() {
            return decimal + group + new String(Character.toChars(zero)) + size;
        }
    }

    @SuppressWarnings("deprecation")
    static Symbols symbolsOf(Locale l) {
        DecimalFormatSymbols dfs = DecimalFormatSymbols.getInstance(l);
        NumberFormat nf = NumberFormat.getNumberInstance(l);
        int size = 3;
        if (nf instanceof DecimalFormat df) {
            size = df.isGroupingUsed() ? df.getGroupingSize() : 0;
        }
        return new Symbols(String.valueOf(dfs.getDecimalSeparator()), String.valueOf(dfs.getGroupingSeparator()), dfs.getZeroDigit(), size);
    }

    /** The tag string of a locale (see Locale.lua): language_COUNTRY_variant_#Script, without extensions. */
    static String tag(Locale l) {
        String text = l.getLanguage();
        String country = l.getCountry(), variant = l.getVariant(), script = l.getScript();
        if (!country.isEmpty() || (!text.isEmpty() && (!variant.isEmpty() || !script.isEmpty()))) text += "_" + country;
        if (!variant.isEmpty() && (!text.isEmpty())) text += "_" + variant;
        if (!script.isEmpty() && !text.isEmpty()) text += "_#" + script;
        return text;
    }

    /** The parents a tag falls back to, nearest first, as LocaleFormat.lua does. */
    static List<String> parents(String tag) {
        List<String> segments = new ArrayList<>(Arrays.asList((tag + "_").split("_", -1)));
        segments.remove(segments.size() - 1);
        String language = segments.isEmpty() ? "" : segments.get(0);
        String country = segments.size() > 1 ? segments.get(1) : "";
        String script = "";
        List<String> variants = new ArrayList<>();
        for (int i = 2; i < segments.size(); i++) {
            if (segments.get(i).startsWith("#")) script = segments.get(i); else variants.add(segments.get(i));
        }
        String variant = String.join("_", variants);
        List<String> out = new ArrayList<>();
        if (!variant.isEmpty()) out.add(join(language, country, "", script));
        if (!script.isEmpty()) {
            out.add(join(language, country, "", ""));
            if (!country.isEmpty()) out.add(join(language, "", "", script));
        }
        if (!language.isEmpty() && (!country.isEmpty() || !variant.isEmpty() || !script.isEmpty())) out.add(language);
        out.add("");
        return out;
    }

    /** Locale.of in Locale.lua: the tag string of the parts. */
    static String join(String language, String country, String variant, String script) {
        String text = language;
        if (!country.isEmpty() || (!language.isEmpty() && (!variant.isEmpty() || !script.isEmpty()))) text += "_" + country;
        if (!variant.isEmpty() && (!language.isEmpty() || !country.isEmpty())) text += "_" + variant;
        if (!script.isEmpty() && (!language.isEmpty() || !country.isEmpty())) text += "_" + script;
        return text;
    }

    static Symbols resolve(Map<String, Symbols> table, String tag) {
        Symbols s = table.get(tag);
        if (s != null) return s;
        for (String parent : parents(tag)) {
            s = table.get(parent);
            if (s != null) return s;
        }
        return table.get("");
    }

    @SuppressWarnings("deprecation")
    static String symbolBlock() {
        Map<String, Symbols> all = new TreeMap<>();
        Map<String, Locale> byTag = new TreeMap<>();
        List<Locale> available = new ArrayList<>(Arrays.asList(Locale.getAvailableLocales()));
        for (Locale l : available) {
            String tag = tag(l);
            // a locale with an extension (th_TH_TH with Thai digits) is the one the tag names
            if (all.containsKey(tag) && l.getExtensionKeys().isEmpty()) continue;
            all.put(tag, symbolsOf(l));
            byTag.put(tag, l);
        }
        all.put("", symbolsOf(Locale.ROOT));
        // keep an entry only when its parent chain does not already give the same symbols
        Map<String, Symbols> kept = new TreeMap<>();
        kept.put("", all.get(""));
        List<String> tags = new ArrayList<>(all.keySet());
        // shorter chains (parents) are decided first, so a child sees the table as the runtime will
        tags.sort((a, b) -> Integer.compare(depth(a), depth(b)));
        for (String tag : tags) {
            if (tag.isEmpty()) continue;
            Symbols inherited = null;
            for (String parent : parents(tag)) {
                inherited = kept.get(parent);
                if (inherited != null) break;
            }
            if (inherited == null) inherited = kept.get("");
            if (!all.get(tag).equals(inherited)) kept.put(tag, all.get(tag));
        }
        // every language with every country must resolve like the JDK
        TreeSet<String> languages = new TreeSet<>();
        for (Locale l : available) languages.add(l.getLanguage());
        int fixes = 0;
        for (String language : languages) {
            for (String country : Locale.getISOCountries()) {
                String tag = language.isEmpty() ? "_" + country : language + "_" + country;
                if (language.isEmpty()) continue;
                Symbols jdk = symbolsOf(new Locale(language, country));
                if (!jdk.equals(resolve(kept, tag))) {
                    kept.put(tag, jdk);
                    fixes++;
                }
            }
        }
        for (Locale l : available) {
            String tag = tag(l);
            Symbols expected = all.get(tag);
            if (!expected.equals(resolve(kept, tag))) {
                throw new IllegalStateException("table does not resolve " + tag + ": " + expected + " vs " + resolve(kept, tag));
            }
        }
        System.err.println("symbols: " + available.size() + " locales, " + kept.size() + " entries kept, " + fixes + " added for unlisted countries");
        StringBuilder sb = new StringBuilder("        symbols = [==[\n");
        for (Map.Entry<String, Symbols> e : kept.entrySet()) {
            sb.append(e.getKey()).append('=').append(e.getValue().encode()).append('\n');
        }
        return sb.append("]==],\n").toString();
    }

    static int depth(String tag) {
        return parents(tag).size() * 100 + (tag.contains("#") ? 1 : 0);
    }

    // ------------------------------------------------------------------ output
    static void splice(String file, String generated) throws Exception {
        Path path = LUALIB.resolve(file);
        String text = Files.readString(path, StandardCharsets.UTF_8);
        int begin = text.indexOf(BEGIN);
        int end = text.indexOf(END);
        if (begin < 0 || end < begin) throw new IllegalStateException(file + " has no generated block");
        int afterBegin = text.indexOf('\n', begin) + 1;
        Files.writeString(path, text.substring(0, afterBegin) + generated + "        " + text.substring(end), StandardCharsets.UTF_8);
        System.err.println("wrote " + path);
    }

    public static void main(String[] args) throws Exception {
        splice("LocaleNames.lua", nameBlock());
        splice("LocaleFormat.lua", symbolBlock());
    }
}
