package dev.k2l.transform

/** A Kotlin regex that the Lua-pattern subset cannot express; the message says which construct. */
internal class RegexUnsupported(message: String) : Exception(message)

internal fun regexFail(what: String): Nothing = throw RegexUnsupported("Regex $what")

/**
 * One item of a Lua pattern being built: an [Kind.ATOM] (a single character or class, which a quantifier may follow) or
 * anything else. [word] is true when it matches word characters only (`\w`), [mandatory] when it matches at least one.
 */
internal class Piece(var lua: String, val kind: Kind, val word: Boolean = false, val mandatory: Boolean = true) {
    enum class Kind { ATOM, FIXED, OPEN, CLOSE, BOUNDARY }
}

/** The first code that is not ASCII: a UTF-8 byte of a character of several bytes from here on. */
internal const val NON_ASCII = 0x80
private const val HEX_DIGITS = 2
private const val UNICODE_DIGITS = 4
private const val OCTAL_DIGITS = 3
private const val HEX = 16
private const val OCTAL = 8
private const val CASE_SHIFT = 32

internal fun isWordByte(b: Int): Boolean = b in '0'.code..'9'.code || b in 'a'.code..'z'.code || b in 'A'.code..'Z'.code || b == '_'.code

/** The escapes that stand for one character (`\t`, `\x41`, `\.`), shared by classes and the rest of a pattern. */
internal object RegexEscapes {
    private val CONTROLS = mapOf('t' to '\t', 'n' to '\n', 'r' to '\r', 'f' to '\u000C', 'a' to '\u0007', 'e' to '\u001B')

    /** The character `\c` stands for, with the index after its text (which continues at [at]); null if it is no character escape. */
    fun char(src: String, at: Int, c: Char): Pair<String, Int>? = when {
        c in CONTROLS -> CONTROLS.getValue(c).toString() to at
        c == 'x' -> hex(src, at, HEX_DIGITS)
        c == 'u' -> hex(src, at, UNICODE_DIGITS)
        c == '0' -> octal(src, at)
        c.code < NON_ASCII && c.isLetterOrDigit() -> null
        else -> c.toString() to at
    }

    fun unsupported(c: Char): Nothing = when (c) {
        'p', 'P' -> regexFail("Unicode property `\\$c{...}` is not supported")
        'B' -> regexFail("`\\B` is not supported (Lua's %f frontier only expresses some `\\b`)")
        'k' -> regexFail("named back-reference `\\k<name>` is not supported")
        else -> regexFail("escape `\\$c` is not supported")
    }

    private fun hex(src: String, at: Int, digits: Int): Pair<String, Int> {
        val text = src.substring(at, minOf(at + digits, src.length))
        if (text.length < digits || !text.all { it.isDigit() || it.lowercaseChar() in 'a'..'f' }) {
            regexFail("syntax error: `\\${if (digits == HEX_DIGITS) 'x' else 'u'}` needs $digits hexadecimal digits")
        }
        return String(Character.toChars(text.toInt(HEX))) to at + digits
    }

    private fun octal(src: String, at: Int): Pair<String, Int> {
        var end = at
        while (end < src.length && end < at + OCTAL_DIGITS && src[end] in '0'..'7') end++
        if (end == at) regexFail("syntax error: `\\0` needs an octal digit")
        return String(Character.toChars(src.substring(at, end).toInt(OCTAL))) to end
    }
}

/**
 * A character class `[...]`, read from just after its `[` (its end is then [end]): a Lua class of ASCII bytes, where
 * `\d \D \s \S \w` are Lua's `%d %D %s %S %w_`. With [ignoreCase], the letters of the other case are added.
 */
internal class ClassReader(private val src: String, start: Int, private val ignoreCase: Boolean) {
    var end = start
        private set
    private val ranges = mutableListOf<IntRange>()
    private val escapes = StringBuilder()
    private var word = true

    fun read(): Piece {
        val negated = src.startsWith("^", end)
        if (negated) end++
        var first = true
        while (true) {
            if (end >= src.length) regexFail("syntax error: unclosed character class `[`")
            val c = src[end++]
            if (c == ']' && !first) break
            first = false
            member(c)
        }
        val body = escapes.toString() + ranges.joinToString("") { render(it) }
        val isWord = !negated && word && ranges.all { r -> r.all(::isWordByte) }
        return Piece("[" + (if (negated) "^" else "") + body + "]", Piece.Kind.ATOM, word = isWord)
    }

    private fun member(c: Char) {
        if (c == '[') regexFail("nested character class is not supported")
        if (c == '&' && src.startsWith("&", end)) regexFail("character class intersection `&&` is not supported")
        val lo = single(c) ?: return
        if (src.startsWith("-", end) && end + 1 < src.length && src[end + 1] != ']') {
            end++
            val hi = single(src[end++]) ?: regexFail("syntax error: a class escape cannot end a range")
            if (hi < lo) regexFail("syntax error: illegal character range")
            add(lo..hi)
        } else {
            add(lo..lo)
        }
    }

    /** The byte of a class member, or null for a class escape (`\d`), which is added. */
    private fun single(c: Char): Int? {
        if (c != '\\') return ascii(c.toString())
        if (end >= src.length) regexFail("syntax error: unclosed character class `[`")
        val e = src[end++]
        CLASS_ITEMS[e]?.let {
            escapes.append(it)
            if (e != 'd' && e != 'w') word = false
            return null
        }
        if (e == 'W') regexFail("`\\W` inside a character class is not supported")
        if (e == 'b') regexFail("`\\b` inside a character class is not supported")
        val (ch, next) = RegexEscapes.char(src, end, e) ?: RegexEscapes.unsupported(e)
        end = next
        return ascii(ch)
    }

    private fun ascii(ch: String): Int {
        if (ch.length != 1 || ch[0].code >= NON_ASCII) {
            regexFail("non-ASCII character in a character class is not supported (strings are bytes)")
        }
        return ch[0].code
    }

    private fun add(range: IntRange) {
        ranges += range
        if (!ignoreCase) return
        for ((letters, shift) in listOf('a'.code..'z'.code to -CASE_SHIFT, 'A'.code..'Z'.code to CASE_SHIFT)) {
            val from = maxOf(range.first, letters.first)
            val to = minOf(range.last, letters.last)
            if (from <= to) ranges += (from + shift)..(to + shift)
        }
    }

    private fun render(r: IntRange): String = when {
        r.first == r.last -> classByte(r.first)
        plainEnd(r.first) && plainEnd(r.last) -> "${r.first.toChar()}-${r.last.toChar()}"
        else -> r.joinToString("") { classByte(it) }
    }

    private companion object {
        val CLASS_ITEMS = mapOf('d' to "%d", 'D' to "%D", 's' to "%s", 'S' to "%S", 'w' to "%w_")

        /** A byte Lua reads as a range end: not `%`, `]`, `^` or `-`, which are escaped (and so cannot end a range). */
        fun plainEnd(b: Int) = b != 0 && b.toChar() !in "%]^-"

        fun classByte(b: Int): String = when {
            b == 0 -> "%z"
            b.toChar() in PUNCTUATION -> "%${b.toChar()}"
            else -> b.toChar().toString()
        }

        const val PUNCTUATION = "!\"#$%&'()*+,-./:;<=>?@[\\]^`{|}~"
    }
}
