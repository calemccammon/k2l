fun searching() {
    val s = "Hello, World, Hello"
    println(s.indexOf("Hello", 1))
    println(s.lastIndexOf("Hello"))
    println(s.indexOf('o', 5))
    println(s.indexOf("hello", ignoreCase = true))
    println(s.startsWith("World", 7))
    println(s.endsWith("HELLO", ignoreCase = true))
    println(s.contains("world", ignoreCase = true))
    println(s.indexOfAny(listOf("W", "l")))
    println(s.commonPrefixWith("Help"))
    println(s.commonSuffixWith("Yellow Hello"))
    println("abc".regionMatches(1, "xbc", 1, 2))
    println("ABC".regionMatches(0, "abc", 0, 3, ignoreCase = true))
}

fun splitting() {
    println("a,b,,c,".split(","))
    println("a,b;c".split(",", ";"))
    println("a,b,c".split(",", limit = 2))
    println("aXbxc".split("x", ignoreCase = true))
    println("a b  c".split(" "))
    println("abc".split(""))
    println("a\r\nb\nc".lines())
    println("l1\nl2".lineSequence().toList())
    println("abc".chunked(2))
    println("abcd".windowed(2))
    println("a-b-c".replaceFirst("-", "+"))
    println("aAbB".replace("a", "x", ignoreCase = true))
    println("abc".replace("", "-"))
}

fun substrings() {
    val s = "Hello, World"
    println(s.substringBefore(","))
    println(s.substringAfter(", "))
    println(s.substringBeforeLast("o"))
    println(s.substringAfterLast("o"))
    println(s.substringAfter("zz", "none"))
    println(s.take(3) + s.takeLast(3))
    println(s.drop(7) + s.dropLast(7))
    println(s.takeWhile { it != ',' })
    println(s.dropWhile { it != ',' })
    println(s.removePrefix("Hello") + s.removeSuffix("World"))
    println("[x]".removeSurrounding("[", "]"))
    println(s.removeRange(0, 7))
    println(s.replaceRange(0, 5, "Bye"))
    println(s.slice(0..4))
    println(s.substring(7))
    println(s.substring(0, 5))
    println(s.subSequence(2, 4))
    println(s.first())
    println(s.last())
    println(s.single { it == 'W' })
}

fun trimming() {
    println("[" + "  x  ".trim() + "]")
    println("[" + "xxaxx".trim('x') + "]")
    println("[" + "xxaxx".trimStart('x') + "]")
    println("[" + "xxaxx".trimEnd('x') + "]")
    println("[" + "12ab34".trim { it.isDigit() } + "]")
    println("  a\n    b".trimIndent())
    println("   |a\n   |b".trimMargin())
    println("a\nb".prependIndent(">"))
    println("7".padStart(3, '0') + "7".padEnd(3, '.'))
    println("".ifEmpty { "empty" })
    println("  ".ifBlank { "blank" })
    println("x".isNullOrEmpty())
    val n: String? = null
    println(n.isNullOrBlank())
    println(n.orEmpty().length)
}

fun transforming() {
    val s = "hello world"
    println(s.replaceFirstChar { it.uppercase() })
    println(s.split(" ").joinToString(" ") { w -> w.replaceFirstChar { it.uppercaseChar() } })
    println(s.filter { it !in "aeiou" })
    println(s.filterNot { it == 'l' })
    println(s.map { it.uppercaseChar() })
    println(s.count { it == 'o' })
    println(s.toList().distinct().size)
    println(s.groupBy { it }.mapValues { it.value.size }.filter { it.value > 1 })
    println(s.partition { it in "aeiou" })
    println(s.reversed())
    println(s.any { it == 'w' })
    println(s.all { it.isLetter() })
    println(s.toSet().size)
    println(s.toSortedSet())
    println(s.zip("abc"))
    println(s.asSequence().filter { it != ' ' }.take(3).joinToString(""))
    println(s.maxOrNull())
    println(s.indices)
    println(s.lastIndex)
    println(s.compareTo("hello"))
    println("a".compareTo("b"))
    println("b" > "a")
    println("abc".equals("ABC", ignoreCase = true))
}

fun conversions() {
    println("42".toInt() + "7".toInt())
    println("ff".toInt(16))
    println("-12".toLong())
    println("x".toIntOrNull())
    println("12".toIntOrNull())
    println("3.5".toDouble())
    println("3.5x".toDoubleOrNull())
    println("1e3".toDouble())
    println("true".toBoolean())
    println("TRUE".toBoolean())
    println("yes".toBoolean())
    println("true".toBooleanStrictOrNull())
    println("maybe".toBooleanStrictOrNull())
    println("abc".toCharArray().size)
    println(String(charArrayOf('h', 'i')))
    println("%05.1f|%-5s|%5s|%x|%c".format(3.14159, "ab", "cd", 255, 'z'))
    println(String.format("%,d", 1234567))
    println("%08.3f".format(-2.5))
    println("%e".format(12345.678))
    println("%b %s %10.4s|".format(true, null, "truncated"))
    println("%+d % d".format(5, 5))
    try {
        "abc".toInt()
    } catch (e: NumberFormatException) {
        println(e.message)
    }
    try {
        "".toDouble()
    } catch (e: NumberFormatException) {
        println(e.message)
    }
}

fun builders() {
    val sb = StringBuilder("abc")
    sb.append(1).append('x').append("yz").append(2.5)
    println(sb)
    sb.insert(0, "<<")
    println(sb)
    sb.deleteCharAt(0)
    sb.setLength(4)
    println(sb)
    sb[0] = 'Q'
    println(sb)
    println(sb.length)
    println(sb.indexOf("b"))
    println(sb.reverse())
    sb.clear()
    sb.appendLine("x").appendLine()
    println(sb.toString().length)
    println(buildString {
        for (i in 1..3) append(i).append(',')
        setLength(length - 1)
    })
}

fun main() {
    searching()
    splitting()
    substrings()
    trimming()
    transforming()
    conversions()
    builders()
}
