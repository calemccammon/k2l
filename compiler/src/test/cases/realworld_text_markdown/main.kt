// A small Markdown-to-HTML converter: headings with slugs, paragraphs, emphasis, inline code, links,
// images, ordered and unordered lists, block quotes, fenced code, horizontal rules, tables and a TOC. The regexes stay
// within what Lua patterns express: alternatives and look-arounds are separate patterns and checks in Kotlin.

fun escapeHtml(s: String): String = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")

fun slug(text: String): String = text.lowercase()
    .replace(Regex("[^a-z0-9\\s-]"), "")
    .trim()
    .replace(Regex("\\s+"), "-")

private val CODE_SPAN = Regex("`([^`]+)`")
private val IMAGE = Regex("""!\[([^\]]*)]\(([^)\s]+)\)""")
private val LINK = Regex("""\[([^\]]+)]\(([^)\s]+)\)""")
private val STRONG = listOf(Regex("""\*\*(.+?)\*\*"""), Regex("""__(.+?)__"""))
private val EM = listOf(Regex("""\*(\S[^*]*)\*"""), Regex("""_([^_]+)_"""))
private val AUTOLINK = Regex("""<(https?://[^>]+)>""")
private val STRIKE = Regex("~~(.+?)~~")

fun inline(text: String): String {
    // protect code spans from the other rules
    val codes = mutableListOf<String>()
    var s = CODE_SPAN.replace(text) { m ->
        codes += "<code>" + escapeHtml(m.groupValues[1]) + "</code>"
        "\u0000${codes.size - 1}\u0000"
    }
    s = AUTOLINK.replace(s) { "<a href=\"${it.groupValues[1]}\">${it.groupValues[1]}</a>" }
    s = escapeHtml(s).replace("&lt;a href=&quot;", "<a href=\"").replace("&quot;&gt;", "\">").replace("&lt;/a&gt;", "</a>")
    s = IMAGE.replace(s) { m ->
        val (alt, src) = m.destructured
        "<img src=\"$src\" alt=\"$alt\">"
    }
    s = LINK.replace(s, "<a href=\"$2\">$1</a>")
    for (strong in STRONG) s = strong.replace(s, "<strong>$1</strong>")
    for (em in EM) s = emphasis(s, em)
    s = STRIKE.replace(s, "<del>$1</del>")
    return Regex("\u0000(\\d+)\u0000").replace(s) { codes[it.groupValues[1].toInt()] }
}

fun isWordChar(c: Char?) = c != null && (c.isLetterOrDigit() || c == '_')

/** `*text*` or `_text_` as <em>: not inside a word (nor next to another `*`), and not with a blank before the closing mark. */
fun emphasis(s: String, em: Regex): String = em.replace(s) { m ->
    val mark = m.value[0]
    val before = s.getOrNull(m.range.first - 1)
    val after = s.getOrNull(m.range.last + 1)
    val body = m.groupValues[1]
    val inWord = isWordChar(before) || before == mark || after == mark || (mark == '_' && isWordChar(after))
    if (inWord || body.last().isWhitespace()) m.value else "<em>$body</em>"
}

fun isRule(line: String) = listOf('*', '-').any { c -> line.firstOrNull() == c && line.count { it == c } >= 3 && line.all { it == c || it.isWhitespace() } }

private val SEPARATOR_CELL = Regex(""":?-+:?""")

fun isSeparator(row: String) = row.trim().removePrefix("|").removeSuffix("|").split("|").all { it.trim().matches(SEPARATOR_CELL) }

private val BULLET = Regex("""^\s*[-*+] (.*)$""")
private val NUMBERED = Regex("""^\s*\d+[.)] (.*)$""")
private val CHECKBOX = Regex("""^\[[ xX]] """)

/** The text of a list item line, or null. */
fun listItem(line: String): String? = (BULLET.matchEntire(line) ?: NUMBERED.matchEntire(line))?.groupValues?.get(1)

data class Heading(val level: Int, val text: String, val id: String)

class Converter {
    val headings = mutableListOf<Heading>()
    private val out = StringBuilder()
    private val usedIds = HashMap<String, Int>()

    private fun uniqueId(base: String): String {
        val n = usedIds.merge(base, 1, Int::plus)!!
        return if (n == 1) base else "$base-${n - 1}"
    }

    fun convert(md: String): String {
        val lines = md.lines()
        var i = 0
        while (i < lines.size) {
            val line = lines[i]
            when {
                line.isBlank() -> i++
                line.startsWith("```") -> {
                    val lang = line.removePrefix("```").trim()
                    val body = mutableListOf<String>()
                    i++
                    while (i < lines.size && !lines[i].startsWith("```")) body += lines[i++]
                    i++
                    val cls = if (lang.isEmpty()) "" else " class=\"language-$lang\""
                    out.append("<pre><code$cls>").append(escapeHtml(body.joinToString("\n"))).append("</code></pre>\n")
                }
                Regex("^#{1,6} ").containsMatchIn(line) -> {
                    val level = line.takeWhile { it == '#' }.length
                    val text = line.drop(level).trim().trimEnd('#').trim()
                    val id = uniqueId(slug(text))
                    headings += Heading(level, text, id)
                    out.append("<h$level id=\"$id\">${inline(text)}</h$level>\n")
                    i++
                }
                isRule(line) -> {
                    out.append("<hr>\n")
                    i++
                }
                line.startsWith(">") -> {
                    val quoted = mutableListOf<String>()
                    while (i < lines.size && lines[i].startsWith(">")) quoted += lines[i++].removePrefix(">").removePrefix(" ")
                    out.append("<blockquote>\n").append(Converter().convert(quoted.joinToString("\n"))).append("</blockquote>\n")
                }
                line.contains('|') && i + 1 < lines.size && isSeparator(lines[i + 1]) -> {
                    fun cells(row: String) = row.trim().removePrefix("|").removeSuffix("|").split("|").map { it.trim() }
                    val header = cells(line)
                    val aligns = cells(lines[i + 1]).map {
                        when {
                            it.startsWith(":") && it.endsWith(":") -> " style=\"text-align:center\""
                            it.endsWith(":") -> " style=\"text-align:right\""
                            else -> ""
                        }
                    }
                    i += 2
                    out.append("<table>\n<tr>")
                    header.forEachIndexed { c, h -> out.append("<th${aligns.getOrElse(c) { "" }}>${inline(h)}</th>") }
                    out.append("</tr>\n")
                    while (i < lines.size && lines[i].contains('|')) {
                        out.append("<tr>")
                        cells(lines[i]).forEachIndexed { c, v -> out.append("<td${aligns.getOrElse(c) { "" }}>${inline(v)}</td>") }
                        out.append("</tr>\n")
                        i++
                    }
                    out.append("</table>\n")
                }
                listItem(line) != null -> {
                    val ordered = line.trimStart().first().isDigit()
                    val start = if (ordered) line.trim().takeWhile { it.isDigit() }.toInt() else 1
                    val tag = if (ordered) "ol" else "ul"
                    out.append(if (ordered && start != 1) "<ol start=\"$start\">\n" else "<$tag>\n")
                    while (i < lines.size) {
                        val text = listItem(lines[i]) ?: break
                        val check = CHECKBOX.find(text)?.value.orEmpty()
                        val box = when {
                            check.isEmpty() -> ""
                            check[1] == ' ' -> "<input type=\"checkbox\" disabled> "
                            else -> "<input type=\"checkbox\" checked disabled> "
                        }
                        out.append("  <li>").append(box).append(inline(text.removePrefix(check))).append("</li>\n")
                        i++
                    }
                    out.append("</$tag>\n")
                }
                else -> {
                    val para = mutableListOf<String>()
                    while (i < lines.size && lines[i].isNotBlank() && !lines[i].startsWith("#") && !lines[i].startsWith("```") &&
                        !lines[i].startsWith(">")
                    ) {
                        para += lines[i++].trim()
                    }
                    val joined = para.joinToString("\n").replace(Regex(" {2,}\n"), "<br>\n")
                    out.append("<p>").append(inline(joined)).append("</p>\n")
                }
            }
        }
        return out.toString()
    }
}

fun toc(headings: List<Heading>): String = buildString {
    val minLevel = headings.minOfOrNull { it.level } ?: 1
    for (h in headings) {
        append("  ".repeat(h.level - minLevel)).append("- [").append(h.text).append("](#").append(h.id).append(")\n")
    }
}

val DOCUMENT = """
# k2l *Guide*

Welcome to **k2l**, a _Kotlin_ to Lua transpiler. See <https://example.org/k2l> or [the docs](https://example.org/docs).
Use `x < y && y > z` freely; it's ~~not~~ escaped.
Second line after a hard break.

## Installing

1. Download the archive
2. Unpack it to `~/opt`
3. Add **bin** to `PATH`

## Features & Limits

- [x] classes and *objects*
- [ ] reflection beyond the __basics__
* plain item with an ![logo](img/logo.png "The Logo") inside

> Note: quotes can contain **markup**
> and span lines.
>
> # Even headings

| Feature | Status | Since |
|:--------|:------:|------:|
| Regex   | done   | 0.1 |
| Streams | `partial` | 0.2 |

```kotlin
fun main() = println("<hello>")
```

***

## Installing

5) fifth
6) sixth

Snake_case_words and 2*3*4 should stay as they are, but *this* is emphasis.
""".trimIndent()

fun main() {
    val c = Converter()
    val html = c.convert(DOCUMENT)
    print(html)
    println("---- toc ----")
    print(toc(c.headings))
    val words = Regex("<[^>]+>").replace(html, " ").split(Regex("\\W+")).filter { it.isNotEmpty() }
    println("words: ${words.size}, distinct: ${words.map { it.lowercase() }.toSet().size}")
    println("tags: " + Regex("<(\\w+)").findAll(html).groupingBy { it.groupValues[1] }.eachCount().toSortedMap())
}
