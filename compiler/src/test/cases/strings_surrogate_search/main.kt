// Searching for one half of a surrogate pair finds it inside the pairs of the text, as on the JVM
fun mark(s: String): String = s.map {
    when {
        it.isHighSurrogate() -> "<H>"
        it.isLowSurrogate() -> "<L>"
        else -> it.toString()
    }
}.joinToString("")

fun main() {
    val high = "\uD83D"
    val low = "\uDE00"
    val s = "a😀b😀"
    println(mark(s))
    println(s.length)
    println(s.contains(high))
    println(s.contains(low))
    println(s.contains("😀"))
    println(s.contains("b" + high))
    println(s.contains(low + "b"))
    println("abc".contains(high))
    println(s.indexOf(high))
    println(s.indexOf(low))
    println(s.indexOf(low, 3))
    println(s.indexOf(high, 2))
    println(s.lastIndexOf(high))
    println(s.lastIndexOf(low))
    println(s.indexOf("😀", 2))
    println(mark(s.replace(high, "X")))
    println(mark(s.replace(low, "Y")))
    println(mark(s.replace(high, "")))
    println(mark(s.replace(low, "")))
    println(mark(s.replace(high, "").replace(low, "")))
    println(mark(s.replace(high, low)))
    println(mark(s.replace("😀", "-")))
    println(mark(s.replaceFirst(low, "Y")))
    println(s.split(high).map { mark(it) })
    println(s.split(low).map { mark(it) })
    println(s.split(high, low).map { mark(it) })
    println(s.split("b", low).map { mark(it) })
    println(s.split(low, limit = 2).map { mark(it) })
    println(s.startsWith(high, 1))
    println(s.startsWith("a" + high))
    println(s.endsWith(low))
    println(s.endsWith(high + low))
    println(s.endsWith("b" + high))
    println(s.removePrefix("a" + high).length)
    println(s.removeSuffix(high + low).length)
    println(mark(s.substringBefore(low)))
    println(mark(s.substringAfter(high)))
    println(mark(s.substringBeforeLast(high)))
    println(mark(s.substringAfterLast(low)))
    println(s.count { it == high[0] })
    println(s.indexOfFirst { it == low[0] })
    println(s.replace(Regex("b"), "!").length)
    println(Regex(high + low).findAll(s).count())
    println(mark("x$high".replace(high, "y")))
    println(mark("x$high".replace(high + "z", "y")))
    println(mark((high + low).replace(high, "[").replace(low, "]")))
    println("a,b$high,c".split(",", high).map { mark(it) })
}
