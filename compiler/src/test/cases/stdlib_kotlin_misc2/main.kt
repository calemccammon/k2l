
// More of kotlin and kotlin.text: Any(), String(), AutoCloseable { }, assert, the kotlin exceptions, hashCode of enums and
// Results, primitive iterators, Appendable and hasSurrogatePairAt
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

enum class Color { RED, GREEN }

fun render(out: Appendable, items: List<Int>): Appendable {
    out.append("items:")
    for (i in items) out.append(' ').append(i.toString())
    out.appendLine()
    out.append("abcdef", 1, 3)
    out.appendLine("!")
    out.appendRange("0123456789", 7, 10)
    out.append(" and", " more")
    return out
}

fun main() {
    // Any() and String()
    val lock = Any()
    val other = Any()
    t("Any") { listOf(lock == lock, lock == other, lock.hashCode() == lock.hashCode(), lock.toString().startsWith("kotlin.Any@")) }
    t("String()") { "[" + String() + "]" }

    // AutoCloseable { }
    val log = mutableListOf<String>()
    val resource = AutoCloseable { log += "closed" }
    resource.use { log += "used" }
    t("AutoCloseable") { log }

    // assert is disabled on the JVM by default: the condition is evaluated, the message never
    var evaluated = 0
    assert(evaluated++ == 100)
    assert(false) { "never built" }
    t("assert") { evaluated }

    // hashCode of enums (identity) and Results (their value's)
    t("enum hashCode") { listOf(Color.RED.hashCode() == Color.RED.hashCode(), Color.RED.hashCode() == Color.GREEN.hashCode()) }
    t("Result hashCode") { listOf(Result.success("x").hashCode() == "x".hashCode(), Result.success(5).hashCode()) }
    val nothing: String? = null
    t("nullable hashCode") { listOf(nothing.hashCode(), "a".hashCode()) }

    // primitive iterators
    val ints = intArrayOf(1, 2).iterator()
    val chars = "xy".iterator()
    val bools = booleanArrayOf(true, false).iterator()
    val longs = longArrayOf(7L).iterator()
    val doubles = doubleArrayOf(1.5).iterator()
    t("iterators") { listOf(ints.nextInt(), ints.next(), chars.nextChar(), bools.nextBoolean(), bools.next(), longs.nextLong(), doubles.nextDouble()) }
    t("more iterators") {
        listOf(byteArrayOf(3).iterator().nextByte(), shortArrayOf(4).iterator().nextShort(), floatArrayOf(2.5f).iterator().nextFloat())
    }
    t("Char.toChar") { 'q'.toChar() }

    // Appendable
    t("Appendable") { render(StringBuilder(), listOf(1, 2, 3)).toString() }

    // unsigned hex

    // hasSurrogatePairAt: no surrogate pairs in ASCII text
    t("hasSurrogatePairAt") { listOf("abc".hasSurrogatePairAt(0), "".hasSurrogatePairAt(0)) }

}
