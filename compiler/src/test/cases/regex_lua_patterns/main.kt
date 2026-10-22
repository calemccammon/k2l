// Kotlin's Regex on Lua patterns: every construct of the supported subset (translated by the compiler, as patterns are
// compile-time constants) and the Regex, MatchResult and String functions built on string.find.

fun show(label: String, value: Any?) = println("$label: $value")

fun values(regex: Regex, input: String): List<String> = regex.findAll(input).map { it.value }.toList()

fun constructs() {
    // literal characters, with Lua's magic characters escaped
    show("magic", Regex("a\\.b\\*c\\+d\\?e\\(f\\)g\\[h]i\\\$j\\^k%l-m").matches("a.b*c+d?e(f)g[h]i\$j^k%l-m"))
    show("dot", values(Regex("a.c"), "abc a\nc a.c"))
    show("class", values(Regex("[a-c]+"), "aabbcc dd cab"))
    show("negated class", values(Regex("[^aeiou\\s]+"), "hello world"))
    show("class members", values(Regex("[\\d.,-]+"), "1,234.5 -7 x") + values(Regex("[-+*/]"), "1+2-3*4/5"))
    show("class ] and ^", values(Regex("[\\]^]+"), "a]^]b^"))
    show("\\d \\D", "${Regex("\\d+").find("ab123c")?.value} ${Regex("\\D+").find("12ab3")?.value}")
    show("\\w \\W", values(Regex("\\w+"), "snake_case, x2!") + values(Regex("\\W+"), "a, b!"))
    show("\\s \\S", "one  two\tthree".split(Regex("\\s+")) + values(Regex("\\S+"), " a bc "))
    show("\\w in a class", values(Regex("[\\w-]+"), "well-known self_made!"))
    show("^", "${Regex("^ab").containsMatchIn("abc")} ${Regex("^ab").containsMatchIn("cab")} ${values(Regex("^a"), "aaa")}")
    show("$", "${Regex("c$").containsMatchIn("abc")} ${Regex("c$").containsMatchIn("cab")} ${Regex("^$").matches("")}")
    show("?", values(Regex("colou?r"), "color colour colouur"))
    show("*", values(Regex("ab*"), "a ab abbb"))
    show("+", values(Regex("[0-9]+"), "1 22 x 333"))
    show("lazy *?", "${values(Regex("<.*?>"), "<a><bb>")} ${Regex("<.*>").find("<a><bb>")?.value}")
    show("lazy +?", "${Regex("a+?").find("aaa")?.value} ${Regex("<.+?>").find("<><a>")?.value}")
    show("{n}", Regex("\\d{4}-\\d{2}-\\d{2}").find("on 2024-03-15.")?.value)
    show("{n,m}", values(Regex("x{2,3}"), "x xx xxx xxxx"))
    show("{n,}", values(Regex("a{2,}"), "a aa aaaa"))
    show("groups", Regex("(\\w+)@(\\w+)\\.com").find("mail me@home.com")?.groupValues)
    show("nested groups", Regex("((\\w)(\\w*))!").find("hey hello!")?.groupValues)
    show("back-reference", values(Regex("(\\w)\\1"), "bookkeeper aardvark"))
    show("\\b before", Regex("\\bcat").findAll("cat concat cat's bobcat").map { it.range.first }.toList())
    show("\\b after", values(Regex("\\w+ing\\b"), "singing kingdom ring"))
    show("\\b both", values(Regex("\\b\\d+\\b"), "12 a34 56b 78"))
    show("ignore case", values(Regex("hello [a-c]+", RegexOption.IGNORE_CASE), "Hello ABC hello cab HELLO d"))
    show("ignore case class", values(Regex("[^a-z ]+", RegexOption.IGNORE_CASE), "Hi 42 there!"))
    show("(?i)", values("(?i)error".toRegex(), "Error ERROR error eRRor"))
    show("LITERAL", "${Regex.fromLiteral("a.b*").matches("a.b*")} ${Regex.fromLiteral("a.b*").matches("axbb")}")
    show("DOT_MATCHES_ALL", "${Regex("a.c", RegexOption.DOT_MATCHES_ALL).matches("a\nc")} ${Regex("a.c").matches("a\nc")}")
    show("escapes", Regex("\\t\\x41\\u0042\\n\\\\").matches("\tAB\n\\"))
    show("\\Q...\\E", Regex("\\Q1+1=2\\E!").containsMatchIn("so 1+1=2!"))
    show("non-ASCII", "${Regex("café").find("un café")?.range} ${Regex("[a-z]+").findAll("naïve").count()}")
    show("options set", Regex("a.c", setOf(RegexOption.IGNORE_CASE, RegexOption.DOT_MATCHES_ALL)).matches("A\nC"))
}

const val WORD = "\\w+"

fun constants() {
    // a pattern is a compile-time constant: a literal, a const val or a template of them
    show("const val", Regex("($WORD)@($WORD)\\.com").find("mail me@home.com")?.groupValues)
    show("const ignore case", Regex("[a-c]" + "+", RegexOption.IGNORE_CASE).find("xxABCa")?.value)
    // fromLiteral and escape also take a string known only at run time
    val star = listOf("*", "+").first()
    show("fromLiteral at run time", "${Regex.fromLiteral(star + ".").find("a**.b")?.range} ${Regex.fromLiteral("$star%").matches("*%")}")
    show("escape at run time", Regex.escape(star))
}

fun api() {
    val range = Regex("(\\d+)-(\\d+)")
    val m = range.find("range 10-20 and 3-4")!!
    show("value", m.value)
    show("range", m.range)
    show("groupValues", m.groupValues)
    val (from, to) = m.destructured
    show("destructured", "$from $to")
    show("groups", "${m.groups[1]?.value} ${m.groups.size}")
    show("next", "${m.next()?.value} ${m.next()?.next()}")
    show("matchEntire", "${Regex("(\\w+)=(\\w+)").matchEntire("key=value")?.groupValues} ${Regex("\\w+").matchEntire("a b")}")
    show("matches", "${range.matches("1-2")} ${range.matches("1-2x")} ${Regex("a*?").matches("aaa")}")
    show("containsMatchIn", "${range.containsMatchIn("x 1-2 y")} ${range.containsMatchIn("1 2")}")
    show("find from", Regex("\\d").find("a1b2", 2)?.range)
    show("findAll from", values(Regex("\\d"), "1a2b3") + Regex("\\d").findAll("1a2b3", 1).map { it.value }.toList())
    show("matchAt", "${Regex("\\d+").matchAt("ab12", 2)?.value} ${Regex("\\d+").matchesAt("ab12", 1)} ${Regex("\\bb").matchesAt("ab", 1)}")
    show("replace", Regex("(\\w+)@(\\w+)").replace("me@home you@work", "$2:$1"))
    show("replace %", Regex("(\\d+)").replace("5 and 6", "$1%"))
    show("replace escapes", Regex("\\d+").replace("cost 5", "\\\$\$0"))
    show("replace transform", Regex("\\d+").replace("a1b22") { (it.value.toInt() * 2).toString() })
    show("replace empty matches", "${Regex("x*").replace("abc", "-")} ${Regex("x*").replace("abc") { "-" }}")
    show("replaceFirst", Regex("o").replaceFirst("foo boo", "0"))
    show("split", Regex(",\\s*").split("a, b,c,,d") + Regex("\\d").split("a1b2c", limit = 2))
    show("splitToSequence", Regex("-").splitToSequence("x-y-z").toList())
    show("escape", "${Regex.escape("1+1")} ${Regex(Regex.escape("1+1")).containsMatchIn("1+1=2")}")
    show("escapeReplacement", Regex("x").replace("axb", Regex.escapeReplacement("$1\\")))
    show("pattern", "${Regex("a+b").pattern} ${Regex("a+b")}")
    for (bad in listOf("$", "\\", "$3")) {
        val e = runCatching { range.replace("1-2", bad) }.exceptionOrNull()
        println("  replacement '$bad': ${e?.let { it::class.simpleName }}")
    }
}

fun strings() {
    show("String.split", "a1b22c".split(Regex("\\d+")))
    show("String.split limit", "a b c d".split(Regex(" "), limit = 2))
    show("String.replace", "2024-03-15".replace(Regex("(\\d+)-(\\d+)-(\\d+)"), "$3/$2/$1"))
    show("String.replace transform", "a-b".replace(Regex("[a-z]")) { it.value.uppercase() })
    show("String.replaceFirst", "aaa".replaceFirst(Regex("a"), "b"))
    show("String.matches", "${"abc".matches(Regex("[a-c]+"))} ${"abd".matches(Regex("[a-c]+"))}")
    show("String.contains", "${"hello world".contains(Regex("o w"))} ${"hello".contains(Regex("\\d"))}")
    show("toRegex", "${"\\d".toRegex().findAll("1a2").count()} ${"AB".toRegex(RegexOption.IGNORE_CASE).matches("ab")}")
    // plain-string split and replace take no pattern
    show("plain", "a.b.c".split(".") + "a.b".replace(".", "%") + "x%y".split("%") + "a+b".replace("+", "$1"))
}

fun main() {
    constructs()
    constants()
    api()
    strings()
}
