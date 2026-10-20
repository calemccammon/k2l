// The kotlin.text functions of CharSequence called on a StringBuilder work on its current text.

fun main() {
    val sb = StringBuilder()
    for (i in 1..4) sb.append(i).append(", ")
    println("[${sb.removeSuffix(", ")}] [${sb.removePrefix("1, ")}] [${sb.trim()}] [${sb.trimEnd(',', ' ')}]")
    println("${sb.startsWith("1")} ${sb.endsWith(", ")} ${sb.contains("3,")} ${sb.count { it == ',' }} ${sb.isBlank()} ${sb.any { it.isDigit() }}")
    println(sb.split(", ").filter { it.isNotEmpty() }.map { it.toInt() * 10 })
    val text = StringBuilder().appendLine("alpha").appendLine("beta").append("gamma")
    println("${text.lines()} ${text.padStart(20, '.').length} ${text.indexOf("beta")} ${text.filter { it != 'a' }}")
    println("${text.first()} ${text.last()} ${text.substring(0, 5)} ${text.reversed()} ${text.toString().uppercase()}")
    // buildString with a capacity hint
    println(buildString(4) { append("cap"); append(4); repeat(3) { append('!') } } + buildString(0) {})
}
