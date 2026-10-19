import java.util.Locale

// Locale arguments are accepted (and ignored) without --strings utf16; Char classification stays ASCII
fun main() {
    println("Hello".uppercase(Locale.ROOT))
    println("Hello".lowercase(Locale.US))
    println("Hello".uppercase(Locale.getDefault()))
    println(String.format(Locale.ROOT, "%5.2f|%s", 3.14159, "x"))
    println("%d items".format(Locale.US, 3))
    println(Character.isLetter('a'))
    println(Character.toUpperCase('b'))
}
