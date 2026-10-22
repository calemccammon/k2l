// Values typed CharSequence: strings, StringBuilders and classes of the program. Loops, length, s[i], lastIndex and
// indices use the object's own members; the text functions see its chars.

class Letters(private val n: Int) : CharSequence {
    override val length: Int get() = n

    override fun get(index: Int): Char = 'a' + index

    override fun subSequence(startIndex: Int, endIndex: Int): CharSequence = Letters(endIndex - startIndex)

    override fun toString(): String = "Letters($n)"
}

class Fixed(override val length: Int) : CharSequence {
    override fun get(index: Int): Char = if (index % 2 == 0) 'x' else 'y'

    override fun subSequence(startIndex: Int, endIndex: Int): CharSequence = Fixed(endIndex - startIndex)
}

class Wrapped(text: CharSequence) : CharSequence by text

class Holder(val text: CharSequence)

fun count(s: CharSequence, c: Char): Int {
    var n = 0
    for (x in s) if (x == c) n++
    return n
}

fun describe(s: CharSequence): String {
    val sb = StringBuilder()
    for (i in s.indices) sb.append(s[i]).append(i)
    return "$sb len=${s.length} last=${s.lastIndex} empty=${s.isEmpty()} blank=${s.isBlank()}"
}

fun maybeText(s: CharSequence?): String = "${s.isNullOrEmpty()} ${s.isNullOrBlank()} ${s?.length} ${s?.contains("b")} [$s]"

fun main() {
    val builder = StringBuilder("hello")
    val texts: List<CharSequence> = listOf("level", builder, Letters(4), Fixed(5), Wrapped(StringBuilder("lull")))
    for (t in texts) println("${count(t, 'l')} ${describe(t)}")
    val held = Holder(StringBuilder("xyz"))
    for (c in held.text) print(c.uppercaseChar())
    println()
    for ((i, c) in held.text.withIndex()) print("$i$c ")
    println()
    for (c in held.text.reversed()) print(c)
    println()
    val nullable: CharSequence? = if (texts.size > 1) builder else null
    if (nullable != null) for (c in nullable) print(c)
    println()
    // the text functions on a StringBuilder held as a CharSequence, and a StringBuilder argument
    val cs: CharSequence = builder
    println("${cs.contains("ell")} ${cs.startsWith("he")} ${cs.indexOf('l')} ${cs.first()} ${cs.last()} ${cs.count { it == 'l' }}")
    println("${"say hello".contains(builder)} ${"hello world".startsWith(builder)} ${cs.toString().uppercase()} ${cs.substring(1, 3)}")
    println("${Letters(5).contains("cd")} ${Letters(3).map { it.uppercaseChar() }} ${Letters(6).lastIndex} ${Letters(2).indices}")
    // objects stay objects where a parameter is not text
    val letters = listOf(Letters(3), Letters(1))
    println("${letters.map { it.length }} $letters")
    // a loop reads length at each step, so it sees the builder grow
    val growing = StringBuilder("ab")
    val view: CharSequence = growing
    var steps = 0
    for (c in view) {
        if (growing.length < 5) growing.append(c.uppercaseChar())
        steps++
    }
    println("$growing $steps")
    for (c in builder) print("[$c]")
    println()
    println(maybeText(null) + " " + maybeText(StringBuilder("ab")) + " " + maybeText(""))
    val any: CharSequence = builder
    println("${any == builder} ${any.equals("hello")} ${listOf<CharSequence>("a", StringBuilder("bc")).sumOf { it.length }}")
}
