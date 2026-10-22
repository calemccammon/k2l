// Rosetta Code style tasks: roman numerals both ways, number names, look-and-say, balanced brackets,
// Luhn and ISBN checks, base conversion, run-length encoding, a hand-written calendar, and FizzBuzz variants.

fun toRoman(n: Int): String {
    require(n in 1..3999) { "out of range: $n" }
    val table = listOf(1000 to "M", 900 to "CM", 500 to "D", 400 to "CD", 100 to "C", 90 to "XC", 50 to "L", 40 to "XL",
        10 to "X", 9 to "IX", 5 to "V", 4 to "IV", 1 to "I")
    var rest = n
    return buildString {
        for ((v, s) in table) while (rest >= v) { append(s); rest -= v }
    }
}

fun fromRoman(s: String): Int {
    val values = mapOf('I' to 1, 'V' to 5, 'X' to 10, 'L' to 50, 'C' to 100, 'D' to 500, 'M' to 1000)
    return s.uppercase().map { values[it] ?: throw IllegalArgumentException("bad numeral '$it' in $s") }
        .let { v -> v.indices.sumOf { i -> if (i + 1 < v.size && v[i] < v[i + 1]) -v[i] else v[i] } }
}

private val SMALL = listOf("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven",
    "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen")
private val TENS = listOf("", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety")
private val SCALES = listOf("" to 1L, "thousand" to 1_000L, "million" to 1_000_000L, "billion" to 1_000_000_000L, "trillion" to 1_000_000_000_000L)

fun spell(n: Long): String {
    if (n < 0) return "minus " + spell(-n)
    if (n < 20) return SMALL[n.toInt()]
    if (n < 100) return TENS[(n / 10).toInt()] + if (n % 10 != 0L) "-" + SMALL[(n % 10).toInt()] else ""
    if (n < 1000) return SMALL[(n / 100).toInt()] + " hundred" + if (n % 100 != 0L) " and " + spell(n % 100) else ""
    val (name, size) = SCALES.last { it.second <= n }
    val rest = n % size
    return spell(n / size) + " " + name + when {
        rest == 0L -> ""
        rest < 100 -> " and " + spell(rest)
        else -> ", " + spell(rest)
    }
}

fun lookAndSay(s: String): String = buildString {
    var i = 0
    while (i < s.length) {
        var j = i
        while (j < s.length && s[j] == s[i]) j++
        append(j - i).append(s[i])
        i = j
    }
}

fun balanced(s: String): String {
    val pairs = mapOf(')' to '(', ']' to '[', '}' to '{', '>' to '<')
    val stack = ArrayDeque<Pair<Char, Int>>()
    for ((i, c) in s.withIndex()) {
        when (c) {
            in pairs.values -> stack.addLast(c to i)
            in pairs.keys -> {
                val top = stack.removeLastOrNull() ?: return "unexpected '$c' at $i"
                if (top.first != pairs[c]) return "mismatch '${top.first}'@${top.second} vs '$c'@$i"
            }
        }
    }
    return stack.lastOrNull()?.let { "unclosed '${it.first}' at ${it.second}" } ?: "ok"
}

fun luhn(number: String): Boolean {
    val digits = number.filter { it.isDigit() }.map { it.digitToInt() }
    if (digits.size < 2) return false
    return digits.reversed().mapIndexed { i, d -> if (i % 2 == 1) (d * 2).let { if (it > 9) it - 9 else it } else d }.sum() % 10 == 0
}

fun isbn13(s: String): Boolean {
    val d = s.replace("-", "").replace(" ", "")
    if (d.length != 13 || !d.all(Char::isDigit)) return false
    return d.mapIndexed { i, c -> c.digitToInt() * if (i % 2 == 0) 1 else 3 }.sum() % 10 == 0
}

// runs of a character (a regex would need (.)\1*, a repeated back-reference, which Lua patterns lack)
fun rle(s: String): String = buildString {
    var i = 0
    while (i < s.length) {
        var j = i
        while (j < s.length && s[j] == s[i]) j++
        append(j - i).append(s[i])
        i = j
    }
}
fun unrle(s: String): String = Regex("(\\d+)(\\D)").findAll(s).joinToString("") { it.groupValues[2].repeat(it.groupValues[1].toInt()) }

fun dayOfWeek(y: Int, m: Int, d: Int): Int {
    // Zeller's congruence, 0 = Saturday
    val (yy, mm) = if (m < 3) (y - 1) to (m + 12) else y to m
    val k = yy % 100
    val j = yy / 100
    return (d + 13 * (mm + 1) / 5 + k + k / 4 + j / 4 + 5 * j) % 7
}

fun isLeap(y: Int) = y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)

fun calendar(year: Int, month: Int): String {
    val names = listOf("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
    val days = intArrayOf(31, if (isLeap(year)) 29 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[month - 1]
    val first = (dayOfWeek(year, month, 1) + 5) % 7 // 0 = Monday
    val title = "${names[month - 1]} $year"
    val sb = StringBuilder(title.padStart((20 + title.length) / 2).padEnd(20)).append('\n').append("Mo Tu We Th Fr Sa Su\n")
    sb.append("   ".repeat(first))
    for (d in 1..days) {
        sb.append(d.toString().padStart(2))
        sb.append(if ((first + d) % 7 == 0 || d == days) "\n" else " ")
    }
    return sb.toString()
}

fun isoDate(y: Int, m: Int, d: Int, h: Int = 0, min: Int = 0) =
    "%04d-%02d-%02dT%02d:%02d".format(y, m, d, h, min) + " (" + listOf("Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri")[dayOfWeek(y, m, d)] + ")"

fun main() {
    val years = listOf(1, 4, 9, 14, 40, 90, 400, 1666, 1990, 2008, 2024, 3999)
    println(years.joinToString { "$it=${toRoman(it)}" })
    println(years.all { fromRoman(toRoman(it)) == it })
    println(listOf("mcmxc", "MMXXIV", "iv", "MDCLXVI").map(::fromRoman))
    try { fromRoman("MXQ") } catch (e: IllegalArgumentException) { println(e.message) }
    try { toRoman(0) } catch (e: IllegalArgumentException) { println(e.message) }

    for (n in listOf(0L, 7L, 13L, 42L, 100L, 101L, 999L, 1_000L, 1_001L, 12_345L, 1_000_000L, 7_654_321L, -15L, 2_147_483_648L, 1_000_000_000_001L)) {
        println("%,d: %s".format(n, spell(n)))
    }

    println(generateSequence("1", ::lookAndSay).take(10).toList())
    println(generateSequence("1", ::lookAndSay).map { it.length }.take(20).joinToString(" "))

    for (s in listOf("([]{<>})", "([)]", "((", "())", "", "{[()()]<>}x", "a(b[c]d)e}")) println("'$s' -> ${balanced(s)}")

    for (card in listOf("4539 3195 0343 6467", "8273 1232 7352 0569", "79927398713", "0", "4111-1111-1111-1111")) println("luhn($card) = ${luhn(card)}")
    for (isbn in listOf("978-0596520687", "978 1734314502", "978-1734314509", "9781788399081", "978-17883-9908")) println("isbn13($isbn) = ${isbn13(isbn)}")

    val samples = listOf(0, 1, 255, 4096, 65535, -1, 2147483647, -2147483648)
    for (n in samples) {
        println("%11d bin=%s oct=%s hex=%s b36=%s".format(n, n.toString(2), n.toString(8), n.toString(16), n.toString(36)))
    }
    println(listOf("ff" to 16, "-1010" to 2, "zz" to 36, "777" to 8, "+42" to 10, "0x1F" to 16, "12a" to 10).map { (s, r) -> s.toIntOrNull(r) })
    println("7fffffff".toLong(16) + 1 to "-8000000000000000".toLong(16) / 2)
    println(listOf("3.14", "-0.0", "1e3", ".5", "5.", "NaN", "-Infinity", "1_000", "0x10", "  7  ", "1.5f", "2d").map { it.toDoubleOrNull() }.joinToString(prefix = "[", postfix = "]") { it.toString() })
    println(listOf("42", "-0", "+7", "0042", " 1", "1e2", "2147483648", "-2147483648").map { it.toIntOrNull() })
    println(listOf(Int.MAX_VALUE.toString(), Long.MIN_VALUE.toString(), (1L shl 40).toString(), 255.toString(16).uppercase(), 10L.toString(2)))

    val text = "WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW"
    val enc = rle(text)
    println("$enc ${unrle(enc) == text} ${rle("aabcccccaaa")} ${unrle("3x2y1z")}")

    print(calendar(2024, 2))
    print(calendar(1969, 7))
    print(calendar(2023, 10))
    println(listOf(Triple(2000, 1, 1), Triple(1970, 1, 1), Triple(2024, 2, 29), Triple(1999, 12, 31)).joinToString { (y, m, d) -> isoDate(y, m, d, 23, 59) })
    println((1900..2100 step 50).map { "$it:${if (isLeap(it)) "leap" else "-"}" })

    println((1..30).joinToString(" ") { i ->
        listOf(3 to "Fizz", 5 to "Buzz", 7 to "Baxx").filter { i % it.first == 0 }.joinToString("") { it.second }.ifEmpty { i.toString() }
    })
}
