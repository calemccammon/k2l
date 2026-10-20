// An RFC 4180-style CSV reader written as a character state machine that yields records lazily from a sequence,
// plus a tiny SQL-like query language (SELECT ... WHERE ... GROUP BY ... ORDER BY ... LIMIT) parsed and run over it.

class CsvError(msg: String, val record: Int, val col: Int) : Exception("record $record, column $col: $msg")

enum class CsvState { FIELD_START, UNQUOTED, QUOTED, QUOTE_IN_QUOTED }

fun csvRecords(text: String, sep: Char = ','): Sequence<List<String>> = sequence {
    var state = CsvState.FIELD_START
    val field = StringBuilder()
    var record = mutableListOf<String>()
    var recNo = 1
    var col = 0
    fun endField() { record.add(field.toString()); field.setLength(0) }
    for (c in text) {
        col++
        state = when (state) {
            CsvState.FIELD_START, CsvState.UNQUOTED -> when (c) {
                '"' -> if (state == CsvState.FIELD_START) CsvState.QUOTED else throw CsvError("quote inside unquoted field", recNo, col)
                sep -> { endField(); CsvState.FIELD_START }
                '\n' -> {
                    endField()
                    if (record.size > 1 || record[0].isNotEmpty()) yield(record)
                    record = mutableListOf(); recNo++; col = 0
                    CsvState.FIELD_START
                }
                '\r' -> state
                else -> { field.append(c); CsvState.UNQUOTED }
            }
            CsvState.QUOTED -> if (c == '"') CsvState.QUOTE_IN_QUOTED else { field.append(c); CsvState.QUOTED }
            CsvState.QUOTE_IN_QUOTED -> when (c) {
                '"' -> { field.append('"'); CsvState.QUOTED }
                sep -> { endField(); CsvState.FIELD_START }
                '\n' -> { endField(); yield(record); record = mutableListOf(); recNo++; col = 0; CsvState.FIELD_START }
                '\r' -> state
                else -> throw CsvError("unexpected '$c' after closing quote", recNo, col)
            }
        }
    }
    if (state == CsvState.QUOTED) throw CsvError("unterminated quoted field", recNo, col)
    if (field.isNotEmpty() || record.isNotEmpty() || state == CsvState.QUOTE_IN_QUOTED) { endField(); yield(record) }
}

class Table(val header: List<String>, val rows: List<List<String>>) {
    fun index(name: String): Int = header.indexOf(name).takeIf { it >= 0 } ?: throw IllegalArgumentException("no column '$name' in $header")
}

fun load(text: String): Table {
    val it = csvRecords(text).iterator()
    val header = it.next().map { it.trim().lowercase() }
    val rows = it.asSequence().onEachIndexed { i, r ->
        require(r.size == header.size) { "row ${i + 2} has ${r.size} fields, expected ${header.size}" }
    }.toList()
    return Table(header, rows)
}

sealed interface Cond {
    data class Cmp(val col: String, val op: String, val value: String) : Cond
    data class And(val l: Cond, val r: Cond) : Cond
    data class Or(val l: Cond, val r: Cond) : Cond
}

data class Select(val col: String, val agg: String? = null) {
    val label get() = if (agg == null) col else "$agg($col)"
}

data class Query(val select: List<Select>, val where: Cond?, val groupBy: String?, val orderBy: String?, val desc: Boolean, val limit: Int?)

class QueryParser(src: String) {
    private val toks = Regex("""'(?:[^']|'')*'|[A-Za-z_][\w]*|\d+(?:\.\d+)?|<=|>=|!=|[(),*=<>]""").findAll(src).map { it.value }.toList()
    private var p = 0
    private fun peek() = toks.getOrNull(p)
    private fun kw(w: String) = peek()?.equals(w, ignoreCase = true) == true
    private fun next(): String = toks.getOrNull(p++) ?: throw IllegalArgumentException("unexpected end of query")
    private fun expect(w: String) { if (!next().equals(w, ignoreCase = true)) throw IllegalArgumentException("expected $w near token ${p - 1}") }

    fun parse(): Query {
        expect("select")
        val sel = mutableListOf<Select>()
        do {
            if (sel.isNotEmpty()) p++
            val name = next().lowercase()
            sel += if (kw("(")) { p++; val c = next().lowercase(); expect(")"); Select(c, name) } else Select(name)
        } while (kw(","))
        val where = if (kw("where")) { p++; or() } else null
        val group = if (kw("group")) { p++; expect("by"); next().lowercase() } else null
        var order: String? = null
        var desc = false
        if (kw("order")) {
            p++; expect("by"); order = next().lowercase()
            if (kw("(")) { p++; order = "$order(${next().lowercase()})"; expect(")") }
            if (kw("desc") || kw("asc")) desc = next().lowercase() == "desc"
        }
        val limit = if (kw("limit")) { p++; next().toInt() } else null
        if (peek() != null) throw IllegalArgumentException("trailing input '${peek()}'")
        return Query(sel, where, group, order, desc, limit)
    }

    private fun or(): Cond { var l = and(); while (kw("or")) { p++; l = Cond.Or(l, and()) }; return l }
    private fun and(): Cond { var l = atom(); while (kw("and")) { p++; l = Cond.And(l, atom()) }; return l }
    private fun atom(): Cond {
        if (kw("(")) { p++; return or().also { expect(")") } }
        val col = next().lowercase()
        val op = next()
        if (op !in setOf("=", "!=", "<", "<=", ">", ">=")) throw IllegalArgumentException("bad operator '$op'")
        val v = next().let { if (it.startsWith("'")) it.substring(1, it.length - 1).replace("''", "'") else it }
        return Cond.Cmp(col, op, v)
    }
}

fun compare(a: String, b: String): Int {
    val x = a.toDoubleOrNull()
    val y = b.toDoubleOrNull()
    return if (x != null && y != null) x.compareTo(y) else a.compareTo(b)
}

fun Cond.test(t: Table, row: List<String>): Boolean = when (this) {
    is Cond.And -> l.test(t, row) && r.test(t, row)
    is Cond.Or -> l.test(t, row) || r.test(t, row)
    is Cond.Cmp -> compare(row[t.index(col)], value).let { c ->
        when (op) { "=" -> c == 0; "!=" -> c != 0; "<" -> c < 0; "<=" -> c <= 0; ">" -> c > 0; else -> c >= 0 }
    }
}

fun fmt(d: Double) = if (d == Math.rint(d)) d.toLong().toString() else "%.2f".format(d)

fun run(t: Table, q: Query): List<List<String>> {
    val rows = t.rows.filter { q.where?.test(t, it) ?: true }
    val groups: Map<String, List<List<String>>> = if (q.groupBy != null) rows.groupBy { it[t.index(q.groupBy)] } else mapOf("" to rows)
    val aggregated = q.select.any { it.agg != null }
    var out = if (!aggregated) rows.map { r -> q.select.map { if (it.col == "*") r.joinToString("|") else r[t.index(it.col)] } } else groups.map { (_, g) ->
        q.select.map { s ->
            val nums by lazy { g.map { it[t.index(s.col)].toDouble() } }
            when (s.agg?.lowercase()) {
                null -> g.first()[t.index(s.col)]
                "count" -> g.size.toString()
                "sum" -> fmt(nums.sum())
                "avg" -> fmt(nums.average())
                "min" -> fmt(nums.min())
                "max" -> fmt(nums.max())
                else -> throw IllegalArgumentException("unknown aggregate ${s.agg}")
            }
        }
    }
    q.orderBy?.let { key ->
        val i = q.select.indexOfFirst { it.label == key }.takeIf { it >= 0 } ?: throw IllegalArgumentException("ORDER BY $key is not selected")
        val cmp = Comparator<List<String>> { a, b -> compare(a[i], b[i]) }
        out = out.sortedWith(if (q.desc) cmp.reversed() else cmp)
    }
    return q.limit?.let { out.take(it) } ?: out
}

val data = "Name,Dept,Salary,City\r\n" +
    "\"Smith, Anna\",Eng,120000,\"New York\"\r\n" +
    "Bob \"Bobby\" Jones,Ops,85000,Austin\n" +
    "\"Chen \"\"CJ\"\" Li\",Eng,135000.50,Seattle\n" +
    "Dana,Sales,70000,\"Austin\"\n" +
    "Émile,Eng,99000,Montréal\n" +
    "\"Multi\nLine\",Ops,60000,\n" +
    "Fay,Sales,91000,Seattle"

fun main() {
    println(runCatching { load(data) }.exceptionOrNull()?.message)
    val fixed = data.replace("Bob \"Bobby\" Jones", "\"Bob \"\"Bobby\"\" Jones\"")
    val t = load(fixed)
    println("${t.header} ${t.rows.size} rows")
    t.rows.forEach { r -> println(r.joinToString(" | ") { it.replace("\n", "\\n").ifEmpty { "∅" } }) }
    val queries = listOf(
        "SELECT name, city WHERE dept = 'Eng' AND salary > 100000",
        "select dept, count(name), sum(salary), avg(salary) group by dept order by sum(salary) desc",
        "SELECT city, max(salary) GROUP BY city ORDER BY city",
        "SELECT name WHERE city = 'Austin' OR (dept = 'Sales' AND salary >= 91000) ORDER BY name DESC LIMIT 2",
        "SELECT * WHERE salary < 70000",
        "SELECT name WHERE name = 'Bob \"Bobby\" Jones'",
        "SELECT name, bogus",
        "SELECT name WHERE salary ~ 3",
        "SELECT name ORDER BY city",
        "SELECT name LIMIT",
        "SELECT name, frob(salary) GROUP BY dept",
        "UPDATE x",
    )
    for (src in queries) {
        println("> $src")
        try {
            val q = QueryParser(src).parse()
            val res = run(t, q)
            println("  " + q.select.joinToString("\t") { it.label })
            res.forEach { println("  " + it.joinToString("\t")) }
        } catch (e: IllegalArgumentException) {
            println("  error: ${e.message}")
        }
    }
    val errs = listOf("a,\"b\nc", "a,\"b\"x,c", "x,y\n1,2,3")
    for (e in errs) println(runCatching { load(e).rows }.fold({ "ok $it" }, { "${it::class.simpleName}: ${it.message}" }))
    println(csvRecords("a;b;\"c;d\"\n;;\n", ';').toList())
    println(csvRecords("one\n\ntwo\n").map { it.single() }.toList())
}
