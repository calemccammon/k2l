// A Markdown-subset to HTML converter: block structure (ATX and setext headings, nested lists, fenced code, block
// quotes, rules, paragraphs) found line by line, and an inline scanner over chars for emphasis, code spans, links,
// autolinks and escapes, with HTML escaping and a heading table of contents with unique slugs.

sealed class Block {
    data class Heading(val level: Int, val text: String) : Block()
    data class Para(val lines: List<String>) : Block()
    data class Code(val lang: String?, val body: String) : Block()
    data class Quote(val children: List<Block>) : Block()
    data class ListBlock(val ordered: Boolean, val start: Int, val items: List<List<Block>>) : Block()
    data object Rule : Block()
}

// Lua patterns have no alternation: bullets and numbers are separate patterns
private val bulletMarker = Regex("""^( {0,3})([-*+])\s+(.*)$""")
private val numberMarker = Regex("""^( {0,3})((\d{1,9})[.)])\s+(.*)$""")

/** A list item line's groups (the line, its indent, marker, number (empty for a bullet) and text), or null. */
fun listMarker(line: String): List<String>? = numberMarker.matchEntire(line)?.groupValues
    ?: bulletMarker.matchEntire(line)?.groupValues?.let { g -> listOf(g[0], g[1], g[2], "", g[3]) }

fun isSetextUnderline(line: String) = Regex("^=+\\s*$").matches(line) || Regex("^-+\\s*$").matches(line)
private val atx = Regex("""^(#{1,6})\s+(.*?)\s*#*\s*$""")

fun parseBlocks(lines: List<String>): List<Block> {
    val out = mutableListOf<Block>()
    var i = 0
    val para = mutableListOf<String>()
    fun flush() { if (para.isNotEmpty()) { out += Block.Para(para.toList()); para.clear() } }
    while (i < lines.size) {
        val line = lines[i]
        val stripped = line.trimStart()
        val heading = atx.matchEntire(line)
        val marker = listMarker(line)
        when {
            line.isBlank() -> { flush(); i++ }
            stripped.startsWith("```") -> {
                flush()
                val lang = stripped.removePrefix("```").trim().ifEmpty { null }
                val body = StringBuilder()
                i++
                while (i < lines.size && !lines[i].trimStart().startsWith("```")) body.append(lines[i++]).append('\n')
                i++
                out += Block.Code(lang, body.toString())
            }
            heading != null -> { flush(); out += Block.Heading(heading.groupValues[1].length, heading.groupValues[2]); i++ }
            para.isNotEmpty() && isSetextUnderline(line) -> {
                val level = if (line[0] == '=') 1 else 2
                out += Block.Heading(level, para.joinToString(" "))
                para.clear()
                i++
            }
            stripped.length >= 3 && stripped.replace(" ", "").let { s -> s.length >= 3 && s.all { it == s[0] } && s[0] in "-*_" } -> {
                flush(); out += Block.Rule; i++
            }
            stripped.startsWith(">") -> {
                flush()
                val inner = mutableListOf<String>()
                while (i < lines.size && lines[i].trimStart().startsWith(">")) inner += lines[i++].trimStart().removePrefix(">").removePrefix(" ")
                out += Block.Quote(parseBlocks(inner))
            }
            marker != null -> {
                flush()
                val delimiter = marker[2].last()
                val ordered = marker[3].isNotEmpty()
                val start = marker[3].toIntOrNull() ?: 1
                val items = mutableListOf<List<String>>()
                while (i < lines.size) {
                    val m = listMarker(lines[i])
                    if (m != null && m[1] == marker[1] && m[2].last() == delimiter) {
                        items += mutableListOf(m[4]); i++
                    } else if (lines[i].startsWith("  ") && items.isNotEmpty()) {
                        (items.last() as MutableList) += lines[i].drop(if (lines[i].startsWith("    ")) 4 else 2); i++
                    } else if (lines[i].isBlank() && i + 1 < lines.size && (lines[i + 1].startsWith("  ") || listMarker(lines[i + 1]) != null)) {
                        i++
                    } else break
                }
                out += Block.ListBlock(ordered, start, items.map { parseBlocks(it) })
            }
            else -> { para += stripped; i++ }
        }
    }
    flush()
    return out
}

fun escapeHtml(s: String): String = buildString(s.length) {
    for (c in s) when (c) {
        '<' -> append("&lt;")
        '>' -> append("&gt;")
        '&' -> append("&amp;")
        '"' -> append("&quot;")
        else -> append(c)
    }
}

fun inline(src: String): String {
    val sb = StringBuilder()
    var i = 0
    val open = ArrayDeque<String>()
    fun toggle(tag: String) {
        if (open.lastOrNull() == tag) { open.removeLast(); sb.append("</$tag>") } else { open.addLast(tag); sb.append("<$tag>") }
    }
    while (i < src.length) {
        val c = src[i]
        when {
            c == '\\' && i + 1 < src.length && src[i + 1] in "\\`*_[]()#+-.!<>" -> { sb.append(escapeHtml(src[i + 1].toString())); i += 2 }
            c == '`' -> {
                val end = src.indexOf('`', i + 1)
                if (end < 0) { sb.append('`'); i++ } else { sb.append("<code>").append(escapeHtml(src.substring(i + 1, end))).append("</code>"); i = end + 1 }
            }
            (c == '*' || c == '_') && src.startsWith("$c$c", i) -> { toggle("strong"); i += 2 }
            c == '*' || (c == '_' && (i == 0 || !src[i - 1].isLetterOrDigit())) || (c == '_' && open.lastOrNull() == "em") -> { toggle("em"); i++ }
            c == '[' -> {
                val close = src.indexOf("](", i)
                val paren = if (close >= 0) src.indexOf(')', close) else -1
                if (paren < 0) { sb.append('['); i++ } else {
                    val (url, title) = src.substring(close + 2, paren).split(" \"", limit = 2).let { it[0] to it.getOrNull(1)?.removeSuffix("\"") }
                    sb.append("<a href=\"").append(escapeHtml(url)).append('"')
                    title?.let { sb.append(" title=\"").append(escapeHtml(it)).append('"') }
                    sb.append('>').append(inline(src.substring(i + 1, close))).append("</a>")
                    i = paren + 1
                }
            }
            c == '<' && Regex("^<(https?://[^>\\s]+)>").find(src.substring(i)) != null -> {
                val url = Regex("^<(https?://[^>\\s]+)>").find(src.substring(i))!!.groupValues[1]
                sb.append("<a href=\"$url\">$url</a>")
                i += url.length + 2
            }
            c == ' ' && src.startsWith("  ", i) && i + 2 == src.length -> { sb.append("<br>"); i += 2 }
            else -> { sb.append(escapeHtml(c.toString())); i++ }
        }
    }
    while (open.isNotEmpty()) sb.append("</${open.removeLast()}>")
    return sb.toString()
}

class Renderer {
    private val slugs = mutableMapOf<String, Int>()
    val toc = mutableListOf<Triple<Int, String, String>>()

    private fun slug(text: String): String {
        val base = text.lowercase().replace(Regex("[^a-z0-9\\s-]"), "").trim().replace(Regex("\\s+"), "-").ifEmpty { "section" }
        val n = slugs.merge(base, 1, Int::plus)!!
        return if (n == 1) base else "$base-${n - 1}"
    }

    fun render(blocks: List<Block>, tight: Boolean = false): String = buildString {
        for (b in blocks) {
            when (b) {
                is Block.Heading -> {
                    val id = slug(b.text)
                    toc += Triple(b.level, b.text, id)
                    append("<h${b.level} id=\"$id\">${inline(b.text)}</h${b.level}>\n")
                }
                is Block.Para -> {
                    val body = b.lines.joinToString("\n") { inline(it) }
                    if (tight) append(body).append('\n') else append("<p>").append(body).append("</p>\n")
                }
                is Block.Code -> append(if (b.lang != null) "<pre><code class=\"language-${b.lang}\">" else "<pre><code>")
                    .append(escapeHtml(b.body)).append("</code></pre>\n")
                is Block.Quote -> append("<blockquote>\n").append(render(b.children)).append("</blockquote>\n")
                is Block.ListBlock -> {
                    val tag = if (b.ordered) "ol" else "ul"
                    append(if (b.ordered && b.start != 1) "<$tag start=\"${b.start}\">\n" else "<$tag>\n")
                    for (item in b.items) append("<li>").append(render(item, tight = true).trimEnd('\n')).append("</li>\n")
                    append("</$tag>\n")
                }
                Block.Rule -> append("<hr>\n")
            }
        }
    }
}

val doc = """
# Release notes
Version **2.0** brings _many_ changes & fixes.

Setup guide
===========

1. Install with `npm i k2l --save`
2. Configure:
   - set `target` to *5.4*
   - set `strings` to __utf16__
3. Run it

7) seven
8) eight

> **Note:** quotes can hold
> - lists
> - and `code <b>`

```kotlin
fun main() = println("<hi> & bye")
```

* * *

Links: [docs](https://example.com/docs "The docs"), <https://k2l.dev>, and [nested *em*](/x).
Escapes: \*not em\*, snake_case_name, 2 < 3 && 5 > 4.
Line two after a hard break.

## Setup guide
## Ünïcode héading!
""".trimIndent()

fun main() {
    val blocks = parseBlocks(doc.lines())
    println(blocks.map { it::class.simpleName }.groupingBy { it }.eachCount())
    val r = Renderer()
    val html = r.render(blocks)
    print(html)
    println("<nav>")
    for ((level, text, id) in r.toc) println("  ".repeat(level - 1) + "<a href=\"#$id\">" + escapeHtml(text.replace(Regex("[*_`]"), "")) + "</a>")
    println("</nav>")
    println(html.lines().count { it.startsWith("<li>") } to Regex("<(\\w+)").findAll(html).map { it.groupValues[1] }.distinct().sorted().toList())
    println(inline("unclosed **bold and `tick"))
}
