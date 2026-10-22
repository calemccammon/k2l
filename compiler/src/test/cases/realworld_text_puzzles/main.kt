// Small text-processing puzzles of the kind found in programming-puzzle calendars, with made-up inputs: word rules,
// password policies, record validation, bracketed address checks, bracket matching and scoring, crate stacks, a
// stream with groups and garbage, string escapes, password increments and digits spelled out in words.

fun niceOld(s: String) = s.count { it in "aeiou" } >= 3 && s.zipWithNext().any { (a, b) -> a == b } &&
    listOf("ab", "cd", "pq", "xy").none { it in s }

fun niceNew(s: String) = Regex("(..).*\\1").containsMatchIn(s) && Regex("(.).\\1").containsMatchIn(s)

fun passwordPolicies(lines: List<String>): Pair<Int, Int> {
    val re = Regex("""(\d+)-(\d+) (\w): (\w+)""")
    var a = 0
    var b = 0
    for (line in lines) {
        val (lo, hi, ch, pw) = re.matchEntire(line)!!.destructured
        val c = ch.single()
        if (pw.count { it == c } in lo.toInt()..hi.toInt()) a++
        if ((pw.getOrNull(lo.toInt() - 1) == c) xor (pw.getOrNull(hi.toInt() - 1) == c)) b++
    }
    return a to b
}

fun validPassport(fields: Map<String, String>): Boolean {
    val rules: Map<String, (String) -> Boolean> = mapOf(
        "byr" to { v -> v.toIntOrNull() in 1920..2002 },
        "iyr" to { v -> v.toIntOrNull() in 2010..2020 },
        "eyr" to { v -> v.toIntOrNull() in 2020..2030 },
        "hgt" to { v ->
            Regex("(\\d+)([a-z]+)").matchEntire(v)?.destructured?.let { (n, u) ->
                when (u) {
                    "cm" -> n.toInt() in 150..193
                    "in" -> n.toInt() in 59..76
                    else -> false
                }
            } ?: false
        },
        "hcl" to { v -> v.matches(Regex("#[0-9a-f]{6}")) },
        "ecl" to { v -> v in setOf("amb", "blu", "brn", "gry", "grn", "hzl", "oth") },
        "pid" to { v -> v.length == 9 && v.all(Char::isDigit) },
    )
    return rules.all { (k, ok) -> fields[k]?.let(ok) ?: false }
}

fun supportsTls(ip: String): Boolean {
    fun abba(s: String) = s.windowed(4).any { it[0] == it[3] && it[1] == it[2] && it[0] != it[1] }
    val parts = ip.split('[', ']')
    val outside = parts.filterIndexed { i, _ -> i % 2 == 0 }
    val inside = parts.filterIndexed { i, _ -> i % 2 == 1 }
    return outside.any(::abba) && inside.none(::abba)
}

fun syntaxScore(lines: List<String>): Pair<Int, Long> {
    val close = mapOf('(' to ')', '[' to ']', '{' to '}', '<' to '>')
    val errorPoints = mapOf(')' to 3, ']' to 57, '}' to 1197, '>' to 25137)
    val completePoints = mapOf(')' to 1, ']' to 2, '}' to 3, '>' to 4)
    var errors = 0
    val completions = mutableListOf<Long>()
    lineLoop@ for (line in lines) {
        val stack = ArrayDeque<Char>()
        for (c in line) {
            if (c in close) {
                stack.addLast(close.getValue(c))
            } else if (stack.removeLastOrNull() != c) {
                errors += errorPoints.getValue(c)
                continue@lineLoop
            }
        }
        completions += stack.reversed().fold(0L) { acc, c -> acc * 5 + completePoints.getValue(c) }
    }
    return errors to completions.sorted()[completions.size / 2]
}

fun crates(input: String, multi: Boolean): String {
    val (drawing, moves) = input.split("\n\n")
    val rows = drawing.lines()
    val count = rows.last().trim().split(Regex("\\s+")).size
    val stacks = List(count) { ArrayDeque<Char>() }
    for (row in rows.dropLast(1)) {
        for (i in 0 until count) {
            val c = row.getOrNull(1 + 4 * i)
            if (c != null && c != ' ') stacks[i].addFirst(c)
        }
    }
    for (m in Regex("move (\\d+) from (\\d+) to (\\d+)").findAll(moves)) {
        val (n, from, to) = m.destructured.toList().map { it.toInt() }
        val taken = (1..n).map { stacks[from - 1].removeLast() }
        (if (multi) taken.reversed() else taken).forEach { stacks[to - 1].addLast(it) }
    }
    return stacks.map { it.lastOrNull() ?: ' ' }.joinToString("")
}

fun stream(s: String): Pair<Int, Int> {
    var depth = 0
    var score = 0
    var garbage = 0
    var inGarbage = false
    var i = 0
    while (i < s.length) {
        val c = s[i]
        when {
            c == '!' -> i++
            inGarbage && c == '>' -> inGarbage = false
            inGarbage -> garbage++
            c == '<' -> inGarbage = true
            c == '{' -> score += ++depth
            c == '}' -> depth--
        }
        i++
    }
    return score to garbage
}

// each escape is one character: \xhh (four characters) or a backslash and any other one
fun decodedLength(lit: String): Int {
    val body = lit.substring(1, lit.length - 1)
    var i = 0
    var n = 0
    while (i < body.length) {
        i += if (body[i] != '\\') 1 else if (Regex("""\\x[0-9a-f]{2}""").matchesAt(body, i)) 4 else 2
        n++
    }
    return n
}

fun encodedLength(lit: String): Int = 2 + lit.sumOf { (if (it == '"' || it == '\\') 2 else 1).toInt() }

fun nextPassword(current: String): String {
    fun inc(s: CharArray): CharArray {
        var i = s.lastIndex
        while (i >= 0) {
            if (s[i] == 'z') {
                s[i] = 'a'
                i--
            } else {
                s[i] = s[i] + 1
                break
            }
        }
        return s
    }
    fun valid(s: String) = s.windowed(3).any { it[1] == it[0] + 1 && it[2] == it[1] + 1 } && s.none { it in "iol" } &&
        Regex("(.)\\1").findAll(s).map { it.value }.distinct().count() >= 2
    var p = inc(current.toCharArray())
    while (!valid(String(p))) p = inc(p)
    return String(p)
}

fun calibration(line: String, words: Boolean): Int {
    val names = listOf("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
    val digits = line.indices.mapNotNull { i ->
        line[i].digitToIntOrNull() ?: if (words) names.indexOfFirst { line.startsWith(it, i) }.takeIf { it >= 0 }?.plus(1) else null
    }
    return digits.first() * 10 + digits.last()
}

fun main() {
    val words = listOf("eeiou", "sootheabout", "rrr", "lomolomo", "uvwuvwkk", "aeiouxxtyty", "babkkeeoi", "momoxoxo", "ffiiuunnoo")
    println("nice: ${words.count(::niceOld)} / ${words.count(::niceNew)} -> ${words.filter(::niceNew)}")

    println("passwords: " + passwordPolicies(listOf("2-4 k: kakkm", "1-2 r: tqrs", "3-5 m: mmmmmm", "1-4 j: jxyj", "2-3 w: awwb")))

    val passports = """
        ecl:gry pid:000123456 eyr:2025 hcl:#a1b2c3
        byr:1950 iyr:2015 cid:7 hgt:180cm

        iyr:2011 hgt:65in ecl:oth hcl:#00ff00
        pid:987654321 byr:1999

        hcl:#123abc byr:1985 eyr:2029 pid:111222333 ecl:hzl iyr:2019 hgt:70in

        byr:2010 iyr:2009 eyr:2031 hgt:190 hcl:123abc ecl:xyz pid:12345

        pid:555666777 hgt:150cm ecl:amb
        hcl:#ffffff
        iyr:2020 byr:1920 eyr:2020

        hgt:194cm ecl:blu byr:1970 iyr:2014 eyr:2024 hcl:#abcdeg pid:0123456789
    """.trimIndent().split(Regex("\n\\s*\n")).map { block ->
        block.split(Regex("\\s+")).associate { it.substringBefore(':') to it.substringAfter(':') }
    }
    println("passports: present=${passports.count { it.keys.containsAll(listOf("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid")) }} valid=${passports.count(::validPassport)}")

    val ips = listOf("kxxk[abcd]efgh", "mnop[qrrq]stts", "zzzz[abcd]efgh", "abcdeffe[xyz]qq", "pqr[stu]vwwvx[lmml]z")
    println("tls: " + ips.map(::supportsTls))

    val chunks = """
        [<>({}){}[([])<>]]
        {([(<>)]
        <{[()]}>)
        [(<{}>]
        <([]){}}
        ({<[]>}
        [[<{(
        {<(>
        <<[]{()}
        (<[{}]>{[]}]
    """.trimIndent().lines()
    println("syntax: " + syntaxScore(chunks))

    val crateInput = "[Q]         [T]\n[R] [W]     [U]\n[S] [X] [Y] [V]\n 1   2   3   4 \n\n" +
        "move 2 from 4 to 3\nmove 1 from 1 to 2\nmove 3 from 3 to 1\nmove 2 from 2 to 4"
    println("crates: ${crates(crateInput, false)} ${crates(crateInput, true)}")

    for (s in listOf("{}", "{{}{}}", "{<x!>y>,{}}", "{{<!!!>>},{<abc>}}", "<!!!!>", "{{{<{}>}},{<>}}", "<a{b!c>")) {
        println("stream $s -> ${stream(s)}")
    }

    val literals = listOf("\"hi\"", "\"a\\\"b\"", "\"\\x4f\\x6b\"", "\"\\\\\\\\\"", "\"z\\\\x41\"")
    println("escapes: " + literals.map { "${it.length}/${decodedLength(it)}/${encodedLength(it)}" } +
        " total=" + literals.sumOf { it.length - decodedLength(it) } + "," + literals.sumOf { encodedLength(it) - it.length })

    println("next passwords: ${nextPassword("qrsuuvwz")} ${nextPassword("tuvaacfz")} ${nextPassword("pqrhhmmz")}")

    val cal = listOf("k4m9", "77", "x1y2z3", "nope5here", "sixabc3", "nineight", "q2threefour", "fivesevenine", "8kseven", "twoone", "threeeight5", "abfour")
    println("calibration: ${cal.take(4).sumOf { calibration(it, false) }} ${cal.drop(4).sumOf { calibration(it, true) }} ${cal.map { calibration(it, true) }}")
}
