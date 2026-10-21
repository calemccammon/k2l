// Lookbehind: the lengths Java allows (bounded, and the unbounded forms it still accepts), the patterns it rejects,
// and a long input that a lookbehind scanning back to the start at every position would make quadratic.

fun show(pattern: String, input: String) {
    val regex = Regex(pattern)
    val found = regex.findAll(input).map { "${it.range.first}:${it.value}" + it.groupValues.drop(1).joinToString("") { g -> "[$g]" } }
    println("$pattern on \"$input\" -> ${found.joinToString(" ")}")
}

fun reject(pattern: String) {
    try {
        Regex(pattern)
        println("accepted $pattern")
    } catch (e: IllegalArgumentException) {
        println("${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    show("(?<=ab)c", "abc xbc abcabc c")
    show("(?<!x)y", "xy y zy yy")
    show("(?<=a|bcd)e", "ae bcde cde e")
    show("(?<!a|bcd)e", "ae bcde cde e")
    show("(?<=[a-c]{2})\\d", "ab1 a2 cc3 9")
    show("(?<=x{1,3})y", "xy xxxy y xxxxy")
    show("(?<=\\b\\w{1,3})\\.", "ab. abcd. a.b.")
    show("(?<=(a|bc)(d|ef)?)!", "ad! bcef! a! aefd! x!")
    show("(?<=(?:de){2}(f{2}))!", "dedeff! deff!")
    show("(?<=(?:ab){0,3})q", "q abq ababq")
    show("(?<=(?:x(?:y|zz)?)?)-", "x- xy- xzz- -")
    show("(?<=(?<=a)b)c", "abc bc")
    show("(?<=a+)b", "aab b xab")
    show("(?<=xa*)q", "xq xaaq q")
    show("(?<=x.+)q", "x12q q")
    show("(?<!\\d+)px", "12px apx px")
    show("(?<=a+(?:b|cd))!", "ab! aacd! cd!")
    show("(?<=^|,)\\w+", "one,two,,three")
    show("(?<=(\\w)\\w)\\b", "ab cde")
    show("(?i)(?<=AB)c", "abc aBc xbc")
    println("lookbehind replace: " + "1234567".replace(Regex("(?<=\\d)(?=(\\d{3})+$)"), ","))
    println("split: " + "aXbYc".split(Regex("(?<=[XY])")))
    reject("(?<=(a)\\1)b")
    reject("(?<!(x|yz){0,3})q")
    reject("(?<=(?:ab)*)q")
    reject("(?<=(?:a|bc)+)q")
    reject("(?<=xa+?)q")
    reject("(?<=xa++)q")
    reject("(?<=(?:a?){2})q")
    reject("(?<=(a|bc)(d|ef){1,2})!")
    reject("(?<=a+)q")
    reject("(?<=(?:a){2,})q")
    reject("(?<=(?:a|bc)?+)q")

    // a long text: every position runs the lookbehinds
    val text = "ab".repeat(20000) + "c"
    println("long (?<=a)b: " + Regex("(?<=a)b").findAll(text).count())
    println("long (?<!a)b: " + Regex("(?<!a)b").findAll(text).count())
    println("long (?<=ab{1,3})c: " + Regex("(?<=ab{1,3})c").find(text)?.range)
    println("long (?<=x|yz)c: " + Regex("(?<=x|yz)c").find(text))
    println("long (?<=[^c]{2})c: " + Regex("(?<=[^c]{2})c").find(text)?.range)
}
