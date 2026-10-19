package rules.engine

/** A value a rule can look at: numbers, text and flags, compared with operators. */
sealed class Value : Comparable<Value> {
    data class Num(val v: Double) : Value() {
        override fun toString() = if (v == Math.floor(v) && !v.isInfinite()) v.toLong().toString() else v.toString()
    }

    data class Text(val s: String) : Value() {
        override fun toString() = "\"$s\""
    }

    data class Flag(val b: Boolean) : Value() {
        override fun toString() = b.toString()
    }

    object Missing : Value() {
        override fun toString() = "missing"
    }

    override fun compareTo(other: Value): Int = when {
        this is Num && other is Num -> v.compareTo(other.v)
        this is Text && other is Text -> s.compareTo(other.s)
        this is Flag && other is Flag -> b.compareTo(other.b)
        else -> throw IllegalArgumentException("cannot compare $this with $other")
    }

    operator fun plus(other: Value): Value = when {
        this is Num && other is Num -> Num(v + other.v)
        this is Text -> Text(s + other.render())
        else -> throw UnsupportedOperationException("$this + $other")
    }

    operator fun times(k: Double): Value = (this as? Num)?.let { Num(it.v * k) } ?: Missing

    fun render(): String = when (this) {
        is Text -> s
        else -> toString()
    }
}

fun Int.toValue(): Value = Value.Num(toDouble())
fun Double.toValue(): Value = Value.Num(this)
fun String.toValue(): Value = Value.Text(this)
fun Boolean.toValue(): Value = Value.Flag(this)

/** The working memory: named facts plus an audit trail of changes. */
class Facts(initial: Map<String, Value> = emptyMap()) {
    private val values = LinkedHashMap(initial)
    private val changes = mutableListOf<String>()

    operator fun get(name: String): Value = values[name] ?: Value.Missing

    operator fun set(name: String, value: Value) {
        val old = values.put(name, value)
        if (old != value) changes += "$name: ${old ?: Value.Missing} -> $value"
    }

    operator fun contains(name: String) = name in values

    operator fun plusAssign(pair: Pair<String, Value>) = set(pair.first, pair.second)

    operator fun minusAssign(name: String) {
        values.remove(name)?.let { changes += "$name removed" }
    }

    fun snapshot(): Map<String, Value> = values.toMap()

    val trail: List<String> get() = changes

    override fun toString(): String = values.entries.joinToString(", ", "{", "}") { "${it.key}=${it.value}" }
}
