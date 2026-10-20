package generics.builders

// Type-safe builders: an HTML-ish tree with a DslMarker and self-typed tags, a table renderer whose columns are typed by
// the row type, and a generic config builder with typed settings.

@DslMarker
annotation class HtmlDsl

@HtmlDsl
abstract class Tag<Self : Tag<Self>>(val name: String) {
    protected val children = mutableListOf<Any>()
    private val attributes = linkedMapOf<String, String>()

    @Suppress("UNCHECKED_CAST")
    fun attr(key: String, value: Any): Self {
        attributes[key] = value.toString()
        return this as Self
    }

    operator fun String.unaryPlus() {
        children += this
    }

    protected fun <T : Tag<T>> child(tag: T, init: T.() -> Unit): T {
        tag.init()
        children += tag
        return tag
    }

    fun render(out: StringBuilder = StringBuilder(), indent: String = ""): StringBuilder {
        val attrs = attributes.entries.joinToString("") { (k, v) -> " $k=\"$v\"" }
        if (children.all { it is String }) {
            return out.append("$indent<$name$attrs>${children.joinToString(" ")}</$name>\n")
        }
        out.append("$indent<$name$attrs>\n")
        for (c in children) {
            if (c is Tag<*>) c.render(out, "$indent  ") else out.append("$indent  $c\n")
        }
        return out.append("$indent</$name>\n")
    }
}

class Html : Tag<Html>("html") {
    fun body(init: Body.() -> Unit) = child(Body(), init)
}

class Body : Tag<Body>("body") {
    fun h1(text: String) = child(Text("h1")) { +text }
    fun p(init: Text.() -> Unit) = child(Text("p"), init)
    fun ul(init: Ul.() -> Unit) = child(Ul(), init)
}

class Text(name: String) : Tag<Text>(name) {
    fun b(text: String) = +"*$text*"
}

class Ul : Tag<Ul>("ul") {
    fun li(text: String) = child(Text("li")) { +text }
    fun <T> items(xs: Iterable<T>, label: (T) -> String = { it.toString() }) = xs.forEach { li(label(it)) }
}

fun html(init: Html.() -> Unit): Html = Html().apply(init)

class Column<R, V>(val title: String, val align: Align, val get: (R) -> V, val show: (V) -> String)

enum class Align { LEFT, RIGHT }

class TableBuilder<R> {
    val columns = mutableListOf<Column<R, *>>()

    fun <V> column(title: String, align: Align = Align.LEFT, show: (V) -> String = { it.toString() }, get: (R) -> V) {
        columns += Column(title, align, get, show)
    }

    fun number(title: String, digits: Int = 2, get: (R) -> Double) =
        column(title, Align.RIGHT, { "%.${digits}f".format(it) }, get)
}

private fun <R, V> Column<R, V>.cell(row: R): String = show(get(row))

fun <R> table(rows: List<R>, build: TableBuilder<R>.() -> Unit): String {
    val columns = TableBuilder<R>().apply(build).columns
    val cells = rows.map { row -> columns.map { it.cell(row) } }
    val widths = columns.mapIndexed { i, c -> maxOf(c.title.length, cells.maxOfOrNull { it[i].length } ?: 0) }
    fun line(values: List<String>) = values.mapIndexed { i, v ->
        if (columns[i].align == Align.RIGHT) v.padStart(widths[i]) else v.padEnd(widths[i])
    }.joinToString(" | ").trimEnd()
    return buildString {
        appendLine(line(columns.map { it.title }))
        appendLine(widths.joinToString("-+-") { "-".repeat(it) })
        cells.forEach { appendLine(line(it)) }
    }
}

class Setting<T>(val name: String, val default: T, val parse: (String) -> T)

class ConfigBuilder {
    private val values = linkedMapOf<Setting<*>, Any?>()
    private val errors = mutableListOf<String>()

    infix fun <T> Setting<T>.to(value: T) {
        values[this] = value
    }

    infix fun <T> Setting<T>.from(raw: String) {
        try {
            values[this] = parse(raw)
        } catch (e: IllegalArgumentException) {
            errors += "$name: ${e.message}"
        }
    }

    fun build() = Config(values.toMap(), errors.toList())
}

class Config(private val values: Map<Setting<*>, Any?>, val errors: List<String>) {
    @Suppress("UNCHECKED_CAST")
    operator fun <T> get(s: Setting<T>): T = if (s in values) values[s] as T else s.default
}

fun config(block: ConfigBuilder.() -> Unit) = ConfigBuilder().apply(block).build()

val WORKERS = Setting("workers", 4, String::toInt)
val VERBOSE = Setting("verbose", false) { it.toBooleanStrict() }
val NAME = Setting("name", "service") { it }
val RATIO = Setting("ratio", 0.5) { s -> s.toDouble().also { require(it in 0.0..1.0) { "ratio out of range: $it" } } }

data class Planet(val name: String, val moons: Int, val radiusKm: Double, val rings: Boolean)

fun main() {
    val page = html {
        attr("lang", "en")
        body {
            attr("class", "doc").attr("id", 7)
            h1("Generics")
            p {
                +"Kotlin has"
                b("declaration-site")
                +"variance."
            }
            ul {
                li("in")
                items(listOf("out", "star")) { "<$it>" }
                items(1..2)
            }
        }
    }
    print(page.render())

    val planets = listOf(
        Planet("Mercury", 0, 2439.7, false),
        Planet("Earth", 1, 6371.0, false),
        Planet("Jupiter", 95, 69911.0, true),
        Planet("Saturn", 146, 58232.0, true),
    )
    print(
        table(planets) {
            column("name") { it.name }
            column("moons", Align.RIGHT) { it.moons }
            number("radius (km)", 1) { it.radiusKm }
            column("rings", show = { if (it) "yes" else "no" }) { it.rings }
            number("vs earth") { it.radiusKm / 6371.0 }
        },
    )
    print(table(listOf("a", "bbb", "cc")) { column<Int>("len", Align.RIGHT) { it.length }; column("upper") { it.uppercase() } })

    val cfg = config {
        WORKERS from "16"
        VERBOSE to true
        RATIO from "1.5"
        VERBOSE from "yes"
        NAME to "api"
    }
    val workers: Int = cfg[WORKERS]
    println("workers=${workers * 2} verbose=${cfg[VERBOSE]} name=${cfg[NAME].uppercase()} ratio=${cfg[RATIO]}")
    println("errors=${cfg.errors}")
}
