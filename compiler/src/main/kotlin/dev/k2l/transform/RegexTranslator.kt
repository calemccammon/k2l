package dev.k2l.transform

import dev.k2l.transform.Piece.Kind

/**
 * Kotlin regexes as Lua patterns: the subset of the regex syntax that maps onto them, translated from the constant pattern
 * of every Regex. Anything else is a [RegexUnsupported] naming the construct.
 */
internal object RegexTranslator {
    private val OPTIONS = setOf("IGNORE_CASE", "LITERAL", "DOT_MATCHES_ALL", "UNIX_LINES")
    private const val MAGIC = "^$()%.[]*+-?"

    /** The Lua pattern of [source] with the RegexOption names [options]. */
    fun translate(source: String, options: Set<String> = emptySet()): String {
        options.firstOrNull { it !in OPTIONS }?.let { regexFail("option $it is not supported") }
        val ignoreCase = "IGNORE_CASE" in options
        if ("LITERAL" in options) return source.map { literal(it, ignoreCase) }.joinToString("")
        val dot = when {
            "DOT_MATCHES_ALL" in options -> "."
            "UNIX_LINES" in options -> "[^\n]"
            else -> "[^\n\r]"
        }
        val inlineCase = source.startsWith("(?i)")
        return PatternReader(source.removePrefix("(?i)"), ignoreCase || inlineCase, dot).read()
    }

    /** Kotlin's Regex.escape: the literal quoted as `\Q...\E`. */
    fun escape(literal: String): String = "\\Q" + literal.replace("\\E", "\\E\\\\E\\Q") + "\\E"

    /** Kotlin's Regex.escapeReplacement: `\` and `$` escaped with a backslash. */
    fun escapeReplacement(literal: String): String = literal.replace("\\", "\\\\").replace("$", "\\$")

    /** The Lua pattern item of a literal ASCII character. */
    fun literal(c: Char, ignoreCase: Boolean): String = when {
        ignoreCase && (c in 'a'..'z' || c in 'A'..'Z') -> "[${c.lowercaseChar()}${c.uppercaseChar()}]"
        c == '\u0000' -> "%z"
        c in MAGIC -> "%$c"
        else -> c.toString()
    }
}

/** Reads a regex (without a leading `(?i)`) into [pieces]. */
private class PatternReader(private val src: String, private val ignoreCase: Boolean, private val dot: String) {
    private var i = 0
    private val pieces = Pieces()
    private var groups = 0
    private val open = ArrayDeque<Int>()
    private val closed = mutableSetOf<Int>()

    fun read(): String {
        while (i < src.length) step(src[i++])
        if (open.isNotEmpty()) regexFail("syntax error: unclosed group `(`")
        return pieces.render()
    }

    private fun step(c: Char) {
        when (c) {
            '\\' -> escape()
            '[' -> ClassReader(src, i, ignoreCase).let { r -> pieces.add(r.read()).also { i = r.end } }
            '(' -> openGroup()
            ')' -> closeGroup()
            '*', '+', '?' -> pieces.quantify(c, suffix(c.toString()))
            '{' -> repetition()
            '|' -> regexFail("alternation `|` is not supported (Lua patterns have no alternation)")
            '^' -> anchor("^", i == 1, "the start")
            '$' -> anchor("$", i == src.length, "the end")
            '.' -> pieces.add(Piece(dot, Kind.ATOM))
            else -> literalChar(c)
        }
    }

    /** A literal character: an ASCII one is an item a quantifier may follow, a non-ASCII one (several bytes) is not. */
    private fun literalChar(c: Char) {
        if (c.code < NON_ASCII) {
            pieces.add(Piece(RegexTranslator.literal(c, ignoreCase), Kind.ATOM, word = isWordByte(c.code)))
        } else {
            pieces.add(Piece(c.toString(), Kind.FIXED))
        }
    }

    private fun escape() {
        if (i >= src.length) regexFail("syntax error: a pattern cannot end with `\\`")
        val c = src[i++]
        val item = ESCAPE_ITEMS[c]
        when {
            item != null -> pieces.add(Piece(item, Kind.ATOM, word = c == 'd' || c == 'w'))

            c == 'b' -> pieces.add(Piece("", Kind.BOUNDARY))

            c == 'Q' -> quoted()

            c in '1'..'9' -> backReference(c - '0')

            else -> {
                val (text, next) = RegexEscapes.char(src, i, c) ?: RegexEscapes.unsupported(c)
                i = next
                text.forEach(::literalChar)
            }
        }
    }

    /** `\Q...\E`: the text up to `\E` (or the end) is literal. */
    private fun quoted() {
        val end = src.indexOf("\\E", i).let { if (it < 0) src.length else it }
        src.substring(i, end).forEach(::literalChar)
        i = minOf(end + 2, src.length)
    }

    private fun backReference(n: Int) {
        if (n !in closed) regexFail("back-reference `\\$n` to a group that is not closed before it is not supported")
        pieces.add(Piece("%$n", Kind.FIXED))
    }

    private fun anchor(lua: String, allowed: Boolean, where: String) {
        if (!allowed) regexFail("anchor `$lua` is only supported at $where of the pattern (as in Lua)")
        pieces.add(Piece(lua, Kind.FIXED))
    }

    private fun openGroup() {
        if (src.startsWith("?", i)) regexFail(groupConstruct(src.substring(i)))
        if (src.startsWith(")", i)) regexFail("empty group `()` is not supported (in Lua it captures a position)")
        if (++groups > MAX_GROUPS) regexFail("with more than $MAX_GROUPS groups is not supported")
        open.addLast(groups)
        pieces.add(Piece("(", Kind.OPEN))
    }

    private fun closeGroup() {
        if (open.isEmpty()) regexFail("syntax error: unmatched `)`")
        closed += open.removeLast()
        pieces.add(Piece(")", Kind.CLOSE))
    }

    /** Whether the quantifier [q] just read is lazy (a `?` follows); a possessive one (`+` follows) is an error. */
    private fun suffix(q: String): Boolean = when {
        src.startsWith("?", i) -> true.also { i++ }
        src.startsWith("+", i) -> regexFail("possessive quantifier `$q+` is not supported")
        else -> false
    }

    /** `{n}`, `{n,}` and `{n,m}`, expanded into copies of the item. */
    private fun repetition() {
        val m = REPEAT.matchAt(src, i - 1) ?: regexFail("syntax error: a `{` that does not start a {n,m} repetition must be escaped")
        i = m.range.last + 1
        val lazy = suffix(m.value)
        val min = m.groupValues[1].toInt()
        val max = if (m.groupValues[2].isEmpty()) min else m.groupValues[3].toIntOrNull()
        if (max != null && max < min) regexFail("syntax error: illegal repetition ${m.value}")
        if ((max ?: min) > MAX_REPEAT) regexFail("repetition ${m.value} above $MAX_REPEAT is not supported (it is expanded)")
        if (lazy && max != null && max != min) regexFail("lazy repetition `${m.value}?` is not supported")
        pieces.repeat(m.value, min, max, lazy)
    }

    private companion object {
        const val MAX_GROUPS = 32
        const val MAX_REPEAT = 20
        val REPEAT = Regex("""\{(\d+)(,(\d*))?}""")
        val ESCAPE_ITEMS = mapOf('d' to "%d", 'D' to "%D", 's' to "%s", 'S' to "%S", 'w' to "[%w_]", 'W' to "[^%w_]")
    }
}

private fun groupConstruct(rest: String): String = when {
    rest.startsWith("?:") -> "non-capturing group `(?:...)` is not supported"

    rest.startsWith("?=") || rest.startsWith("?!") || rest.startsWith("?<=") || rest.startsWith("?<!") ->
        "lookaround `(?=...)`, `(?!...)`, `(?<=...)` or `(?<!...)` is not supported"

    rest.startsWith("?<") -> "named group `(?<name>...)` is not supported"

    rest.startsWith("?>") -> "atomic group `(?>...)` is not supported"

    else -> "inline flags `(?...)` are not supported (only a leading `(?i)` is)"
}

/** The items of a pattern, with the quantifiers applied to them and the `\b` among them made Lua frontiers. */
private class Pieces {
    private val list = mutableListOf<Piece>()

    fun add(piece: Piece) {
        list += piece
    }

    /** `*`, `+` and `?` (and lazily, `*?` and `+?`) on the last item. */
    fun quantify(q: Char, lazy: Boolean) {
        val atom = lastAtom(q.toString())
        list[list.lastIndex] = when (q) {
            '*' -> Piece(atom.lua + if (lazy) "-" else "*", Kind.FIXED, atom.word, mandatory = false)
            '+' -> Piece(if (lazy) atom.lua + atom.lua + "-" else atom.lua + "+", Kind.FIXED, atom.word)
            else -> if (lazy) regexFail("lazy quantifier `??` is not supported") else Piece(atom.lua + "?", Kind.FIXED, atom.word, false)
        }
    }

    /** A repetition `{min,max}` (no [max]: `{min,}`) of the last item. */
    fun repeat(q: String, min: Int, max: Int?, lazy: Boolean) {
        val atom = lastAtom(q)
        val rest = if (max == null) atom.lua + (if (lazy) "-" else "*") else (atom.lua + "?").repeat(max - min)
        list[list.lastIndex] = Piece(atom.lua.repeat(min) + rest, Kind.FIXED, atom.word, mandatory = min > 0)
    }

    private fun lastAtom(q: String): Piece {
        val last = list.lastOrNull()
        return when {
            last == null -> regexFail("syntax error: dangling quantifier `$q`")

            last.kind == Kind.CLOSE -> regexFail(
                "quantifier on a group is not supported (Lua quantifies single characters and classes only)",
            )

            last.lua.any { it.code >= NON_ASCII } -> regexFail("quantifier on a non-ASCII character is not supported (it is several bytes)")

            last.kind != Kind.ATOM -> regexFail("quantifier `$q` is only supported on a single character or class")

            else -> last
        }
    }

    fun render(): String {
        for ((k, p) in list.withIndex()) {
            if (p.kind != Kind.BOUNDARY) continue
            p.lua = when {
                neighbour(k, 1)?.let { it.word && it.mandatory } == true -> "%f[%w_]"
                neighbour(k, -1)?.let { it.word && it.mandatory } == true -> "%f[^%w_]"
                else -> regexFail(BOUNDARY)
            }
        }
        return list.joinToString("") { it.lua }
    }

    /** The item next to the one at [k] in the direction [step], past group parentheses. */
    private fun neighbour(k: Int, step: Int): Piece? {
        var j = k + step
        while (list.getOrNull(j)?.kind.let { it == Kind.OPEN || it == Kind.CLOSE }) j += step
        return list.getOrNull(j)
    }

    private companion object {
        const val BOUNDARY = "`\\b` is only supported before or after a word character (\\w, a letter, a digit or _), " +
            "where Lua's %f frontier can express it"
    }
}
