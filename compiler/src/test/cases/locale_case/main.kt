import java.util.Locale

fun hex(s: String) = s.map { it.code.toString(16) }.joinToString(" ")

fun main() {
    val tr = Locale("tr")
    val trTR = Locale("tr", "TR")
    val az = Locale.forLanguageTag("az-Latn-AZ")
    val lt = Locale("LT", "lt")
    val others = listOf(Locale.ROOT, Locale.ENGLISH, Locale.US, Locale.GERMANY, Locale("el"), Locale.FRANCE)

    // Turkish and Azeri: dotted and dotless i
    println("Iİıi".uppercase(tr))
    println("Iİıi".lowercase(trTR))
    println("TITLE İSTANBUL".lowercase(tr))
    println("title istanbul".uppercase(az))
    println(hex("İx".lowercase(tr)))
    println(hex("IỊ̇".lowercase(tr)))
    println(hex("Ị̇".lowercase(trTR)))
    println(hex("Í̇".lowercase(tr)))
    println(hex("̇".lowercase(tr)))
    println(hex("Iß".uppercase(tr)))
    println(hex("ıÇ".uppercase(tr)))

    // the other locales are the root rules
    for (locale in others) {
        println(hex("Iİıi".lowercase(locale)) + " | " + hex("Iİıi".uppercase(locale)))
    }

    // Lithuanian
    println(hex("Ì".lowercase(lt)))
    println(hex("J́x".lowercase(lt)))
    println(hex("Į̃".lowercase(lt)))
    println(hex("Ix".lowercase(lt)))
    println(hex("Ì̖".lowercase(lt)))
    println(hex("Ị".lowercase(lt)))
    println(hex("ÌÍĨ".lowercase(lt)))
    println(hex("i̇".uppercase(lt)))
    println(hex("j̣̇".uppercase(lt)))
    println(hex("̇".uppercase(lt)))
    println(hex("ȧ".uppercase(lt)))
    println(hex("i̇".uppercase(Locale.ROOT)))

    // Σ and İ: the final sigma and the root mapping of İ are unchanged by the locale
    println(hex("ΑΣ ΣΑΣ".lowercase(tr)))
    println(hex("İ".lowercase(Locale.ROOT)))
    println(hex("İ".lowercase(tr)))

    // Char.titlecase
    println("istanbul".replaceFirstChar { it.titlecase(tr) })
    println("istanbul".replaceFirstChar { it.titlecase(Locale.ENGLISH) })
    println('ǆ'.titlecase(Locale.ROOT))
    for (c in listOf('i', 'I', 'ı', 'İ', 'ß', 'ŉ', 'ǆ', 'a', 'ǰ')) {
        println("$c ${hex(c.titlecase(tr))} ${hex(c.titlecase(lt))} ${hex(c.titlecase(Locale.ROOT))} ${hex(c.titlecase())}")
    }

    // Locale values
    println(tr.language + " " + trTR.country + " " + trTR + " " + lt + " " + az)
    println(Locale.ROOT.toLanguageTag() + " " + trTR.toLanguageTag() + " " + Locale("", "US").toLanguageTag())
    println(Locale.forLanguageTag("de-CH-1996").toString() + " " + Locale.forLanguageTag("und") + "|")
    println(Locale("en", "us", "posix").variant)
    println(Locale.getDefault().language.length)
    println(tr == Locale("TR") && tr != trTR && trTR == Locale("tr", "tr"))
}
