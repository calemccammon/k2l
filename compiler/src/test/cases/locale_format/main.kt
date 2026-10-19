import java.util.Locale

fun line(locale: Locale, number: Double, count: Long) {
    println(
        String.format(locale, "%,d|%,.2f|%.3f|%e|%12.1f|%012d|%,15d|%-12d|", count, number, number, number, number, count, count, count),
    )
}

fun main() {
    val locales = listOf(
        Locale.US, Locale.ROOT, Locale.UK, Locale.GERMANY, Locale.FRANCE, Locale.ITALY, Locale.JAPAN, Locale.CHINA, Locale.CANADA,
        Locale.CANADA_FRENCH, Locale.KOREA, Locale("es", "ES"), Locale("es", "MX"), Locale("es", "AR"), Locale("pt", "BR"),
        Locale("pt", "PT"), Locale("ru", "RU"), Locale("pl", "PL"), Locale("sv", "SE"), Locale("nb", "NO"), Locale("da", "DK"),
        Locale("fi", "FI"), Locale("cs", "CZ"), Locale("nl", "NL"), Locale("tr", "TR"), Locale("de", "CH"), Locale("de", "AT"),
        Locale("fr", "CH"), Locale("en", "IN"), Locale("hi", "IN"), Locale("ar", "EG"), Locale("ar"), Locale("fa", "IR"),
        Locale("he", "IL"), Locale("th", "TH"), Locale("th", "TH", "TH"), Locale("bn", "BD"), Locale("mr", "IN"), Locale("my", "MM"),
        Locale("ne", "NP"), Locale("hu", "HU"), Locale("uk", "UA"), Locale("bg", "BG"), Locale("el", "GR"), Locale("id", "ID"),
        Locale("vi", "VN"), Locale("de"), Locale("fr"), Locale("xx", "YY"), Locale("zz"),
    )
    for (locale in locales) {
        print("${locale.language}_${locale.country}: ")
        line(locale, 1234567.891, 9876543210)
    }

    val de = Locale.GERMANY
    println(String.format(de, "%d", 1234567))
    println(String.format(de, "%,d", -1234567))
    println(String.format(de, "%,d", 999))
    println(String.format(de, "%,.2f", -9876.5))
    println(String.format(de, "%(,.2f", -9876.5))
    println(String.format(de, "%+,.1f", 9876.54))
    println(String.format(de, "% d", 42))
    println(String.format(de, "%08.2f", -3.14159))
    println(String.format(de, "%.0f", 2.5))
    println(String.format(de, "%#.0f", 2.5))
    println(String.format(de, "%10s|%-10s|", "ab", "cd"))
    println(String.format(de, "%x %o %X", 255, 255, 255))
    println(String.format(de, "%08x", 255))
    println(String.format(de, "%s %b %c", 1.5, true, 'x'))
    println(String.format(de, "%f %f %f", Double.NaN, Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY))
    println(String.format(de, "%e", 0.000123456))
    println(String.format(de, "%E", 123456.789))
    println(String.format(de, "%g", 0.0000123456))
    println(String.format(de, "%g", 1234.5678))
    println(String.format(de, "%.3g", 98765.4321))
    println(String.format(de, "%n").length)
    println(String.format(de, "%2\$s %1\$s", "a", "b"))
    println(String.format(de, "100%%"))
    println("%,d items".format(Locale.FRANCE, 1234567))
    println("%,.2f".format(Locale("de", "CH"), 1234567.891))
    println("%,.2f".format(Locale("hi", "IN"), 1234567.891))
    println("%,d".format(Locale("ar", "EG"), -1234567))
    println("%d%%".format(Locale.US, 50))
    println("%,d".format(Locale.ROOT, 1234567))
    println("%,d".format(null as Locale?, 1234567))
    println(String.format(null as Locale?, "%,.1f", 1234567.25))

    // the arguments of the format stay as they are
    println(String.format(de, "%s", 1234567))
    println(String.format(de, "%s %s", 1.5, listOf(1.5, 2.5)))
    println(String.format(de, "%.2f%s", 0.5, "x"))
    println(String.format(Locale("ar", "EG"), "%d-%d", 12, 34))
    println(String.format(Locale("fa"), "%.2f", 3.14159))
    println(String.format(Locale("my"), "%,d", 1234567))
    println(String.format(Locale("th", "TH", "TH"), "%,.2f", 1234567.891))

    // a locale that is not a constant
    val dynamic = listOf(Locale.GERMANY, Locale.US, Locale.FRANCE).map { String.format(it, "%,.1f", 1234567.85) }
    println(dynamic)
    val chosen = if (dynamic.size > 2) Locale("it", "IT") else Locale.US
    println(String.format(chosen, "%,d", 1234567))
}
