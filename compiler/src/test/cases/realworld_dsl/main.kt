package dsl

// Type-safe builders: an HTML DSL and a JSON DSL with @DslMarker, lambdas with receivers, unaryPlus and extension properties.

@DslMarker
annotation class HtmlTagMarker

interface Element {
    fun render(builder: StringBuilder, indent: String)
}

class TextElement(val text: String) : Element {
    override fun render(builder: StringBuilder, indent: String) {
        builder.append("$indent${escape(text)}\n")
    }
}

fun escape(s: String): String = buildString {
    for (c in s) {
        when (c) {
            '<' -> append("&lt;")
            '>' -> append("&gt;")
            '&' -> append("&amp;")
            '"' -> append("&quot;")
            else -> append(c)
        }
    }
}

@HtmlTagMarker
abstract class Tag(val name: String) : Element {
    val children = arrayListOf<Element>()
    val attributes = linkedMapOf<String, String>()

    protected fun <T : Element> initTag(tag: T, init: T.() -> Unit): T {
        tag.init()
        children.add(tag)
        return tag
    }

    override fun render(builder: StringBuilder, indent: String) {
        builder.append("$indent<$name${renderAttributes()}")
        if (children.isEmpty()) {
            builder.append("/>\n")
            return
        }
        builder.append(">\n")
        for (c in children) c.render(builder, "$indent  ")
        builder.append("$indent</$name>\n")
    }

    private fun renderAttributes(): String =
        attributes.entries.joinToString("") { (k, v) -> " $k=\"${escape(v)}\"" }

    override fun toString(): String = StringBuilder().also { render(it, "") }.toString()

    operator fun String.unaryPlus() {
        children.add(TextElement(this))
    }

    operator fun set(attr: String, value: String) {
        attributes[attr] = value
    }

    operator fun get(attr: String): String? = attributes[attr]
}

abstract class TagWithText(name: String) : Tag(name)

class HTML : TagWithText("html") {
    fun head(init: Head.() -> Unit) = initTag(Head(), init)
    fun body(init: Body.() -> Unit) = initTag(Body(), init)
}

class Head : TagWithText("head") {
    fun title(init: Title.() -> Unit) = initTag(Title(), init)
}

class Title : TagWithText("title")

abstract class BodyTag(name: String) : TagWithText(name) {
    fun b(init: B.() -> Unit) = initTag(B(), init)
    fun p(init: P.() -> Unit) = initTag(P(), init)
    fun h1(init: H1.() -> Unit) = initTag(H1(), init)
    fun ul(init: UL.() -> Unit) = initTag(UL(), init)
    fun a(href: String, init: A.() -> Unit) {
        val a = initTag(A(), init)
        a.href = href
    }
}

class Body : BodyTag("body")
class B : BodyTag("b")
class P : BodyTag("p")
class H1 : BodyTag("h1")

class UL : BodyTag("ul") {
    fun li(init: LI.() -> Unit) = initTag(LI(), init)
}

class LI : BodyTag("li")

class A : BodyTag("a") {
    var href: String
        get() = attributes.getValue("href")
        set(value) {
            attributes["href"] = value
        }
}

// Extension properties on the DSL types.
var Tag.cssClass: String?
    get() = attributes["class"]
    set(value) {
        if (value == null) attributes.remove("class") else attributes["class"] = value
    }

val Tag.depth: Int
    get() = 1 + (children.filterIsInstance<Tag>().maxOfOrNull { it.depth } ?: 0)

fun html(init: HTML.() -> Unit): HTML = HTML().apply(init)

// A JSON builder.
sealed class Json {
    abstract fun write(sb: StringBuilder)

    override fun toString() = buildString { write(this) }

    data class JString(val value: String) : Json() {
        override fun write(sb: StringBuilder) {
            sb.append('"')
            value.forEach { ch ->
                when (ch) {
                    '"' -> sb.append("\\\"")
                    '\\' -> sb.append("\\\\")
                    '\n' -> sb.append("\\n")
                    else -> sb.append(ch)
                }
            }
            sb.append('"')
        }
    }

    data class JNumber(val value: Number) : Json() {
        override fun write(sb: StringBuilder) {
            sb.append(value)
        }
    }

    data class JBool(val value: Boolean) : Json() {
        override fun write(sb: StringBuilder) {
            sb.append(value)
        }
    }

    object JNull : Json() {
        override fun write(sb: StringBuilder) {
            sb.append("null")
        }
    }

    class JArray(val items: List<Json>) : Json() {
        override fun write(sb: StringBuilder) {
            sb.append('[')
            items.forEachIndexed { i, item ->
                if (i > 0) sb.append(',')
                item.write(sb)
            }
            sb.append(']')
        }
    }

    class JObject(val fields: Map<String, Json>) : Json() {
        override fun write(sb: StringBuilder) {
            sb.append('{')
            var first = true
            for ((k, v) in fields) {
                if (!first) sb.append(',')
                first = false
                JString(k).write(sb)
                sb.append(':')
                v.write(sb)
            }
            sb.append('}')
        }

        operator fun get(key: String): Json? = fields[key]
    }
}

@DslMarker
annotation class JsonMarker

@JsonMarker
class ObjectBuilder {
    private val fields = linkedMapOf<String, Json>()

    infix fun String.to(value: Any?) {
        fields[this] = toJson(value)
    }

    fun obj(key: String, init: ObjectBuilder.() -> Unit) {
        fields[key] = ObjectBuilder().apply(init).build()
    }

    fun array(key: String, init: ArrayBuilder.() -> Unit) {
        fields[key] = ArrayBuilder().apply(init).build()
    }

    fun build() = Json.JObject(fields.toMap())
}

@JsonMarker
class ArrayBuilder {
    private val items = mutableListOf<Json>()

    operator fun Any?.unaryPlus() {
        items += toJson(this)
    }

    fun obj(init: ObjectBuilder.() -> Unit) {
        items += ObjectBuilder().apply(init).build()
    }

    fun build() = Json.JArray(items.toList())
}

fun toJson(value: Any?): Json = when (value) {
    null -> Json.JNull
    is Json -> value
    is String -> Json.JString(value)
    is Boolean -> Json.JBool(value)
    is Int -> Json.JNumber(value)
    is Double -> Json.JNumber(value)
    is List<*> -> Json.JArray(value.map(::toJson))
    is Map<*, *> -> Json.JObject(value.entries.associate { (k, v) -> k.toString() to toJson(v) })
    else -> Json.JString(value.toString())
}

fun json(init: ObjectBuilder.() -> Unit): Json.JObject = ObjectBuilder().apply(init).build()

fun main() {
    val page = html {
        head {
            title { +"Report <draft>" }
        }
        body {
            cssClass = "main"
            h1 { +"Sales & Revenue" }
            p {
                +"Totals for"
                b { +"Q3" }
                this["data-id"] = "p1"
            }
            ul {
                for ((i, item) in listOf("apples", "pears", "plums").withIndex()) {
                    li {
                        if (i % 2 == 0) cssClass = "even"
                        +"${i + 1}. $item"
                    }
                }
            }
            a("https://example.com/?q=1&r=2") { +"link" }
        }
    }
    print(page)
    val body = page.children.last() as Body
    println("body class=${body.cssClass} depth=${page.depth} p=${(body.children[1] as Tag)["data-id"]}")
    body.cssClass = null
    println("after: ${body.cssClass} ${body.attributes}")
    val link = body.children.filterIsInstance<A>().single()
    println(link.href)

    val doc = json {
        "name" to "k2l"
        "version" to 1
        "ratio" to 0.75
        "stable" to false
        "notes" to null
        "quote" to "say \"hi\"\n"
        obj("owner") {
            "login" to "cale"
            "tags" to listOf("lua", "kotlin")
        }
        array("targets") {
            +"5.1"
            +54
            +true
            obj { "jit" to true }
        }
        "extra" to mapOf(Pair("a", 1), Pair("b", listOf(1, 2)))
    }
    println(doc)
    println(doc["owner"])
    println((doc["targets"] as Json.JArray).items.size)
    println(doc["missing"] ?: "absent")
    println(Json.JString("x") == Json.JString("x"))
    println(listOf<Json>(Json.JNull, Json.JBool(true), Json.JNumber(3)).joinToString(" "))
}
