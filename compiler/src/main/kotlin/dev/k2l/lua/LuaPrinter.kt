package dev.k2l.lua

/** Renders a [LuaChunk] as readable Lua source. */
@Suppress("TooManyFunctions") // one small method per Lua construct; splitting would scatter the printer
class LuaPrinter(private val indentUnit: String = "    ") {
    private val out = StringBuilder()
    private var indent = 0

    fun print(chunk: LuaChunk): String {
        out.clear()
        printBlock(chunk.body, topLevel = true)
        return out.toString()
    }

    private fun line(text: String) {
        repeat(indent) { out.append(indentUnit) }
        out.append(text).append('\n')
    }

    private fun blankLine() {
        if (out.isNotEmpty() && !out.endsWith("\n\n")) out.append('\n')
    }

    private fun nested(body: List<LuaStmt>) {
        indent++
        printBlock(body, topLevel = false)
        indent--
    }

    private fun printBlock(body: List<LuaStmt>, topLevel: Boolean) {
        body.forEachIndexed { i, stmt ->
            val isLast = i == body.lastIndex
            // Top-level functions get breathing room, like hand-written modules.
            val spaced = topLevel && stmt is LuaFunctionDecl
            if (spaced && i > 0) blankLine()
            if (!isLast && (stmt is LuaReturn || stmt is LuaBreak)) {
                // Lua only allows `return`/`break` as the last statement of a block.
                line("do ${statementInline(stmt)} end")
            } else {
                printStatement(stmt)
            }
            if (spaced && !isLast) blankLine()
        }
    }

    private fun statementInline(stmt: LuaStmt): String = when (stmt) {
        is LuaReturn -> returnText(stmt)
        LuaBreak -> "break"
        else -> error("not inline: $stmt")
    }

    private fun returnText(stmt: LuaReturn) =
        if (stmt.values.isEmpty()) "return" else "return " + stmt.values.joinToString(", ") { expr(it) }

    private fun printStatement(stmt: LuaStmt) {
        when (stmt) {
            is LuaLocal -> line(
                "local " + stmt.names.joinToString(", ") +
                    if (stmt.values.isEmpty()) "" else " = " + stmt.values.joinToString(", ") { expr(it) },
            )

            is LuaAssign -> line(
                stmt.targets.joinToString(", ") { expr(it) } + " = " + stmt.values.joinToString(", ") { expr(it) },
            )

            is LuaCallStmt -> line(expr(stmt.call))

            is LuaIf -> printIf(stmt)

            is LuaWhile -> {
                line("while ${expr(stmt.cond)} do")
                nested(stmt.body)
                line("end")
            }

            is LuaRepeat -> {
                line("repeat")
                nested(stmt.body)
                line("until ${expr(stmt.until)}")
            }

            is LuaNumericFor -> {
                val step = stmt.step?.let { ", " + expr(it) } ?: ""
                line("for ${stmt.variable} = ${expr(stmt.start)}, ${expr(stmt.limit)}$step do")
                nested(stmt.body)
                line("end")
            }

            is LuaGenericFor -> {
                line("for ${stmt.names.joinToString(", ")} in ${stmt.exprs.joinToString(", ") { expr(it) }} do")
                nested(stmt.body)
                line("end")
            }

            is LuaFunctionDecl -> printFunctionDecl(stmt)

            is LuaReturn -> line(returnText(stmt))

            LuaBreak -> line("break")

            is LuaGoto -> line("goto ${stmt.label}")

            is LuaLabel -> line("::${stmt.label}::")

            is LuaDo -> {
                line("do")
                nested(stmt.body)
                line("end")
            }

            is LuaComment -> stmt.text.lines().forEach { line("-- $it") }
        }
    }

    private fun printFunctionDecl(stmt: LuaFunctionDecl) {
        val prefix = if (stmt.isLocal) "local function " else "function "
        val name = stmt.name
        val header = if (stmt.isMethod && name is LuaIndex && name.key is LuaString) {
            "${expr(name.target)}:${name.key.value}"
        } else {
            expr(name)
        }
        printFunction(prefix + header, stmt.fn)
    }

    private fun printIf(stmt: LuaIf) {
        line("if ${expr(stmt.cond)} then")
        nested(stmt.then)
        var orElse = stmt.orElse
        while (orElse != null) {
            val single = orElse.singleOrNull()
            if (single is LuaIf) {
                line("elseif ${expr(single.cond)} then")
                nested(single.then)
                orElse = single.orElse
            } else {
                if (orElse.isNotEmpty()) {
                    line("else")
                    nested(orElse)
                }
                orElse = null
            }
        }
        line("end")
    }

    private fun printFunction(header: String, fn: LuaFunction) {
        val params = paramList(fn)
        if (fn.body.isEmpty()) {
            line("$header($params) end")
            return
        }
        line("$header($params)")
        nested(fn.body)
        line("end")
    }

    private fun paramList(fn: LuaFunction) = (fn.params + if (fn.isVararg) listOf("...") else emptyList()).joinToString(", ")

    // ---- expressions ----

    private fun expr(e: LuaExpr, parentPrecedence: Int = 0): String = when (e) {
        LuaNil -> "nil"

        is LuaBool -> e.value.toString()

        is LuaNumber -> if (e.text.startsWith("-") && parentPrecedence >= UNARY_PRECEDENCE) "(${e.text})" else e.text

        is LuaString -> quote(e.value)

        is LuaName -> e.name

        is LuaIndex -> {
            val key = e.key
            if (key is LuaString && isIdentifier(key.value)) {
                "${prefix(e.target)}.${key.value}"
            } else {
                "${prefix(e.target)}[${expr(key)}]"
            }
        }

        is LuaCall -> "${prefix(e.fn)}(${e.args.joinToString(", ") { expr(it) }})"

        is LuaMethodCall -> "${prefix(e.target)}:${e.method}(${e.args.joinToString(", ") { expr(it) }})"

        is LuaBinary -> binary(e, parentPrecedence)

        is LuaUnary -> {
            val operand = expr(e.operand, UNARY_PRECEDENCE)
            // Avoid `- -x`, which Lua would read as a comment.
            val text = if (e.op == LuaUnOp.Neg && operand.startsWith("-")) "-($operand)" else e.op.token + operand
            if (parentPrecedence > UNARY_PRECEDENCE) "($text)" else text
        }

        is LuaFunction -> functionExpr(e)

        is LuaTable -> table(e)
    }

    private fun binary(e: LuaBinary, parentPrecedence: Int): String {
        val p = e.op.precedence
        // Same-precedence operands on the non-associative side need parentheses. Concatenation is
        // associative, so `(a .. b) .. c` can drop them too.
        val leftIsConcat = e.op == LuaBinOp.Concat && (e.left as? LuaBinary)?.op == LuaBinOp.Concat
        val left = expr(e.left, if (e.op.rightAssoc && !leftIsConcat) p + 1 else p)
        val right = expr(e.right, if (e.op.rightAssoc) p else p + 1)
        val text = "$left ${e.op.token} $right"
        return if (p < parentPrecedence) "($text)" else text
    }

    /** Call and index targets must be Lua "prefix expressions". */
    private fun prefix(e: LuaExpr): String = when (e) {
        is LuaName, is LuaIndex, is LuaCall, is LuaMethodCall -> expr(e)
        else -> "(${expr(e)})"
    }

    private fun functionExpr(fn: LuaFunction): String {
        val params = paramList(fn)
        if (fn.body.isEmpty()) return "function($params) end"
        // Short single-expression lambdas stay on one line: function(it) return it * 2 end
        val single = fn.body.singleOrNull()
        if (single is LuaReturn && single.values.size <= 1 && single.values.none { it is LuaFunction }) {
            val text = "function($params) ${returnText(single)} end"
            if (text.length <= MAX_INLINE_FUNCTION_LENGTH && '\n' !in text) return text
        }
        val sub = LuaPrinter(indentUnit)
        sub.indent = indent + 1
        sub.printBlock(fn.body, topLevel = false)
        return "function($params)\n${sub.out}${indentUnit.repeat(indent)}end"
    }

    private fun table(t: LuaTable): String {
        if (t.fields.isEmpty()) return "{}"
        return t.fields.joinToString(", ", "{", "}") { f ->
            when (f) {
                is LuaField.Positional -> expr(f.value)
                is LuaField.Named -> "${f.name} = ${expr(f.value)}"
                is LuaField.Keyed -> "[${expr(f.key)}] = ${expr(f.value)}"
            }
        }
    }

    companion object {
        private const val MAX_INLINE_FUNCTION_LENGTH = 60
        private const val ASCII_LIMIT = 0x80
        private const val FIRST_PRINTABLE = 0x20
        private const val DELETE = 0x7F
        private const val DECIMAL_ESCAPE_DIGITS = 3

        val KEYWORDS = setOf(
            "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in",
            "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
        )

        private fun isIdentifier(s: String) = s.isNotEmpty() && (s[0].isLetter() || s[0] == '_') && s[0].code < ASCII_LIMIT &&
            s.all { (it.isLetterOrDigit() || it == '_') && it.code < ASCII_LIMIT } && s !in KEYWORDS

        private fun quote(s: String): String = buildString {
            append('"')
            val bytes = s.toByteArray(Charsets.UTF_8)
            var i = 0
            while (i < bytes.size) {
                val b = bytes[i].toInt() and 0xFF
                when {
                    b == '"'.code -> append("\\\"")

                    b == '\\'.code -> append("\\\\")

                    b == '\n'.code -> append("\\n")

                    b == '\r'.code -> append("\\r")

                    b == '\t'.code -> append("\\t")

                    b < FIRST_PRINTABLE || b == DELETE -> append("\\").append(b.toString().padStart(DECIMAL_ESCAPE_DIGITS, '0'))

                    b < ASCII_LIMIT -> append(b.toChar())

                    else -> {
                        // Copy a whole UTF-8 sequence through unescaped so the output stays readable.
                        val len = when {
                            b >= 0xF0 -> 4
                            b >= 0xE0 -> 3
                            else -> 2
                        }
                        append(String(bytes, i, minOf(len, bytes.size - i), Charsets.UTF_8))
                        i += len
                        continue
                    }
                }
                i++
            }
            append('"')
        }
    }
}
