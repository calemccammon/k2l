package editor.text

/** A cursor position; ordered so selections can be normalized. */
data class Pos(val line: Int, val col: Int) : Comparable<Pos> {
    override fun compareTo(other: Pos) = compareValuesBy(this, other, { it.line }, { it.col })
    override fun toString() = "$line:$col"
}

data class Selection(val anchor: Pos, val head: Pos) {
    val start get() = minOf(anchor, head)
    val end get() = maxOf(anchor, head)
    val isEmpty get() = anchor == head
}

/** A document of lines; mutated only through [Editable]. */
open class Document(text: String = "") {
    protected val lines: MutableList<StringBuilder> = text.split("\n").map { StringBuilder(it) }.toMutableList()
    var revision = 0
        protected set

    val lineCount get() = lines.size

    fun line(i: Int): String = lines[i].toString()

    val text: String get() = lines.joinToString("\n")

    protected fun touch() {
        revision++
    }

    fun clamp(p: Pos): Pos {
        val line = p.line.coerceIn(0, lines.lastIndex)
        return Pos(line, p.col.coerceIn(0, lines[line].length))
    }

    override fun toString(): String = lines.mapIndexed { i, l -> "${(i + 1).toString().padStart(2)}| $l" }.joinToString("\n")
}

/** Operations that change a document; used by commands, which know how to reverse them. */
class Editable(text: String) : Document(text) {
    fun insert(at: Pos, s: String): Pos {
        val p = clamp(at)
        val parts = s.split("\n")
        val rest = lines[p.line].substring(p.col)
        lines[p.line].setLength(p.col)
        lines[p.line].append(parts[0])
        for (i in 1 until parts.size) lines.add(p.line + i, StringBuilder(parts[i]))
        val endLine = p.line + parts.size - 1
        val endCol = if (parts.size == 1) p.col + parts[0].length else parts.last().length
        lines[endLine].append(rest)
        touch()
        return Pos(endLine, endCol)
    }

    fun delete(sel: Selection): String {
        val (start, end) = clamp(sel.start) to clamp(sel.end)
        val removed = extract(start, end)
        val tail = lines[end.line].substring(end.col)
        lines[start.line].setLength(start.col)
        lines[start.line].append(tail)
        repeat(end.line - start.line) { lines.removeAt(start.line + 1) }
        touch()
        return removed
    }

    fun extract(start: Pos, end: Pos): String = if (start.line == end.line) {
        lines[start.line].substring(start.col, end.col)
    } else {
        buildString {
            append(lines[start.line].substring(start.col))
            for (l in start.line + 1 until end.line) append('\n').append(lines[l])
            append('\n').append(lines[end.line].substring(0, end.col))
        }
    }

    fun endOf(start: Pos, s: String): Pos {
        val parts = s.split("\n")
        return if (parts.size == 1) Pos(start.line, start.col + s.length) else Pos(start.line + parts.size - 1, parts.last().length)
    }
}
