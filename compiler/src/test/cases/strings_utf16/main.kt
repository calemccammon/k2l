// --strings utf16: length, indices and chars are UTF-16 code units, as on the JVM

fun hex(s: String): String = s.map { it.code.toString(16) }.joinToString(" ")

fun lengthsAndIndexing() {
    val words = listOf("hello", "héllo", "日本語テキスト", "a😀b😀c", "éx", "")
    for (w in words) {
        println("'$w' length=${w.length} indices=${w.indices} lastIndex=${w.lastIndex} empty=${w.isEmpty()}")
    }
    val s = "a😀b"
    println(hex(s))
    println(s[0])
    println(s[2] == 'b')
    println(s[1].code)
    println(s[2].code)
    println(s.get(3))
    println(s.getOrNull(4))
    println(s.getOrNull(2))
    try {
        println(s[4])
    } catch (e: IndexOutOfBoundsException) {
        println("out of bounds")
    }
    println("日本語"[1])
    println("héllo".first())
    println("héllo".last())
    println("é".single())
    println(hex("日本語"))
    println("日本語".code0())
}

fun String.code0() = this[0].code

fun substrings() {
    val s = "héllo wörld 日本語 😀!"
    println(s.length)
    println(s.substring(1, 4))
    println(s.substring(12))
    println(s.substring(12, 15))
    println(s.substring(16, 18))
    println(hex(s.substring(16, 17)))
    println(hex(s.substring(17, 18)))
    println(s.substring(1..3))
    println(s.take(3))
    println(s.drop(12))
    println(s.takeLast(3))
    println(s.dropLast(3))
    println(s.takeWhile { it != ' ' })
    println(s.dropWhile { it != ' ' })
    println(s.takeLastWhile { it != ' ' })
    println(s.dropLastWhile { it != ' ' })
    println(s.removeRange(1, 5))
    println(s.replaceRange(0, 5, "HELLO"))
    println(s.slice(0..4))
    println(s.slice(listOf(1, 7, 13)))
    println(s.substringBefore('w'))
    println(s.substringAfter('w'))
    println(s.substringAfterLast(' '))
    println(s.removePrefix("hé"))
    println(s.removeSuffix("😀!"))
    println(s.chunked(5))
    println(s.windowed(4, 4, true))
    println(s.padStart(25, '*'))
    println(s.padEnd(25, '日'))
    println("日本".padStart(5, '-'))
    println(s.reversed())
    println("a😀b".reversed())
    println("a😀b".reversed().length)
    println("héllo".uppercase())
    try {
        s.substring(10, 40)
    } catch (e: IndexOutOfBoundsException) {
        println("substring failed")
    }
    println(s.commonPrefixWith("héllo, there"))
    println("😀a".commonPrefixWith("😁a"))
    println("a😀".commonSuffixWith("b😀"))
}

fun searching() {
    val s = "日本語 and 日本語 and 😀 and 😀"
    println(s.indexOf("日本語"))
    println(s.indexOf("日本語", 1))
    println(s.indexOf('a'))
    println(s.indexOf("and", 10))
    println(s.lastIndexOf("日本語"))
    println(s.lastIndexOf("😀"))
    println(s.lastIndexOf("and"))
    println(s.indexOf("😀"))
    println(s.indexOf("zzz"))
    println(s.contains("😀"))
    println(s.indexOfAny(listOf("and", "😀")))
    println(s.startsWith("本語", 1))
    println(s.startsWith("本語"))
    println(s.endsWith("😀"))
    println(s.replace("日本語", "X"))
    println(s.replace("and", "&"))
    println(s.split(" "))
    println("日本語".split(""))
    println("a😀".split(""))
    println("é-😀-x".split("-"))
    println(s.count { it == 'a' })
    println(s.count())
    println(s.lines())
    println(s.regionMatches(0, "日本語 x", 0, 3))
}

fun chars() {
    for (c in "aé日😀") {
        println("$c ${c.code} ${c.isSurrogate()}")
    }
    println('é'.code)
    println(Char(233))
    println(Char(0x65E5))
    println(0x65E5.toChar())
    println(('a' + 1))
    println(('é' + 1))
    println(('é' - 'a'))
    println(('日' - '本'))
    println(('a'..'e').toList())
    println(('à'..'å').toList())
    println(('à'..'å').map { it.code })
    println('é' in 'a'..'z')
    println('é' in 'a'..'ÿ')
    for (c in 'α'..'ε') print(c)
    println()
    for (c in 'ε' downTo 'α') print(c)
    println()
    var c = 'é'
    c++
    println(c)
    c--
    c--
    println(c)
    println('日'.toString() + '本')
    println("" + 'é' + '日')
    println('é' < 'z')
    println('é' > 'z')
    println('é'.compareTo('a'))
    println("é".compareTo("a"))
    println("日".compareTo("本"))
    println("abc".compareTo("abd"))
    println("a".compareTo("abc"))
}

fun builders() {
    val sb = StringBuilder("a😀b")
    println(sb.length)
    sb.insert(1, "é")
    println(sb)
    println(sb.length)
    sb.setCharAt(0, 'z')
    println(sb)
    sb.deleteCharAt(1)
    println(sb)
    sb.append('日').append("本").append(1)
    println(sb)
    println(sb.length)
    println(sb.reverse())
    println(sb[0])
    println(sb.indexOf("日"))
    println(sb.substring(1, 3))
    sb.setLength(2)
    println(sb)
    sb.delete(0, 1)
    println(sb)
    sb.replace(0, 1, "ÿÿ")
    println(sb)
    println(sb.toString().length)
    val built = buildString {
        append("é")
        append('日')
        append("😀")
        appendLine(length)
    }
    print(built)
    val parts = StringBuilder()
    val emoji = "😀"
    parts.append(emoji[0]).append(emoji[1])
    println(parts)
    println(parts.length)
    println(parts.toString() == emoji)
}

fun templatesAndConversion() {
    val s = "x😀y"
    println("${s.length} ${s[1].code} ${s.first()}${s.last()}")
    val hi = s[1]
    val lo = s[2]
    println("$hi$lo")
    println("" + hi + lo)
    println(hi.toString() + lo)
    println(("$hi$lo") == "😀")
    println(s.toCharArray().size)
    println(String(s.toCharArray()))
    println(s.toCharArray().concatToString())
    println(s.toList().size)
    println(s.map { it.code }.size)
    println(String(charArrayOf('é', '日')))
    println(s.filter { it != 'x' })
    println(s.filter { it.code < 128 })
    println(s.partition { it.code < 128 })
    println(s.map { it.toString() }.joinToString("|").length)
    println(s.zip("ab").size)
}

fun ordering() {
    // UTF-16 order: a supplementary character (surrogate D83D...) sorts before U+FFFF
    val items = listOf("￿", "😀", "z", "é", "日", "", "𝄞")
    println(items.sorted().map { hex(it) })
    println(items.sortedDescending().map { it.length })
    println("😀" < "￿")
    println("😀".compareTo("￿") < 0)
    println(items.maxOrNull()?.length)
    println(items.minOrNull()?.length)
    println("a".equals("A", ignoreCase = true))
    val map = HashMap<String, Int>()
    for ((i, w) in listOf("héllo", "日本語", "😀", "wörld", "zebra", "café", "ñandú").withIndex()) map[w] = i
    println(map)
    println(setOf("é", "日", "😀", "ab").toList())
    println(listOf("héllo", "日本語", "😀").map { it.hashCode() })
    println("é".hashCode())
    println("😀".hashCode())
    println("日本語テキスト".hashCode())
    println("".hashCode())
}

fun formatting() {
    println(String.format("%5s|%-5s|", "é", "日"))
    println(String.format("%.2s|", "日本語"))
    println("%3s|%-3s|".format("😀", "😀"))
    println("%s has %d chars".format("日本語", "日本語".length))
}

fun main() {
    lengthsAndIndexing()
    substrings()
    searching()
    chars()
    builders()
    templatesAndConversion()
    ordering()
    formatting()
}
