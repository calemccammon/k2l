// Regexes (compile-time constants) are translated to Lua patterns at compile time: what Lua patterns cannot express is an error.

fun main() {
    val all = listOf(
        Regex("cat|dog"),
        Regex("(ab)+"),
        Regex("(?:ab)c"),
        Regex("a(?=b)"),
        Regex("(?<!x)y"),
        Regex("(?<year>\\d+)"),
        Regex("a(?i)b"),
        Regex("a??"),
        Regex("a*+"),
        Regex("\\p{Lu}"),
        Regex("\\s\\b"),
        Regex("\\B"),
        Regex("a^b"),
        Regex("a$|b"),
        Regex("[a-z&&[^e]]"),
        Regex("[\\W]"),
        Regex("[é]"),
        Regex("é+"),
        Regex("\\1(a)"),
        Regex("a{2,40}"),
        Regex("a{2,3}?"),
        Regex("x{"),
        Regex("()"),
        Regex("(unclosed"),
        Regex("\\Gx"),
        Regex("a", RegexOption.MULTILINE),
        "a|b".toRegex(),
        "(x)*".toRegex(RegexOption.IGNORE_CASE),
        Regex.fromLiteral("fine|literal"),
    )
    val m = Regex("(a)").find("a")!!
    println(m.groups[1]?.range)
    println(m.groups["name"])
    println(all.size)
    // patterns and options must be compile-time constants
    val user = listOf("x").first()
    val option = if (user.isEmpty()) RegexOption.IGNORE_CASE else RegexOption.LITERAL
    println(Regex(user))
    println("($user)+x".toRegex())
    println(Regex("a", option))
    println(Regex("a", setOf(option)))
    println(listOf("a").map(::Regex))
}
