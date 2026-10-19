// Ports of text-heavy Advent of Code puzzles (with small embedded inputs): nice strings, password policies,
// passport validation, ABBA addresses, syntax scoring, crate stacks, stream garbage, string escapes,
// password increments and calibration values with spelled-out digits.

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
            Regex("(\\d+)(cm|in)").matchEntire(v)?.destructured?.let { (n, u) -> if (u == "cm") n.toInt() in 150..193 else n.toInt() in 59..76 } ?: false
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

fun decodedLength(lit: String): Int =
    lit.substring(1, lit.length - 1).replace(Regex("""\\x[0-9a-f]{2}|\\.""")) { "_" }.length

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
    val words = listOf("ugknbfddgicrmopn", "aaa", "jchzalrnumimnmhp", "haegwjzuvuyypxyu", "dvszwmarrgswjxmb", "qjhvhtzxzqqjkmpb", "xxyxx", "uurcxstgmygtbstg", "ieodomkazucvgmuy")
    println("nice: ${words.count(::niceOld)} / ${words.count(::niceNew)} -> ${words.filter(::niceNew)}")

    println("passwords: " + passwordPolicies(listOf("1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc", "3-4 x: xxyx", "2-2 z: zz")))

    val passports = """
        eyr:1972 cid:100
        hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

        pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
        hcl:#623a2f

        hcl:#888785
        hgt:164cm byr:2001 iyr:2015 cid:88
        pid:545766238 ecl:hzl
        eyr:2022

        iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719

        hgt:59cm ecl:zzz eyr:2038 hcl:74454a iyr:2023 pid:3556412378 byr:2007
    """.trimIndent().split(Regex("\n\\s*\n")).map { block ->
        block.split(Regex("\\s+")).associate { it.substringBefore(':') to it.substringAfter(':') }
    }
    println("passports: present=${passports.count { it.keys.containsAll(listOf("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid")) }} valid=${passports.count(::validPassport)}")

    val ips = listOf("abba[mnop]qrst", "abcd[bddb]xyyx", "aaaa[qwer]tyui", "ioxxoj[asdfgh]zxcvbn", "xyx[abc]ddmn[poop]q")
    println("tls: " + ips.map(::supportsTls))

    val chunks = """
        [({(<(())[]>[[{[]{<()<>>
        [(()[<>])]({[<{<<[]>>(
        {([(<{}[<>[]}>{[]{[(<()>
        (((({<>}<{<{<>}{[]{[]{}
        [[<[([]))<([[{}[[()]]]
        [{[{({}]{}}([{[{{{}}([]
        {<[[]]>}<{[{[{[]{()[[[]
        [<(<(<(<{}))><([]([]()
        <{([([[(<>()){}]>(<<{{
        <{([{{}}[<[[[<>{}]]]>[]]
    """.trimIndent().lines()
    println("syntax: " + syntaxScore(chunks))

    val crateInput = "    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 \n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2"
    println("crates: ${crates(crateInput, false)} ${crates(crateInput, true)}")

    for (s in listOf("{}", "{{{}}}", "{{<!!>},{<!!>},{<!!>},{<!!>}}", "{{<a!>},{<a!>},{<a!>},{<ab>}}", "<{o\"i!a,<{i<a>", "{{<ab>},{<ab>},{<ab>},{<ab>}}")) {
        println("stream $s -> ${stream(s)}")
    }

    val literals = listOf("\"\"", "\"abc\"", "\"aaa\\\"aaa\"", "\"\\x27\"", "\"\\\\x41\"")
    println("escapes: " + literals.map { "${it.length}/${decodedLength(it)}/${encodedLength(it)}" } +
        " total=" + literals.sumOf { it.length - decodedLength(it) } + "," + literals.sumOf { encodedLength(it) - it.length })

    println("next passwords: ${nextPassword("abcdfezz")} ${nextPassword("ghjaabbz")} ${nextPassword("abcdffaa")}")

    val cal = listOf("1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet", "two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "zoneight234", "7pqrstsixteen", "oneight")
    println("calibration: ${cal.take(4).sumOf { calibration(it, false) }} ${cal.drop(4).sumOf { calibration(it, true) }} ${cal.map { calibration(it, true) }}")
}
