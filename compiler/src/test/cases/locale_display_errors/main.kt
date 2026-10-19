import java.util.Locale

fun main() {
    println(Locale.FRANCE.getDisplayLanguage(Locale.ENGLISH))
    println(Locale.FRANCE.getDisplayLanguage(Locale.US))
    println(Locale.FRANCE.getDisplayCountry(Locale.GERMAN))
    println(Locale.FRANCE.getDisplayName(Locale.FRANCE))
    println(Locale.FRANCE.getDisplayName(Locale.JAPAN))
}
