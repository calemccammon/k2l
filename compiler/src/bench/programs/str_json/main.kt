// Adapted from realworld_text_json: a sealed JSON value tree, a character-level recursive-descent parser, a
// serializer with escaping, and queries over the parsed documents (maps of lists of maps).

const val SIZE = 1500 // documents

sealed class Json {
    data class Num(val value: Double) : Json()
    data class Str(val value: String) : Json()
    data class Bool(val value: Boolean) : Json()
    object Null : Json()
    data class Arr(val items: List<Json>) : Json()
    data class Obj(val fields: Map<String, Json>) : Json()
}

class ParseError(message: String) : Exception(message)

class Parser(private val text: String) {
    private var pos = 0

    fun parse(): Json {
        val v = value()
        skip()
        if (pos != text.length) throw ParseError("trailing data at $pos")
        return v
    }

    private fun skip() {
        while (pos < text.length && text[pos].isWhitespace()) pos++
    }

    private fun value(): Json {
        skip()
        if (pos >= text.length) throw ParseError("unexpected end")
        return when (val c = text[pos]) {
            '{' -> obj()
            '[' -> arr()
            '"' -> Json.Str(string())
            't', 'f' -> literal(if (c == 't') "true" else "false", Json.Bool(c == 't'))
            'n' -> literal("null", Json.Null)
            else -> number()
        }
    }

    private fun literal(word: String, v: Json): Json {
        if (!text.startsWith(word, pos)) throw ParseError("bad literal at $pos")
        pos += word.length
        return v
    }

    private fun number(): Json {
        val start = pos
        while (pos < text.length && (text[pos].isDigit() || text[pos] in "+-.eE")) pos++
        return Json.Num(text.substring(start, pos).toDoubleOrNull() ?: throw ParseError("bad number at $start"))
    }

    private fun string(): String {
        pos++
        val sb = StringBuilder()
        while (true) {
            val c = text[pos++]
            when (c) {
                '"' -> return sb.toString()
                '\\' -> {
                    when (val e = text[pos++]) {
                        'n' -> sb.append('\n')
                        't' -> sb.append('\t')
                        'u' -> {
                            sb.append(text.substring(pos, pos + 4).toInt(16).toChar())
                            pos += 4
                        }
                        else -> sb.append(e)
                    }
                }
                else -> sb.append(c)
            }
        }
    }

    private fun arr(): Json {
        pos++
        val items = mutableListOf<Json>()
        skip()
        if (text[pos] == ']') {
            pos++
            return Json.Arr(items)
        }
        while (true) {
            items += value()
            skip()
            when (text[pos++]) {
                ',' -> continue
                ']' -> return Json.Arr(items)
                else -> throw ParseError("expected , or ] at ${pos - 1}")
            }
        }
    }

    private fun obj(): Json {
        pos++
        val fields = LinkedHashMap<String, Json>()
        skip()
        if (text[pos] == '}') {
            pos++
            return Json.Obj(fields)
        }
        while (true) {
            skip()
            val key = string()
            skip()
            if (text[pos++] != ':') throw ParseError("expected : at ${pos - 1}")
            fields[key] = value()
            skip()
            when (text[pos++]) {
                ',' -> continue
                '}' -> return Json.Obj(fields)
                else -> throw ParseError("expected , or } at ${pos - 1}")
            }
        }
    }
}

fun quote(s: String, out: StringBuilder) {
    out.append('"')
    for (c in s) {
        when (c) {
            '"' -> out.append("\\\"")
            '\\' -> out.append("\\\\")
            '\n' -> out.append("\\n")
            else -> out.append(c)
        }
    }
    out.append('"')
}

fun write(v: Json, out: StringBuilder) {
    when (v) {
        is Json.Num -> if (v.value == Math.floor(v.value)) out.append(v.value.toLong()) else out.append(v.value)
        is Json.Str -> quote(v.value, out)
        is Json.Bool -> out.append(v.value)
        Json.Null -> out.append("null")
        is Json.Arr -> {
            out.append('[')
            v.items.forEachIndexed { i, item ->
                if (i > 0) out.append(',')
                write(item, out)
            }
            out.append(']')
        }
        is Json.Obj -> {
            out.append('{')
            var first = true
            for ((k, item) in v.fields) {
                if (!first) out.append(',')
                first = false
                quote(k, out)
                out.append(':')
                write(item, out)
            }
            out.append('}')
        }
    }
}

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

fun document(rng: Lcg, id: Int): String {
    val users = (0 until 4 + rng.next(6)).joinToString(",\n    ") { u ->
        val tags = (0 until rng.next(4)).joinToString(", ") { "\"tag${rng.next(20)}\"" }
        """{"id": ${id * 100 + u}, "name": "user \"$u\"", "score": ${rng.next(10000) / 100.0}, "active": ${rng.next(2) == 0}, "tags": [$tags], "manager": null}"""
    }
    return """{"doc": $id, "title": "Report\n#$id", "users": [
    $users
], "meta": {"version": 3, "ratio": 1.5e-3, "unicode": "\u0041\u0042C"}}"""
}

fun main() {
    val rng = Lcg(1234)
    var users = 0
    var score = 0.0
    var tags = 0
    var chars = 0L
    for (id in 0 until SIZE) {
        val parsed = Parser(document(rng, id)).parse() as Json.Obj
        val list = (parsed.fields["users"] as Json.Arr).items.map { it as Json.Obj }
        users += list.size
        score += list.filter { (it.fields["active"] as Json.Bool).value }.sumOf { (it.fields["score"] as Json.Num).value }
        tags += list.sumOf { (it.fields["tags"] as Json.Arr).items.size }
        val out = StringBuilder()
        write(parsed, out)
        val again = Parser(out.toString()).parse()
        check(again == parsed) { "round trip failed for $id" }
        chars += out.length
    }
    println("users $users, active score %.2f, tags $tags, serialized $chars chars".format(score))
}
