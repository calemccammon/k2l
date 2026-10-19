// Classic string algorithms: KMP, Rabin-Karp, Z-function, Levenshtein with an edit script, longest common
// subsequence, a suffix array with LCP, Manacher's palindromes, anagram groups and StringBuilder surgery.

fun kmpTable(p: String): IntArray {
    val fail = IntArray(p.length)
    var k = 0
    for (i in 1 until p.length) {
        while (k > 0 && p[i] != p[k]) k = fail[k - 1]
        if (p[i] == p[k]) k++
        fail[i] = k
    }
    return fail
}

fun kmpSearch(text: String, p: String): List<Int> {
    val fail = kmpTable(p)
    val hits = mutableListOf<Int>()
    var k = 0
    for ((i, c) in text.withIndex()) {
        while (k > 0 && c != p[k]) k = fail[k - 1]
        if (c == p[k]) k++
        if (k == p.length) {
            hits += i - k + 1
            k = fail[k - 1]
        }
    }
    return hits
}

fun rabinKarp(text: String, p: String, base: Long = 256, mod: Long = 1_000_000_007): List<Int> {
    if (p.length > text.length) return emptyList()
    var high = 1L
    repeat(p.length - 1) { high = high * base % mod }
    var hp = 0L
    var ht = 0L
    for (i in p.indices) {
        hp = (hp * base + p[i].code) % mod
        ht = (ht * base + text[i].code) % mod
    }
    val hits = mutableListOf<Int>()
    for (i in 0..text.length - p.length) {
        if (hp == ht && text.regionMatches(i, p, 0, p.length)) hits += i
        if (i + p.length < text.length) {
            ht = ((ht - text[i].code * high % mod + mod) * base + text[i + p.length].code) % mod
        }
    }
    return hits
}

fun zFunction(s: String): IntArray {
    val z = IntArray(s.length)
    var l = 0
    var r = 0
    for (i in 1 until s.length) {
        if (i < r) z[i] = minOf(r - i, z[i - l])
        while (i + z[i] < s.length && s[z[i]] == s[i + z[i]]) z[i]++
        if (i + z[i] > r) {
            l = i
            r = i + z[i]
        }
    }
    return z
}

fun levenshtein(a: String, b: String): Pair<Int, String> {
    val d = Array(a.length + 1) { IntArray(b.length + 1) }
    for (i in 0..a.length) d[i][0] = i
    for (j in 0..b.length) d[0][j] = j
    for (i in 1..a.length) for (j in 1..b.length) {
        val cost = if (a[i - 1].equals(b[j - 1], ignoreCase = true)) 0 else 1
        d[i][j] = minOf(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost)
    }
    // walk back to an edit script: = keep, ~ substitute, - delete, + insert
    val script = StringBuilder()
    var i = a.length
    var j = b.length
    while (i > 0 || j > 0) {
        when {
            i > 0 && j > 0 && d[i][j] == d[i - 1][j - 1] + (if (a[i - 1].equals(b[j - 1], true)) 0 else 1) -> {
                script.append(if (a[i - 1].equals(b[j - 1], true)) '=' else '~'); i--; j--
            }
            i > 0 && d[i][j] == d[i - 1][j] + 1 -> { script.append('-'); i-- }
            else -> { script.append('+'); j-- }
        }
    }
    return d[a.length][b.length] to script.reverse().toString()
}

fun lcs(a: String, b: String): String {
    val dp = Array(a.length + 1) { IntArray(b.length + 1) }
    for (i in a.indices.reversed()) for (j in b.indices.reversed()) {
        dp[i][j] = if (a[i] == b[j]) dp[i + 1][j + 1] + 1 else maxOf(dp[i + 1][j], dp[i][j + 1])
    }
    val sb = StringBuilder()
    var i = 0
    var j = 0
    while (i < a.length && j < b.length) {
        when {
            a[i] == b[j] -> { sb.append(a[i]); i++; j++ }
            dp[i + 1][j] >= dp[i][j + 1] -> i++
            else -> j++
        }
    }
    return sb.toString()
}

fun suffixArray(s: String): List<Int> = s.indices.sortedWith { x, y -> s.substring(x).compareTo(s.substring(y)) }

fun lcpArray(s: String, sa: List<Int>): IntArray {
    val rank = IntArray(s.length)
    sa.forEachIndexed { i, p -> rank[p] = i }
    val lcp = IntArray(s.length)
    var h = 0
    for (i in s.indices) {
        if (rank[i] > 0) {
            val j = sa[rank[i] - 1]
            while (i + h < s.length && j + h < s.length && s[i + h] == s[j + h]) h++
            lcp[rank[i]] = h
            if (h > 0) h--
        } else {
            h = 0
        }
    }
    return lcp
}

fun longestPalindrome(s: String): String {
    val t = s.toCharArray().joinToString("#", "^#", "#$")
    val p = IntArray(t.length)
    var center = 0
    var right = 0
    for (i in 1 until t.length - 1) {
        if (i < right) p[i] = minOf(right - i, p[2 * center - i])
        while (t[i + 1 + p[i]] == t[i - 1 - p[i]]) p[i]++
        if (i + p[i] > right) {
            center = i
            right = i + p[i]
        }
    }
    val (len, c) = p.withIndex().maxBy { it.value }.let { it.value to it.index }
    val start = (c - len) / 2
    return s.substring(start, start + len)
}

fun surgery() {
    val sb = StringBuilder("Hello, World")
    sb.insert(0, ">> ").insert(sb.length, '!').insert(8, 123).insert(3, 4.5).insert(3, true)
    println(sb)
    sb.setCharAt(0, '<')
    sb.deleteCharAt(1)
    sb.delete(2, 9)
    sb.replace(0, 2, "[[").append(']').append(']')
    println("$sb len=${sb.length} idx=${sb.indexOf("o")} last=${sb.lastIndexOf("o")} char=${sb[3]} sub=${sb.substring(2, 6)}")
    sb.reverse()
    println(sb)
    sb.setLength(5)
    println("'$sb' ${sb.isEmpty()} ${sb.toString().uppercase()} ${sb.contains("d")}")
    sb.clear()
    for (i in 1..5) sb.append(i).append(if (i < 5) "," else "")
    println(sb.reversed())
    val words = "the quick brown fox jumps over the lazy dog".split(" ")
    val capitalized = words.joinToString(" ") { w -> w.replaceFirstChar { it.titlecase() } }
    println(capitalized)
    println(words.map { it.reversed() }.joinToString(" ") + " | " + words.reversed().joinToString(" "))
    println(capitalized.filter { it.isUpperCase() } + " " + capitalized.count { it.isLowerCase() } + " " + capitalized.swapCase())
}

fun String.swapCase(): String = map { if (it.isUpperCase()) it.lowercaseChar() else it.uppercaseChar() }.joinToString("")

fun main() {
    val text = "abracadabra abracadabra cadabra"
    for (p in listOf("abra", "cad", "a", "zzz", "abracadabra c")) {
        val k = kmpSearch(text, p)
        val r = rabinKarp(text, p)
        val builtin = generateSequence(text.indexOf(p)) { prev -> text.indexOf(p, prev + 1).takeIf { it >= 0 } }.takeWhile { it >= 0 }.toList()
        println("'$p': kmp=$k rk=$r same=${k == r && r == builtin}")
    }
    println("kmp table of 'aabaaab': ${kmpTable("aabaaab").joinToString()}")
    println("z of 'aaabaab': ${zFunction("aaabaab").contentToString()}")

    for ((a, b) in listOf("kitten" to "sitting", "Saturday" to "sunday", "" to "abc", "flaw" to "lawn", "same" to "SAME")) {
        val (dist, script) = levenshtein(a, b)
        println("lev('$a', '$b') = $dist  $script  lcs='${lcs(a.lowercase(), b.lowercase())}'")
    }

    val banana = "banana"
    val sa = suffixArray(banana)
    val lcp = lcpArray(banana, sa)
    sa.forEachIndexed { i, p -> println("%2d %d %-7s lcp=%d".format(i, p, banana.substring(p), lcp[i])) }
    val longestRepeat = lcp.withIndex().maxBy { it.value }.let { banana.substring(sa[it.index], sa[it.index] + it.value) }
    println("longest repeated substring: $longestRepeat")

    for (s in listOf("babad", "forgeeksskeegfor", "a", "abacdfgdcaba", "racecar level")) println("palindrome($s) = ${longestPalindrome(s)}")

    val words = listOf("listen", "silent", "enlist", "google", "gooegl", "cat", "act", "tac", "dog", "Inlets")
    val groups = words.groupBy { it.lowercase().toCharArray().sorted().joinToString("") }
    groups.filterValues { it.size > 1 }.toSortedMap().forEach { (k, v) -> println("$k -> ${v.sorted()}") }
    println(words.sortedWith(compareBy<String> { it.length }.thenByDescending { it }).joinToString())
    println(words.map { it.lowercase() }.sortedWith(String.CASE_INSENSITIVE_ORDER).distinct().chunked(4))

    surgery()
}
