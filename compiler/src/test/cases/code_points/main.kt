import java.util.Locale

// --strings utf16: code points, surrogates, Locale, and regex indices in UTF-16 units

fun codePoints() {
    val s = "a😀b𝄞é"
    println(s.length)
    println(s.codePointAt(0))
    println(s.codePointAt(1))
    println(s.codePointAt(2))
    println(s.codePointAt(3))
    println(s.codePointBefore(3))
    println(s.codePointCount(0, s.length))
    println(s.codePointCount(1, 3))
    println(s.offsetByCodePoints(0, 3))
    println(s.codePoints().count())
    println(s.codePoints().toArray().toList())
    println(s.chars().count())
    println(s.chars().sum())
    println(s.codePoints().boxed().toList())
    s.codePoints().forEach { println(Integer.toHexString(it)) }
    println(s.codePoints().filter { it > 0xFFFF }.count())
    println(s.codePoints().map { it + 1 }.sum())
}

fun surrogates() {
    println(Character.isSupplementaryCodePoint(0x1F600))
    println(Character.isSupplementaryCodePoint(0x41))
    println(Character.charCount(0x1F600))
    println(Character.charCount(0x41))
    val chars = Character.toChars(0x1F600)
    println(chars.size)
    println(chars[0].code)
    println(chars[1].code)
    println(String(chars))
    println(String(chars).length)
    println(Character.toChars(0x41).size)
    println('a'.isSurrogate())
    println(chars[0].isSurrogate())
    println(chars[0].isHighSurrogate())
    println(chars[0].isLowSurrogate())
    println(chars[1].isLowSurrogate())
    println(Character.isHighSurrogate(chars[0]))
    println(Character.toCodePoint(chars[0], chars[1]))
    val sb = StringBuilder()
    sb.appendCodePoint(0x1F600)
    sb.appendCodePoint(0x62)
    sb.appendCodePoint(0x1D11E)
    println(sb)
    println(sb.length)
    println(Character.isLetter('é'))
    println(Character.isLetter(0x65E5))
    println(Character.isDigit(0x663))
    println(Character.isUpperCase(0xC9))
    println(Character.toUpperCase('é'))
    println(Character.toUpperCase(0xE9))
    println(Character.toLowerCase(0x10400))
    println(Character.isWhitespace(0x2003))
    println(Character.isLetterOrDigit('_'))
    println(Character.toString(0x1F600))
    val half = "😀".substring(0, 1)
    println(half.length)
    println(half.first().isHighSurrogate())
}

fun locales() {
    println("İI".lowercase(Locale.ROOT).length)
    println("ß".uppercase(Locale.US))
    println(String.format(Locale.ROOT, "%5.1f|%d|%s", 3.14159, 42, "é"))
    println("%08.3f".format(Locale.US, 3.14159))
    println(String.format(Locale.getDefault(), "%s-%s", 1, 'x'))
}

fun regexIndices() {
    val s = "a😀b😀c"
    val emoji = Regex("😀")
    println(emoji.find(s)?.range)
    println(emoji.findAll(s).map { it.range }.toList())
    println(emoji.find(s, 2)?.range)
    println(Regex("b.").find(s)?.value)
    println(Regex("(.)(😀)").find(s)?.groups?.get(2)?.range)
    println(Regex(".").findAll(s).count())
    println(Regex("[a-c]").findAll(s).map { it.range.first }.toList())
    println(emoji.replace(s, "<>"))
    println(emoji.split(s))
    println(s.replace(Regex("[^a-z]"), "?"))
}

fun main() {
    codePoints()
    surrogates()
    locales()
    regexIndices()
}
