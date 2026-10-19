import java.util.Locale

var count = 0

fun show(locale: Locale) {
    count++
    println("#$count ${locale.displayLanguage} | ${locale.displayCountry} | ${locale.displayName}")
}

fun main() {
    show(Locale.US)
    show(Locale.UK)
    show(Locale.GERMANY)
    show(Locale.FRANCE)
    show(Locale.JAPAN)
    show(Locale.CHINA)
    show(Locale.CANADA)
    show(Locale.ITALIAN)
    show(Locale.KOREA)
    show(Locale.ROOT)
    show(Locale.getDefault())
    show(Locale("tr", "TR"))
    show(Locale("pt", "BR"))
    show(Locale("es", "419"))
    show(Locale("sr", "RS", "Latn"))
    show(Locale("de", "CH"))
    show(Locale("fil", "PH"))
    show(Locale("ast"))
    show(Locale("haw", "US"))
    show(Locale("xx", "YY"))
    show(Locale("", "US"))
    show(Locale("en", "US", "POSIX"))
    show(Locale("en", "", "POSIX"))
    show(Locale("ja", "JP", "JP"))
    show(Locale("th", "TH", "TH"))
    show(Locale("he"))
    show(Locale("iw", "IL"))
    show(Locale("in", "ID"))
    show(Locale("zh", "TW"))
    show(Locale("eng"))
    show(Locale.forLanguageTag("zh-Hans-CN"))
    show(Locale.forLanguageTag("zh-Hant-TW"))
    show(Locale.forLanguageTag("sr-Cyrl-RS"))
    show(Locale.forLanguageTag("az-Latn-AZ"))
    show(Locale.forLanguageTag("en-001"))
    show(Locale.forLanguageTag("ca-ES-valencia"))

    val de = Locale.GERMAN
    println(Locale.FRENCH.getDisplayLanguage(Locale.ENGLISH))
    println(Locale.FRANCE.getDisplayCountry(Locale.US))
    println(Locale.FRANCE.getDisplayName(Locale.UK))
    println(Locale.JAPAN.getDisplayName(Locale.ROOT))
    println(Locale.forLanguageTag("zh-Hans-CN").getDisplayScript())
    println(Locale.forLanguageTag("zh-Hans-CN").displayScript)
    println(Locale("en", "US", "POSIX").displayVariant)
    println(Locale.US.displayVariant.isEmpty())
    println(Locale.US.displayScript.isEmpty())
    println(de.displayLanguage)
    println(listOf(Locale.ENGLISH, Locale.GERMAN, Locale.FRENCH).map { it.displayLanguage })
    println(listOf("fr", "ja", "ru", "ar", "ko").map { Locale(it).displayLanguage }.sorted())
}
