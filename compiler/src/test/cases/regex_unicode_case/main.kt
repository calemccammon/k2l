fun show(pattern: String, input: String, vararg options: RegexOption): String {
    val regex = Regex(pattern, options.toSet())
    val found = regex.find(input)
    return "$pattern ~ $input: ${found?.value} at ${found?.range} matches=${regex.matches(input)} all=${regex.findAll(input).map { it.value }.toList()}"
}

fun main() {
    val ic = RegexOption.IGNORE_CASE
    // non-ASCII letters
    println(show("straße", "STRASSE", ic))
    println(show("straße", "STRAßE", ic))
    println(show("élan", "ÉLAN", ic))
    println(show("ÉLAN", "élan", ic))
    println(show("привет", "ПРИВЕТ", ic))
    println(show("ΑΣ", "ας", ic))
    println(show("ǆ", "ǅ", ic))
    println(show("ǅ", "Ǆ", ic))
    println(show("İ", "i", ic))
    println(show("ı", "I", ic))
    println(show("ſ", "S", ic))
    // letters that fold to the same one as ASCII letters
    println(show("k", "K", ic))
    println(show("K", "k", ic))
    println(show("s+", "SſsS", ic))
    // classes
    println(show("[äöü]+", "ÄÖÜäöü", ic))
    println(show("[a-z]+", "abcKELVINK", ic))
    println(show("[^é]+", "ÉéaÉ", ic))
    println(show("[k]", "K", ic))
    println(show("[K]", "K", ic))
    // ranges of non-ASCII characters
    println(show("[а-я]+", "привет мир"))
    println(show("[а-я]+", "ПРИВЕТ мир", ic))
    println(show("[^α-ω]+", "abcαβγ"))
    println(show("[a-я]+", "abcприветXYZ"))
    // quantifiers, groups and back-references
    println(show("(é)\\1", "éÉ", ic))
    println(show("(ab)\\1", "abAB", ic))
    println(show("(ab)\\1", "abAB"))
    println(show("(ß)\\1", "ßß", ic))
    println(show("(?<w>[а-я]+) \\k<w>", "слово СЛОВО", ic))
    println(show("é{2}", "éÉ", ic))
    println(show("(?:é|ü)+", "ÉüÜé", ic))
    // without the option the match is exact
    println(show("élan", "ÉLAN"))
    println(show("élan", "élan"))
    println(show("abc", "ABC"))
    // inline flags: (?i) is ASCII only in Java, (?iu) is Unicode
    println(show("(?i)élan", "ÉLAN"))
    println(show("(?i)abc", "ABC"))
    println(show("(?iu)élan", "ÉLAN"))
    println(show("(?i)k", "K"))
    println(show("(?iu)k", "K"))
    println(show("(?i:é)l", "Él"))
    println(show("(?iu:é)l", "Él"))
    // replace and split
    println(Regex("é", ic).replace("Éé", "e"))
    println(Regex("É", ic).split("aÉbéc"))
    println("ÀÉÎ".contains(Regex("àéî", ic)))
    println(Regex("ß", ic).containsMatchIn("SS"))
}
