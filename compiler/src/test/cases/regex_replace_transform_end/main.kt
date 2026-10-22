// Regex.replace with a transform stops once a match reaches the end of the input, so a pattern that also matches the
// empty string gets no empty match there; replace with a replacement string does get one.

fun main() {
    println(Regex("x*").replace("abc") { "-" })
    println(Regex("c*").replace("abc") { "-" })
    println(Regex("c*").replace("abc", "-"))
    println(Regex("[0-9.]*").replace("1.0") { "<${it.value}>" })
    println(Regex("[0-9.]*").replace("1.0", "<$0>"))
    println("".replace(Regex("a*")) { "!" })
    println("a1b22".replace(Regex("\\d*")) { "[${it.value}]" })
    println("a1b22".replace(Regex("\\d*"), "[$0]"))
    println(Regex("\\d*").replaceFirst("22b", "#"))
    // optional items only: the whole input in one match, nothing after it
    val range = Regex("([\\[(]?)\\s*(\\d*)\\s*(,?)\\s*(\\d*)\\s*([\\])]?)")
    val parts = mutableListOf<String>()
    val rest = range.replace("[1,2)") { m ->
        parts += m.groupValues.drop(1).joinToString("|")
        ""
    }
    println("$parts '$rest'")
}
