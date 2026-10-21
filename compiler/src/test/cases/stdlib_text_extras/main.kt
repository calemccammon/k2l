// More of kotlin.text and kotlin: replaceAfter/Before, toByte/toShort, splitToSequence, isISOControl, Charsets.UTF_8,
// decoding bytes, Boolean.and/or, lazyOf, enumValues/enumValueOf and setOfNotNull
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

enum class Level { LOW, MEDIUM, HIGH }

inline fun <reified E : Enum<E>> names(): List<String> = enumValues<E>().map { it.name }

inline fun <reified E : Enum<E>> parseOr(text: String, default: E): E = try {
    enumValueOf<E>(text)
} catch (e: IllegalArgumentException) {
    default
}

var calls = 0

fun touch(result: Boolean): Boolean {
    calls++
    return result
}

fun main() {
    val path = "dir/sub/file.tar.gz"
    t("replaceAfter") { listOf(path.replaceAfter("/", "X"), path.replaceAfter('.', "zip"), path.replaceAfter("#", "X", "none")) }
    t("replaceBefore") { listOf(path.replaceBefore("/", "root"), path.replaceBefore('#', "X")) }
    t("replaceAfterLast") { listOf(path.replaceAfterLast(".", "bz2"), path.replaceAfterLast('/', "other.txt")) }
    t("replaceBeforeLast") { listOf(path.replaceBeforeLast("/", "home"), path.replaceBeforeLast("#", "X", "missing")) }

    t("toByte") { listOf("12".toByte(), "-128".toByte(), "7f".toByte(16)) }
    t("toByte range") { "128".toByte() }
    t("toByte malformed") { "x1".toByte() }
    t("toShort") { listOf("32767".toShort(), "-5".toShort(), "ff".toShort(16)) }
    t("toShort range") { "40000".toShort() }
    t("OrNull") { listOf("100".toByteOrNull(), "300".toByteOrNull(), "x".toByteOrNull(), "-32768".toShortOrNull(), "40000".toShortOrNull()) }

    t("splitToSequence") { "a,b,,c".splitToSequence(",").filter { it.isNotEmpty() }.map { it.uppercase() }.toList() }
    t("splitToSequence chars") { "k=v;x=y".splitToSequence(';', '=').toList() }
    t("Regex.splitToSequence") { Regex("\\s+").splitToSequence("one  two three").toList() }

    t("isISOControl") { listOf('\n'.isISOControl(), '\u0000'.isISOControl(), 'a'.isISOControl(), '\u007f'.isISOControl()) }

    val bytes = "héllo".toByteArray(Charsets.UTF_8)
    t("utf8 bytes") { bytes.size }
    t("decode") { listOf(bytes.decodeToString(), String(bytes), String(bytes, Charsets.UTF_8), bytes.toString(Charsets.UTF_8)) }
    t("charset") { Charsets.UTF_8.name() }

    t("and/or") { listOf(true and false, true or false, false and touch(true), true or touch(false), calls) }
    var flags = 0
    val both = (flags++ > 5) and (flags++ > 5)
    t("both evaluated") { "$both $flags" }

    val lazy = lazyOf("ready")
    t("lazyOf") { listOf(lazy.isInitialized(), lazy.value, lazy.toString()) }

    t("enumValues") { names<Level>() }
    t("enumValueOf") { listOf(parseOr("HIGH", Level.LOW), parseOr("nope", Level.MEDIUM)) }
    t("enumValueOf direct") { enumValueOf<Level>("MEDIUM").ordinal }

    t("setOfNotNull") { listOf(setOfNotNull(1, null, 2, 1), setOfNotNull<String>(null), setOfNotNull("x")) }
}
