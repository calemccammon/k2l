// A mustache-like templating engine: {{name}}, dotted paths, filters with arguments ({{price | money:2}}),
// {{#each items}}...{{/each}} with @index/@first/@last, {{#if}}/{{else}}, partials, comments and escaping.

sealed class Node
data class Text(val text: String) : Node()
data class Value(val path: String, val filters: List<Pair<String, List<String>>>, val raw: Boolean) : Node()
data class Each(val path: String, val body: List<Node>) : Node()
data class If(val path: String, val negate: Boolean, val then: List<Node>, val otherwise: List<Node>) : Node()
data class Partial(val name: String) : Node()

class TemplateError(msg: String) : Exception(msg)

private val TAG = Regex("""\{\{(\{?)\s*([#/^!>]?)\s*(.*?)\s*\}?\}\}""")

fun parseTemplate(src: String): List<Node> {
    data class Frame(val kind: String, val arg: String, val nodes: MutableList<Node>, var otherwise: MutableList<Node>? = null)
    val stack = ArrayDeque<Frame>()
    stack.addLast(Frame("root", "", mutableListOf()))
    var last = 0
    for (m in TAG.findAll(src)) {
        val target = stack.last().otherwise ?: stack.last().nodes
        if (m.range.first > last) target += Text(src.substring(last, m.range.first))
        last = m.range.last + 1
        val (brace, sigil, body) = m.destructured
        when (sigil) {
            "!" -> {}
            "#", "^" -> {
                val (kind, arg) = body.split(Regex("\\s+"), limit = 2).let { it[0] to it.getOrElse(1) { "" } }
                if (sigil == "^") stack.addLast(Frame("unless", kind, mutableListOf()))
                else stack.addLast(Frame(kind, arg, mutableListOf()))
            }
            "/" -> {
                val f = stack.removeLast()
                if (f.kind != body && !(f.kind == "unless" && f.arg == body)) throw TemplateError("unexpected {{/$body}}, open block is '${f.kind}'")
                val node = when (f.kind) {
                    "each" -> Each(f.arg, f.nodes)
                    "if" -> If(f.arg, false, f.nodes, f.otherwise ?: mutableListOf())
                    "unless" -> If(f.arg, true, f.nodes, f.otherwise ?: mutableListOf())
                    else -> throw TemplateError("unknown block '${f.kind}'")
                }
                (stack.last().otherwise ?: stack.last().nodes) += node
            }
            ">" -> target += Partial(body)
            else -> if (body == "else") {
                stack.last().otherwise = mutableListOf()
            } else {
                val parts = body.split('|').map { it.trim() }
                val filters = parts.drop(1).map { f ->
                    val name = f.substringBefore(':')
                    name to (if (':' in f) f.substringAfter(':').split(',').map { it.trim().removeSurrounding("\"") } else emptyList())
                }
                target += Value(parts[0], filters, raw = brace == "{")
            }
        }
    }
    if (last < src.length) (stack.last().otherwise ?: stack.last().nodes) += Text(src.substring(last))
    if (stack.size != 1) throw TemplateError("unclosed {{#${stack.last().kind}}}")
    return stack.single().nodes
}

class Scope(val value: Any?, val parent: Scope?, val locals: Map<String, Any?> = emptyMap()) {
    fun lookup(path: String): Any? {
        if (path == "." || path == "this") return value
        if (path.startsWith("@")) return locals[path] ?: parent?.lookup(path)
        val keys = path.split('.')
        var scope: Scope? = this
        while (scope != null) {
            val head = field(scope.value, keys[0])
            if (head != null) return keys.drop(1).fold(head) { acc: Any?, k -> field(acc, k) }
            scope = scope.parent
        }
        return null
    }

    private fun field(obj: Any?, key: String): Any? = when (obj) {
        is Map<*, *> -> obj[key]
        is List<*> -> key.toIntOrNull()?.let { obj.getOrNull(it) } ?: if (key == "length") obj.size else null
        is String -> if (key == "length") obj.length else null
        else -> null
    }
}

fun truthy(v: Any?): Boolean = when (v) {
    null -> false
    is Boolean -> v
    is Number -> v.toDouble() != 0.0
    is String -> v.isNotEmpty()
    is Collection<*> -> v.isNotEmpty()
    else -> true
}

fun html(s: String) = buildString {
    for (c in s) append(when (c) { '<' -> "&lt;"; '>' -> "&gt;"; '&' -> "&amp;"; '"' -> "&quot;"; '\'' -> "&#39;"; else -> c })
}

val FILTERS: Map<String, (Any?, List<String>) -> Any?> = mapOf(
    "upper" to { v, _ -> v.toString().uppercase() },
    "lower" to { v, _ -> v.toString().lowercase() },
    "capitalize" to { v, _ -> v.toString().replaceFirstChar { it.uppercaseChar() } },
    "trim" to { v, _ -> v.toString().trim() },
    "money" to { v, a -> "$" + String.format("%,.${a.firstOrNull() ?: "2"}f", (v as Number).toDouble()) },
    "pad" to { v, a -> v.toString().padStart(a[0].toInt(), a.getOrElse(1) { " " }.first()) },
    "rpad" to { v, a -> v.toString().padEnd(a[0].toInt(), a.getOrElse(1) { " " }.first()) },
    "default" to { v, a -> if (truthy(v)) v else a[0] },
    "join" to { v, a -> (v as List<*>).joinToString(a.firstOrNull() ?: ", ") },
    "truncate" to { v, a -> v.toString().let { s -> if (s.length <= a[0].toInt()) s else s.take(a[0].toInt() - 1) + "…" } },
    "plural" to { v, a -> if ((v as Number).toInt() == 1) a[0] else a.getOrElse(1) { a[0] + "s" } },
    "percent" to { v, _ -> "%.1f%%".format((v as Number).toDouble() * 100) },
    "reverse" to { v, _ -> if (v is List<*>) v.reversed() else v.toString().reversed() },
    "length" to { v, _ -> if (v is Collection<*>) v.size else v.toString().length },
)

class Renderer(private val partials: Map<String, String>) {
    private val cache = mutableMapOf<String, List<Node>>()

    fun render(nodes: List<Node>, scope: Scope, out: StringBuilder) {
        for (n in nodes) when (n) {
            is Text -> out.append(n.text)
            is Value -> {
                var v = scope.lookup(n.path)
                for ((name, args) in n.filters) {
                    val f = FILTERS[name] ?: throw TemplateError("unknown filter '$name'")
                    v = f(v, args)
                }
                val s = when (v) {
                    null -> ""
                    is Double -> if (v % 1.0 == 0.0) v.toLong().toString() else v.toString()
                    else -> v.toString()
                }
                out.append(if (n.raw) s else html(s))
            }
            is Each -> {
                val items = scope.lookup(n.path) as? List<*> ?: emptyList<Any?>()
                items.forEachIndexed { i, item ->
                    val locals = mapOf("@index" to i, "@number" to i + 1, "@first" to (i == 0), "@last" to (i == items.lastIndex))
                    render(n.body, Scope(item, scope, locals), out)
                }
            }
            is If -> render(if (truthy(scope.lookup(n.path)) != n.negate) n.then else n.otherwise, scope, out)
            is Partial -> render(cache.getOrPut(n.name) { parseTemplate(partials[n.name] ?: throw TemplateError("no partial '${n.name}'")) }, scope, out)
        }
    }

    fun render(src: String, data: Any?): String = StringBuilder().also { render(parseTemplate(src), Scope(data, null), it) }.toString()
}

val INVOICE = """
{{! invoice template }}
INVOICE #{{number | pad:6,0}}  {{customer.name | upper}}
{{#if customer.vip}}*** VIP customer: {{customer.discount | percent}} off ***{{else}}Regular customer{{/if}}
{{#each lines}}{{> line}}{{/each}}
{{#if notes}}Notes: {{notes | join:"; "}}{{/if}}{{^notes}}No notes.{{/notes}}
Total: {{total | money}} ({{lines | length}} {{lines.length | plural:line}})
Tags: {{#each tags}}{{.}}{{#if @last}}.{{else}}, {{/if}}{{/each}}
Escaped: {{html}} / raw: {{{html}}} / missing: [{{nope | default:"n/a"}}]
""".trimIndent()

fun main() {
    val partials = mapOf("line" to "{{@number | pad:2}}. {{name | rpad:22,.}} {{qty | pad:3}} x {{price | money | pad:10}}{{#if @first}}  <- first{{/if}}\n")
    val lines = listOf(
        mapOf("name" to "keyboard", "qty" to 2, "price" to 49.99),
        mapOf("name" to "ultra-wide monitor stand", "qty" to 1, "price" to 1299.5),
        mapOf("name" to "usb cable", "qty" to 10, "price" to 3.25),
    )
    val total = lines.sumOf { (it["qty"] as Int) * (it["price"] as Double) } * 0.9
    val data = mapOf(
        "number" to 417,
        "customer" to mapOf("name" to "Ada Lovelace", "vip" to true, "discount" to 0.1),
        "lines" to lines,
        "notes" to listOf("leave at door", "fragile"),
        "total" to total,
        "tags" to listOf("hardware", "office", "q1"),
        "html" to "<b>\"Tom\" & 'Jerry'</b>",
    )
    val r = Renderer(partials)
    println(r.render(INVOICE, data))
    println("----")
    println(r.render(INVOICE, data + mapOf("notes" to emptyList<String>(), "customer" to mapOf("name" to "bob", "vip" to false))))
    println("----")
    println(r.render("{{#each rows}}[{{#each .}}{{.}}{{^@last}},{{/@last}}{{/each}}]{{/each}}", mapOf("rows" to listOf(listOf(1, 2), listOf(3), emptyList<Int>()))))
    println(r.render("{{greeting | capitalize}}, {{name | truncate:6}}! {{name | reverse | lower}} {{name | length}}", mapOf("greeting" to "hello", "name" to "Wilhelmina")))
    println(r.render("{{a.b.c}}|{{a.list.1}}|{{a.list.length}}|{{a.missing.deep}}|{{x | trim | upper}}", mapOf("a" to mapOf("b" to mapOf("c" to 3.5), "list" to listOf("p", "q")), "x" to "  spaced  ")))
    for (bad in listOf("{{#each x}}oops", "{{#if a}}{{/each}}", "{{x | shout}}", "{{> nope}}")) {
        try {
            println(r.render(bad, mapOf("x" to 1)))
        } catch (e: TemplateError) {
            println("template error: ${e.message}")
        }
    }
}
