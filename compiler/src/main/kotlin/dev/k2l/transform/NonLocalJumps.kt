package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.resolution.KaCallableMemberCall
import org.jetbrains.kotlin.analysis.api.resolution.KaFunctionCall
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.psi.*

/*
 * A `return`, `break` or `continue` out of a lambda passed to an inline function. Where the lambda is expanded in place (the
 * scope functions, the collection functions of InlinedCollections.kt, `inline fun`s of the program, ...) it is a `goto` or
 * a Lua `return`. Where it stays a Lua function (a library function the lualib implements, such as `trim { }`, `maxOfWith`,
 * `mapCatching` or the functions of a `Sequence`), it raises the token of the call it was passed to (`__K2L_Jump`, see
 * Jump.lua), and the call, run in a pcall, makes the jump: `local ____jump = __K2L_NewJump()`, then
 * `local ____ok, ____result = pcall(function() ... end)` and `if ____result == ____jump then return ____jump.value end`.
 * The runtime raises a token again wherever it catches errors, so `catch`, `runCatching` and the like never see it, while
 * `finally` blocks and `use` still run on the way out.
 */

/** A jump to [target] from here: [value] is what a `return` returns. */
internal fun FileTransformer.jumpTo(target: JumpTarget, value: Operand?, at: KtElement): Unit = with(session) {
    val owner = when (target) {
        is JumpTarget.Return -> target.frame
        is JumpTarget.Break -> target.loop.owner
        is JumpTarget.Continue -> target.loop.owner
    }
    val crossed = jumps.frames.drop(jumps.frames.indexOfLast { it === owner } + 1)
    val closure = crossed.lastOrNull { it.isClosure }
    when {
        closure != null -> raiseJump(closure, target, value, at)
        target is JumpTarget.Return -> returnLocally(target.frame, value)
        target is JumpTarget.Break -> breakLocally(target.loop, crossed.isNotEmpty())
        target is JumpTarget.Continue -> continueLocally(target.loop, crossed.isNotEmpty())
    }
}

/** Leaves the Lua function of [closure], a lambda passed to an inline function, by raising the token of its call. */
private fun FileTransformer.raiseJump(closure: FunctionFrame, target: JumpTarget, value: Operand?, at: KtElement): Unit = with(session) {
    val site = closure.site
    if (site == null) {
        val call = generateSequence(closure.psi) { it.parent }.take(5).filterIsInstance<KtCallExpression>().firstOrNull()
        val callee = (call?.calleeExpression as? KtNameReferenceExpression)?.getReferencedName()
        val what = when (target) {
            is JumpTarget.Return -> "return"
            is JumpTarget.Break -> "break"
            is JumpTarget.Continue -> "continue"
        }
        unsupported(at, "Non-local $what out of a lambda" + callee?.let { " passed to '$it'" }.orEmpty())
        return
    }
    val token = LuaName(site.token ?: ctx.temp("jump").also { site.token = it })
    val code = LuaNumber(site.codeOf(target, value != null).toString())
    jumps.jumpsRaised++
    fun raise(v: LuaExpr?) = LuaCallStmt(LuaCall(lualibRef("Jump", "__K2L_Jump"), listOfNotNull(token, code, v)))
    when (value) {
        null -> emit(raise(null))
        is Operand.Value -> emit(raise(value.lua))
        is Operand.Source -> emitAll(valueInto(value.expr) { listOf(raise(it)) })
    }
}

/**
 * A call of an inline function, built by [build]: if a lambda argument that stays a Lua function jumps out of itself, the call
 * runs in a pcall that makes the jumps. Otherwise (the lambdas were expanded, or have no such jumps) it is unchanged.
 */
internal fun FileTransformer.catchingJumps(call: KaCallableMemberCall<*, *>, full: KtExpression, build: () -> LuaExpr): LuaExpr {
    val lambdas = inlinedLambdaArguments(call)
    if (lambdas.isEmpty()) return build()
    val site = JumpSite(lambdas)
    jumps.jumpSites.addLast(site)
    val (value, pre) = try {
        withPreceding(build)
    } finally {
        jumps.jumpSites.removeLast()
    }
    if (site.jumps.isEmpty()) {
        emitAll(pre)
        return value
    }
    return pcallSite(site, pre, value, full)
}

/** The lambda literals passed to [call] if it calls an inline function: the only lambdas Kotlin lets jump out of themselves. */
private fun FileTransformer.inlinedLambdaArguments(call: KaCallableMemberCall<*, *>): Set<KtLambdaExpression> {
    if (call !is KaFunctionCall<*>) return emptySet()
    val symbol = call.symbol
    val inline = when (symbol) {
        is KaNamedFunctionSymbol -> symbol.isInline
        is KaConstructorSymbol -> isArrayConstructor(symbol)
        else -> false
    }
    if (!inline) return emptySet()
    return call.valueArgumentMapping.keys.mapNotNullTo(HashSet()) { lambdaLiteral(it) ?: inlinedLambdaOf(it)?.expr }
}

/** Runs the call ([pre] and [value]) in a pcall: an error that is the site's token makes the jump stored in it. */
private fun FileTransformer.pcallSite(site: JumpSite, pre: List<LuaStmt>, value: LuaExpr, full: KtExpression): LuaExpr = with(session) {
    val token = site.token!!
    emit(LuaLocal(listOf(token), listOf(LuaCall(lualibRef("Jump", "__K2L_NewJump"), emptyList()))))
    val unit = full.expressionType.let { it == null || it.isUnitType || it.isNothingType }
    val result = if (unit) null else declare("value")
    // locals the call needs first are declared outside the protected function, so code after the call still sees them
    val hoisted = pre.filterIsInstance<LuaLocal>().flatMap { it.names }
    if (hoisted.isNotEmpty()) emit(LuaLocal(hoisted))
    val body = pre.mapNotNull {
        if (it is LuaLocal) it.values.takeIf { v -> v.isNotEmpty() }?.let { v -> LuaAssign(it.names.map(::LuaName), v) } else it
    }
    val last = when {
        result != null -> assign(result, value)
        value is LuaCall || value is LuaMethodCall -> LuaCallStmt(value)
        else -> null
    }
    lowerTry(
        TryParts(
            pcall = pcallFor(site),
            body = { body + listOfNotNull(last) },
            handler = { error ->
                val rethrow = LuaCallStmt(luaCall(LuaName("error"), LuaName(error), LuaNumber("0")))
                listOf(LuaIf(LuaBinary(LuaBinOp.Eq, LuaName(error), LuaName(token)), madeJumps(site, LuaName(token), full)), rethrow)
            },
            hasCatch = true,
            finally = null,
        ),
    )
    return result ?: LuaNil
}

/** The jumps a raised token asks for, by its code. */
private fun FileTransformer.madeJumps(site: JumpSite, token: LuaName, at: KtElement): List<LuaStmt> {
    val jumps = site.jumps.map { jump ->
        collect { jumpTo(jump.target, if (jump.hasValue) LuaIndex(token, LuaString("value")).asOperand() else null, at) }
    }
    if (jumps.size == 1) return jumps.single()
    val code = LuaIndex(token, LuaString("code"))
    return jumps.withIndex().reversed().fold(null as List<LuaStmt>?) { orElse, (i, stmts) ->
        listOf(LuaIf(LuaBinary(LuaBinOp.Eq, code, LuaNumber("${i + 1}")), stmts, orElse))
    }.orEmpty()
}

/** `pcall`, or on Lua 5.1 `__K2L_CoPcall` when a lambda can suspend (5.1 cannot yield across pcall). */
private fun FileTransformer.pcallFor(site: JumpSite): LuaExpr {
    val suspends = !target.yieldsAcrossPcall && site.lambdas.any { containsSuspensionPoint(it) }
    return if (suspends) lualibRef("CoPcall", "__K2L_CoPcall") else luaPcall()
}

/** `Array(n) { }`, `IntArray(n) { }`, ...: their constructors are inline. */
private fun isArrayConstructor(symbol: KaConstructorSymbol): Boolean {
    val classId = symbol.containingClassId ?: return false
    return classId.packageFqName.asString() == "kotlin" && classId.shortClassName.asString().endsWith("Array")
}
