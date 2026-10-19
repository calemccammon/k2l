// Regex.findAll is a lazy Sequence: for loops and forEach work on it, matches are searched for as they are
// pulled, and the start index is checked when findAll is called.

fun main() {
    val re = Regex("""(\w)=(\d+)""")
    val text = "a=1, b=22, c=333, d=4"
    re.findAll(text).forEach { m ->
        val (k, v) = m.destructured
        print("$k:$v ")
    }
    println()
    for (m in re.findAll(text, 6)) print("${m.value}@${m.range.first} ")
    println()
    val seen = mutableListOf<String>()
    val firstLong = re.findAll(text).onEach { seen += it.value }.first { it.groupValues[2].length >= 2 }
    println("${firstLong.value} after $seen")
    println(Regex("x*").findAll("axb").map { it.range }.toList())
    println(re.findAll(text).count() + re.findAll("").count())
    println(re.findAll(text).map { it.groupValues[2].toInt() }.filter { it > 1 }.sum())
    val matches = re.findAll(text)
    println("${matches.toList().size} ${matches.toList().size} ${matches.iterator().next().value}")
    println(runCatching { re.findAll(text, 99) }.exceptionOrNull())
    println(Regex("[aeiou]").findAll("sequence").joinToString("") { it.value.uppercase() })
}
