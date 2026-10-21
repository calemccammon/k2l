package dev.k2l.codegen

// Name analysis of the Lua syntax tree for UpvalueLimit and LambdaHoisting: which names a function uses and declares.

/** The locals of the chunk's own scope and the functions written in it (not those nested in other functions). */
internal class ChunkScan(val locals: MutableSet<String>, val functions: MutableList<LuaFunction>) {
    fun stmt(s: LuaStmt) {
        when (s) {
            is LuaLocal -> {
                locals += s.names
                s.values.forEach(::expr)
            }

            is LuaFunctionDecl -> {
                if (s.isLocal) (s.name as? LuaName)?.let { locals += it.name }
                functions += s.fn
            }

            else -> children(s, ::stmt, ::expr)
        }
    }

    fun expr(e: LuaExpr) {
        if (e is LuaFunction) functions += e else exprChildren(e, ::expr)
    }
}

/** The names a function reads or assigns, and the names it (or a function in it) declares. */
internal class Names {
    val referenced = HashSet<String>()
    val declared = HashSet<String>()

    fun function(fn: LuaFunction) {
        declared += fn.params
        fn.body.forEach(::stmt)
    }

    fun stmt(s: LuaStmt) {
        when (s) {
            is LuaLocal -> declared += s.names

            is LuaNumericFor -> declared += s.variable

            is LuaGenericFor -> declared += s.names

            is LuaFunctionDecl -> {
                if (s.isLocal) (s.name as? LuaName)?.let { declared += it.name }
                if (s.isMethod) declared += "self"
            }

            else -> Unit
        }
        children(s, ::stmt, ::expr)
    }

    fun expr(e: LuaExpr) {
        when (e) {
            is LuaName -> referenced += e.name
            is LuaFunction -> function(e)
            else -> exprChildren(e, ::expr)
        }
    }
}

/** The statements and expressions directly inside [s] (a declared function's name and body included). */
internal fun children(s: LuaStmt, stmt: (LuaStmt) -> Unit, expr: (LuaExpr) -> Unit) {
    when (s) {
        is LuaLocal -> s.values.forEach(expr)

        is LuaAssign -> (s.targets + s.values).forEach(expr)

        is LuaCallStmt -> expr(s.call)

        is LuaIf -> {
            expr(s.cond)
            s.then.forEach(stmt)
            s.orElse?.forEach(stmt)
        }

        is LuaWhile -> {
            expr(s.cond)
            s.body.forEach(stmt)
        }

        is LuaRepeat -> {
            s.body.forEach(stmt)
            expr(s.until)
        }

        is LuaNumericFor -> {
            listOfNotNull(s.start, s.limit, s.step).forEach(expr)
            s.body.forEach(stmt)
        }

        is LuaGenericFor -> {
            s.exprs.forEach(expr)
            s.body.forEach(stmt)
        }

        is LuaFunctionDecl -> {
            expr(s.name)
            expr(s.fn)
        }

        is LuaReturn -> s.values.forEach(expr)

        is LuaDo -> s.body.forEach(stmt)

        LuaBreak, is LuaGoto, is LuaLabel -> Unit
    }
}

internal fun exprChildren(e: LuaExpr, expr: (LuaExpr) -> Unit) {
    when (e) {
        is LuaIndex -> {
            expr(e.target)
            expr(e.key)
        }

        is LuaCall -> (listOf(e.fn) + e.args).forEach(expr)

        is LuaMethodCall -> (listOf(e.target) + e.args).forEach(expr)

        is LuaBinary -> {
            expr(e.left)
            expr(e.right)
        }

        is LuaUnary -> expr(e.operand)

        is LuaTable -> e.fields.forEach { f ->
            when (f) {
                is LuaField.Positional -> expr(f.value)

                is LuaField.Named -> expr(f.value)

                is LuaField.Keyed -> {
                    expr(f.key)
                    expr(f.value)
                }
            }
        }

        is LuaFunction, LuaNil, is LuaBool, is LuaNumber, is LuaString, is LuaName -> Unit
    }
}

/** The names [fn] reads or assigns that are not its own parameters or locals in scope where it uses them (its upvalues and globals). */
internal fun freeNames(fn: LuaFunction): Set<String> = FreeScan().also { it.function(fn, emptyList()) }.free

private class FreeScan {
    val free = HashSet<String>()
    private val scopes = ArrayDeque<MutableSet<String>>()

    fun function(fn: LuaFunction, implicit: List<String>) {
        scopes.addLast((fn.params + implicit).toMutableSet())
        fn.body.forEach(::stmt)
        scopes.removeLast()
    }

    private fun block(body: List<LuaStmt>, declared: List<String> = emptyList(), after: () -> Unit = {}) {
        scopes.addLast(declared.toMutableSet())
        body.forEach(::stmt)
        after()
        scopes.removeLast()
    }

    private fun declare(names: List<String>) {
        scopes.last() += names
    }

    private fun stmt(s: LuaStmt) {
        when (s) {
            is LuaLocal -> {
                s.values.forEach(::expr)
                declare(s.names)
            }

            is LuaFunctionDecl -> {
                if (s.isLocal) (s.name as? LuaName)?.let { declare(listOf(it.name)) } else expr(s.name)
                function(s.fn, if (s.isMethod) listOf("self") else emptyList())
            }

            is LuaIf -> {
                expr(s.cond)
                block(s.then)
                s.orElse?.let { block(it) }
            }

            is LuaWhile -> {
                expr(s.cond)
                block(s.body)
            }

            // `until` sees the body's locals
            is LuaRepeat -> block(s.body) { expr(s.until) }

            is LuaNumericFor -> {
                listOfNotNull(s.start, s.limit, s.step).forEach(::expr)
                block(s.body, listOf(s.variable))
            }

            is LuaGenericFor -> {
                s.exprs.forEach(::expr)
                block(s.body, s.names)
            }

            is LuaDo -> block(s.body)

            else -> children(s, ::stmt, ::expr)
        }
    }

    private fun expr(e: LuaExpr) {
        when (e) {
            is LuaName -> if (scopes.none { e.name in it }) free += e.name
            is LuaFunction -> function(e, emptyList())
            else -> exprChildren(e, ::expr)
        }
    }
}
