package dev.k2l.codegen

/**
 * Cuts the runtime down to what a program uses. Each feature is split into its top-level statements (and those of its
 * `do` blocks). A statement can define locals (`local function f`, `local a, b = ...`, `f = ...`), define members of a
 * table (`function C:m()`, `C.m = ...`), or belong to a table it changes (`C[key] = ...`, a call with the table as its
 * first argument such as `setmetatable(C, ...)`, an alias `local X = C`).
 *
 * Starting from the names the program's code uses, a statement is kept when kept code refers to a local it defines, when
 * it defines a member of a kept table whose name kept code or the program's code uses (`x.m`, `x:m()`, `"m"`) or which
 * starts with `__` (metamethods and fields such as `____name`), or when it belongs to a kept table. Any other statement
 * (a loop, an `if`) is always kept, so a table the runtime fills when it loads is built in a function
 * (`local T = (function() ... end)()`). Members match by name only, whatever table they are read from, so a method the
 * runtime or the program looks up by a name it got elsewhere (`cls[key]`) is kept as long as that name appears somewhere.
 */
internal object LualibPruning {
    /** One statement of a feature, with what it defines and uses; a `do` block has [children] between [text] and [footer]. */
    class Statement(
        val text: String,
        val locals: Set<String>,
        val members: List<Pair<String, String>>,
        val owner: String?,
        val names: Set<String>,
        val keys: Set<String>,
        val children: List<Statement>? = null,
        val footer: String = "",
    )

    /** The names and the member names some code uses. */
    class Uses(val names: Set<String>, val keys: Set<String>)

    /** What the generated files [code] use. */
    fun uses(code: Collection<String>): Uses {
        val tokens = code.map { Lexer(it).tokens() }
        return Uses(tokens.flatMapTo(HashSet(), ::referencedNames), tokens.flatMapTo(HashSet(), ::memberKeys))
    }

    /** The kept part of each code in [features] (in the same order), for code that uses [uses] and the runtime [roots]. */
    fun prune(features: List<List<Statement>>, uses: Uses, roots: Collection<String>): List<String> {
        val all = features.flatMap(::flatten)
        val defined = all.flatMapTo(HashSet()) { it.locals }
        val needed = HashSet(uses.names).apply { addAll(roots) }
        val keys = HashSet(uses.keys)
        val kept = HashSet<Statement>()
        fun keeps(s: Statement): Boolean = when {
            s.locals.any { it in needed } -> true
            s.members.any { (table, key) -> table !in defined || (table in needed && (key in keys || key.startsWith("__"))) } -> true
            s.owner != null -> s.owner !in defined || s.owner in needed
            else -> s.locals.isEmpty() && s.members.isEmpty()
        }
        do {
            var changed = false
            for (s in all) {
                if (s !in kept && keeps(s)) {
                    kept += s
                    needed += s.names
                    keys += s.keys
                    changed = true
                }
            }
        } while (changed)
        return features.map { statements -> buildString { statements.forEach { emit(it, kept) } }.trimEnd() }
    }

    private fun flatten(statements: List<Statement>): List<Statement> = statements.flatMap { s -> s.children?.let(::flatten) ?: listOf(s) }

    private fun StringBuilder.emit(s: Statement, kept: Set<Statement>) {
        val children = s.children
        if (children == null) {
            if (s in kept) append(s.text)
        } else if (flatten(children).any { it in kept }) {
            append(s.text)
            children.forEach { emit(it, kept) }
            append(s.footer)
        }
    }

    /** [code]'s top-level statements; concatenated, their text is [code] up to trailing comments. */
    fun statements(code: String): List<Statement> {
        val tokens = Lexer(code).tokens()
        return Splitter(code, tokens).split(0, tokens.size, 0).first
    }

    private enum class Kind { NAME, STRING, OTHER }

    /** A token; the [text] of a string is its contents. */
    private class Token(val kind: Kind, val text: String, val start: Int, val end: Int) {
        fun isName(word: String) = kind == Kind.NAME && text == word
        fun isOp(op: String) = kind == Kind.OTHER && text == op
    }

    private val KEYWORDS = setOf(
        "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not",
        "or", "repeat", "return", "then", "true", "until", "while",
    )
    private val OPERATORS = listOf("...", "..", "==", "~=", "<=", ">=", "//", "<<", ">>", "::")
    private val BINARY = setOf("+", "-", "*", "/", "%", "^", "..", "==", "~=", "<", ">", "<=", ">=", "//", "&", "|", "~", "<<", ">>")
    private val CONTINUATIONS = BINARY + setOf(".", ":", "(", "[", "{", "=", ",")
    private val IDENTIFIER = Regex("[A-Za-z_][A-Za-z0-9_]*")

    /** How a token changes the nesting of blocks and brackets (a loop's `do` opens its block). */
    private val DEPTH = mapOf(
        "function" to 1, "if" to 1, "do" to 1, "repeat" to 1, "(" to 1, "[" to 1, "{" to 1,
        "end" to -1, "until" to -1, ")" to -1, "]" to -1, "}" to -1,
    )

    private fun nesting(t: Token): Int = if (t.kind == Kind.STRING) 0 else DEPTH[t.text] ?: 0

    /** In a pattern of tokens, any name that is no keyword, and any string. */
    private const val NAME = "<name>"
    private const val STRING = "<string>"

    private fun List<Token>.startsWith(vararg pattern: String): Boolean = pattern.size <= size && pattern.indices.all { i ->
        val t = this[i]
        when (pattern[i]) {
            NAME -> t.kind == Kind.NAME && t.text !in KEYWORDS
            STRING -> t.kind == Kind.STRING
            else -> t.kind != Kind.STRING && t.text == pattern[i]
        }
    }

    private class Lexer(private val code: String) {
        private val out = ArrayList<Token>()
        private var i = 0

        fun tokens(): List<Token> {
            while (i < code.length) next()
            return out
        }

        private fun next() {
            val c = code[i]
            when {
                c.isWhitespace() -> i++
                code.startsWith("--", i) -> i = commentEnd()
                longBracket(i) >= 0 -> longString()
                c == '"' || c == '\'' -> quoted(c)
                c.isLetter() || c == '_' -> add(Kind.NAME, scan { it.isLetterOrDigit() || it == '_' })
                c.isDigit() -> add(Kind.OTHER, scan { it.isLetterOrDigit() || it == '.' || (it in "+-" && code[i - 1] in "eEpP") })
                else -> add(Kind.OTHER, i + (OPERATORS.firstOrNull { code.startsWith(it, i) }?.length ?: 1))
            }
        }

        private fun add(kind: Kind, end: Int, text: String = code.substring(i, end)) {
            out += Token(kind, text, i, end)
            i = end
        }

        /** Where the run of characters from the current one that match [part] ends. */
        private fun scan(part: (Char) -> Boolean): Int {
            val start = i
            while (i < code.length && part(code[i])) i++
            return i.also { i = start }
        }

        private fun commentEnd(): Int {
            val level = longBracket(i + 2)
            if (level >= 0) return closeLong(i + 2, level)
            return code.indexOf('\n', i).let { if (it < 0) code.length else it }
        }

        private fun longString() {
            val level = longBracket(i)
            val end = closeLong(i, level)
            val open = level + 2
            add(Kind.STRING, end, code.substring(i + open, maxOf(i + open, end - open)))
        }

        private fun quoted(quote: Char) {
            var j = i + 1
            while (j < code.length && code[j] != quote) j += if (code[j] == '\\') 2 else 1
            add(Kind.STRING, minOf(j + 1, code.length), code.substring(i + 1, minOf(j, code.length)))
        }

        /** The level of the long bracket `[==[` at [at], or -1. */
        private fun longBracket(at: Int): Int {
            if (code.getOrNull(at) != '[') return -1
            var j = at + 1
            while (code.getOrNull(j) == '=') j++
            return if (code.getOrNull(j) == '[') j - at - 1 else -1
        }

        private fun closeLong(at: Int, level: Int): Int {
            val close = "]" + "=".repeat(level) + "]"
            val found = code.indexOf(close, at + level + 2)
            return if (found < 0) code.length else found + close.length
        }
    }

    /** Names that are no keywords and no member names (`x.m`). */
    private fun referencedNames(tokens: List<Token>): Set<String> = tokens.indices
        .filter { tokens[it].kind == Kind.NAME && tokens[it].text !in KEYWORDS && !isMemberName(tokens, it) }
        .mapTo(HashSet()) { tokens[it].text }

    /** Member names: `x.m`, `x:m()`, and any string literal that is an identifier (`x["m"]`, `rawget(x, "m")`). */
    private fun memberKeys(tokens: List<Token>): Set<String> = tokens.indices
        .filter { isMemberName(tokens, it) || (tokens[it].kind == Kind.STRING && IDENTIFIER.matches(tokens[it].text)) }
        .mapTo(HashSet()) { tokens[it].text }

    private fun isMemberName(tokens: List<Token>, i: Int) =
        tokens[i].kind == Kind.NAME && i > 0 && (tokens[i - 1].isOp(".") || tokens[i - 1].isOp(":"))

    /** What a statement defines. */
    private class Definitions(range: List<Token>) {
        val locals = HashSet<String>()
        val members = ArrayList<Pair<String, String>>()
        var owner: String? = null

        init {
            val method = range.startsWith("function", NAME, ".", NAME) || range.startsWith("function", NAME, ":", NAME)
            when {
                range.startsWith("local", "function", NAME) -> locals += range[2].text
                range.startsWith("local") -> local(range)
                method -> members += member(range, 1)
                range.startsWith("function", NAME) -> locals += range[1].text
                range.startsWith(NAME) -> assignmentOrCall(range)
            }
        }

        /** `local a, b = ...`; an alias `local X = C` belongs to `C`, whose members can be defined through it. */
        private fun local(range: List<Token>) {
            val names = topLevel(range).firstOrNull { range[it].isOp("=") }?.let { range.subList(1, it) } ?: range.drop(1)
            names.filter { it.kind == Kind.NAME }.forEach { locals += it.text }
            val value = range.drop(names.size + 1)
            if (value.size == 2 && value.startsWith("=", NAME)) owner = value[1].text
        }

        /** `A.b = ...` or `f(A, ...)`; any other call is kept. */
        private fun assignmentOrCall(range: List<Token>) {
            val assign = topLevel(range).firstOrNull { range[it].isOp("=") }
            if (assign != null) {
                targets(range.subList(0, assign)).forEach(::target)
            } else if (range.startsWith(NAME, "(", NAME, ",") || range.startsWith(NAME, "(", NAME, ")")) {
                owner = range[2].text
            }
        }

        private fun target(target: List<Token>) {
            when {
                target.size == 1 -> locals += target[0].text
                target.startsWith(NAME, ".", NAME) || target.startsWith(NAME, "[", STRING, "]") -> members += member(target, 0)
                else -> owner = target[0].text
            }
        }

        /** The table and the member name of `A.b`, `A:b` or `A["b"]` at [at]. */
        private fun member(range: List<Token>, at: Int) = range[at].text to range[at + 2].text

        /** Indices of the tokens of [range] outside any bracket or block. */
        private fun topLevel(range: List<Token>): List<Int> {
            val out = ArrayList<Int>()
            var depth = 0
            for ((k, t) in range.withIndex()) {
                if (depth == 0) out += k
                depth += nesting(t)
            }
            return out
        }

        /** The comma-separated assignment targets in [lhs]. */
        private fun targets(lhs: List<Token>): List<List<Token>> {
            val commas = topLevel(lhs).filter { lhs[it].isOp(",") }
            return (listOf(-1) + commas).zip(commas + lhs.size).map { (a, b) -> lhs.subList(a + 1, b) }
        }
    }

    private class Splitter(val code: String, val tokens: List<Token>) {
        /** The statements of tokens [from] until [to], whose text starts at [textStart]; also where their text ends. */
        fun split(from: Int, to: Int, textStart: Int): Pair<List<Statement>, Int> {
            val out = ArrayList<Statement>()
            var start = textStart
            var i = from
            while (i < to) {
                val last = statementEnd(i, to)
                val end = lineEnd(tokens[last].end)
                out += statement(i, last, start, end)
                start = end
                i = last + 1
            }
            return out to start
        }

        /** The last token of the statement starting at [from]: where every block and bracket is closed and the line ends. */
        private fun statementEnd(from: Int, to: Int): Int {
            var depth = 0
            // `while` and `for` up to their `do`, where a line break does not end the statement
            var loopHeads = 0
            for (j in from until to) {
                val t = tokens[j]
                if (t.isName("while") || t.isName("for")) loopHeads++
                if (t.isName("do") && loopHeads > 0) loopHeads--
                depth += nesting(t)
                val closed = depth == 0 && loopHeads == 0
                if (closed && (j + 1 == to || endsLine(j))) return j
            }
            return to - 1
        }

        /** Whether the statement ends after token [j], which ends a line. */
        private fun endsLine(j: Int): Boolean {
            val last = tokens[j]
            val next = tokens[j + 1]
            if (!lineBreak(last, next)) return false
            val open = when (last.kind) {
                Kind.OTHER -> last.text in BINARY || last.text == "=" || last.text == ","
                Kind.NAME -> last.text in setOf("and", "or", "not", "local")
                Kind.STRING -> false
            }
            val goesOn = when (next.kind) {
                Kind.OTHER -> next.text in CONTINUATIONS
                Kind.NAME -> next.text == "and" || next.text == "or"
                Kind.STRING -> true
            }
            return !open && !goesOn
        }

        private fun lineBreak(a: Token, b: Token): Boolean = code.indexOf('\n', a.end) in a.end until b.start

        private fun lineEnd(offset: Int): Int = code.indexOf('\n', offset).let { if (it < 0) code.length else it + 1 }

        private fun statement(first: Int, last: Int, textStart: Int, textEnd: Int): Statement {
            if (isBlock(first, last)) {
                val bodyStart = lineEnd(tokens[first].end)
                val (children, childrenEnd) = split(first + 1, last, bodyStart)
                val header = code.substring(textStart, bodyStart)
                return Statement(
                    header,
                    emptySet(),
                    emptyList(),
                    null,
                    emptySet(),
                    emptySet(),
                    children,
                    code.substring(childrenEnd, textEnd),
                )
            }
            val range = tokens.subList(first, last + 1)
            val d = Definitions(range)
            return Statement(code.substring(textStart, textEnd), d.locals, d.members, d.owner, referencedNames(range), memberKeys(range))
        }

        /** A `do ... end` block with `do` and `end` on lines of their own. */
        private fun isBlock(first: Int, last: Int): Boolean {
            val ownLines = last > first + 1 && lineBreak(tokens[first], tokens[first + 1]) && lineBreak(tokens[last - 1], tokens[last])
            return tokens[first].isName("do") && tokens[last].isName("end") && ownLines
        }
    }
}
