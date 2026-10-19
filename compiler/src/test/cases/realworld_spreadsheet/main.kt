package sheet

// A tiny spreadsheet: value-class cell references, ranges via rangeTo, formulas with dependencies, recalculation in
// dependency order and cycle detection.

@JvmInline
value class Col(val index: Int) {
    val letters: String get() = toLetters(index)

    companion object {
        tailrec fun toLetters(i: Int, acc: String = ""): String =
            if (i < 0) acc else toLetters(i / 26 - 1, ('A' + i % 26) + acc)

        fun parse(s: String): Col = Col(s.fold(0) { acc, c -> acc * 26 + (c - 'A' + 1) } - 1)
    }
}

data class Ref(val col: Col, val row: Int) : Comparable<Ref> {
    override fun toString() = "${col.letters}$row"
    override fun compareTo(other: Ref) = compareValuesBy(this, other, { it.row }, { it.col.index })

    operator fun rangeTo(other: Ref) = Area(this, other)

    companion object {
        private val PATTERN = Regex("([A-Z]+)([0-9]+)")
        fun parse(s: String): Ref {
            val m = PATTERN.matchEntire(s.trim().uppercase()) ?: throw IllegalArgumentException("bad reference '$s'")
            val (letters, digits) = m.destructured
            return Ref(Col.parse(letters), digits.toInt())
        }
    }
}

class Area(val from: Ref, val to: Ref) : Iterable<Ref> {
    override fun iterator(): Iterator<Ref> = iterator {
        for (r in minOf(from.row, to.row)..maxOf(from.row, to.row)) {
            for (c in minOf(from.col.index, to.col.index)..maxOf(from.col.index, to.col.index)) yield(Ref(Col(c), r))
        }
    }

    override fun toString() = "$from:$to"
}

operator fun Ref.component1() = col.letters
operator fun Ref.component2() = row

sealed class Formula {
    abstract fun refs(): Set<Ref>

    class Const(val value: Double) : Formula() {
        override fun refs() = emptySet<Ref>()
        override fun toString() = value.toString()
    }

    class Cell(val ref: Ref) : Formula() {
        override fun refs() = setOf(ref)
        override fun toString() = ref.toString()
    }

    class Op(val op: Char, val left: Formula, val right: Formula) : Formula() {
        override fun refs() = left.refs() + right.refs()
        override fun toString() = "($left $op $right)"
    }

    class Fn(val name: String, val area: Area) : Formula() {
        override fun refs() = area.toSet()
        override fun toString() = "$name($area)"
    }
}

class CycleException(val path: List<Ref>) : RuntimeException("cycle: ${path.joinToString(" -> ")}")

infix fun Formula.plus(other: Formula) = Formula.Op('+', this, other)
infix fun Formula.times(other: Formula) = Formula.Op('*', this, other)

fun parseFormula(text: String): Formula {
    val t = text.trim()
    t.toDoubleOrNull()?.let { return Formula.Const(it) }
    Regex("""(SUM|AVG|MAX)\((\w+):(\w+)\)""").matchEntire(t)?.let { m ->
        val (name, a, b) = m.destructured
        return Formula.Fn(name, Ref.parse(a)..Ref.parse(b))
    }
    for (op in listOf('+', '-', '*', '/')) {
        val i = t.lastIndexOf(op)
        if (i > 0) return Formula.Op(op, parseFormula(t.substring(0, i)), parseFormula(t.substring(i + 1)))
    }
    return Formula.Cell(Ref.parse(t))
}

class Sheet {
    private val formulas = sortedMapOf<Ref, Formula>()
    private val values = hashMapOf<Ref, Double>()
    lateinit var lastOrder: List<Ref>
    var evaluations = 0
        private set

    operator fun set(ref: String, formula: String) {
        formulas[Ref.parse(ref)] = parseFormula(formula)
    }

    operator fun get(ref: String): Double = values[Ref.parse(ref)] ?: 0.0

    operator fun get(area: Area): List<Double> = area.map { values[it] ?: 0.0 }

    private fun order(): List<Ref> {
        val done = linkedSetOf<Ref>()
        val visiting = mutableListOf<Ref>()
        fun visit(r: Ref) {
            if (r in done) return
            if (r in visiting) throw CycleException(visiting.dropWhile { it != r } + r)
            visiting += r
            formulas[r]?.refs()?.sorted()?.forEach(::visit)
            visiting.removeAt(visiting.lastIndex)
            done += r
        }
        formulas.keys.forEach(::visit)
        return done.filter { it in formulas }
    }

    fun recalc() {
        lastOrder = order()
        values.clear()
        for (ref in lastOrder) values[ref] = eval(formulas.getValue(ref))
    }

    private fun eval(f: Formula): Double {
        evaluations++
        return when (f) {
            is Formula.Const -> f.value
            is Formula.Cell -> values[f.ref] ?: 0.0
            is Formula.Op -> {
                val (l, r) = eval(f.left) to eval(f.right)
                when (f.op) {
                    '+' -> l + r
                    '-' -> l - r
                    '*' -> l * r
                    '/' -> if (r == 0.0) Double.NaN else l / r
                    else -> error("unknown operator ${f.op}")
                }
            }
            is Formula.Fn -> {
                val xs = this[f.area]
                when (f.name) {
                    "SUM" -> xs.sum()
                    "AVG" -> xs.average()
                    "MAX" -> xs.maxOrNull() ?: 0.0
                    else -> error("unknown function ${f.name}")
                }
            }
        }
    }

    fun render(area: Area): String {
        val rows = area.groupBy { it.row }
        return rows.entries.joinToString("\n") { (row, refs) ->
            "%3d | ".format(row) + refs.joinToString(" ") { "%8.2f".format(values[it] ?: 0.0) }
        }
    }

    fun describe(): List<String> = formulas.map { (ref, f) -> "$ref = $f" }
}

fun main() {
    println((0..3).map { Col(it).letters } + listOf(25, 26, 27, 51, 52, 701, 702).map { Col.toLetters(it) })
    println(listOf("A", "Z", "AA", "AZ", "ZZ", "AAA").map { Col.parse(it).index })
    val (letters, row) = Ref.parse("bc12")
    println("$letters $row ${Ref.parse("C3") < Ref.parse("A4")} ${(Ref.parse("A1")..Ref.parse("B2")).toList()}")
    println(runCatching { Ref.parse("1A") }.exceptionOrNull()?.message)

    val s = Sheet()
    s["A1"] = "10"
    s["A2"] = "32.5"
    s["A3"] = "SUM(A1:A2)"
    s["B1"] = "A1*2"
    s["B2"] = "B1+A3"
    s["B3"] = "AVG(A1:B2)"
    s["C1"] = "MAX(A1:B3)"
    s["C2"] = "C1/A4"
    s["C3"] = "B3-A1-1"
    s.recalc()
    s.describe().forEach(::println)
    println("order: ${s.lastOrder}")
    println(s.render(Ref.parse("A1")..Ref.parse("C3")))
    println("C2 is NaN: ${s["C2"].isNaN()}, evaluations=${s.evaluations}")
    println(s[Ref.parse("A1")..Ref.parse("A3")].map { it.toString() })

    val built = Formula.Const(2.0) plus Formula.Cell(Ref.parse("A1")) times Formula.Const(3.0)
    println("$built refs=${built.refs()}")

    s["A1"] = "C3"
    try {
        s.recalc()
    } catch (e: CycleException) {
        println("${e.message} (length ${e.path.size})")
    }
    val fresh = Sheet()
    println(runCatching { fresh.lastOrder }.exceptionOrNull()?.javaClass?.simpleName)
}
