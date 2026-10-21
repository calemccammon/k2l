// Lookbehind over characters of several UTF-8 bytes, with UTF-16 indices: the bounds are in bytes, so a class or `.`
// of one character may span up to four of them.

fun show(pattern: String, input: String) {
    val found = Regex(pattern).findAll(input).map { "${it.range.first}:${it.value}" }
    println("$pattern on \"$input\" -> ${found.joinToString(" ")}")
}

fun main() {
    show("(?<=é)x", "éx ex")
    show("(?<=[éa]{2})x", "aéx éx ééx")
    show("(?<=.)\\.", ".a.é.😀.")
    show("(?<=😀)!", "😀! !")
    show("(?<=[^a]{1,2})!", "😀😀! a!")
    show("(?<!\\p{L})\\d", "é1 2 x3")
    show("(?iu)(?<=k)x", "Kx kx Kx")
    show("(?<=ü+)z", "üüz z")
    try {
        Regex("(?<=é(a)\\1)b")
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    val text = "éb".repeat(10000)
    println("long (?<=é)b: " + Regex("(?<=é)b").findAll(text).count())
    println("long (?<![^é])b: " + Regex("(?<![^é])b").findAll(text).count())
}
