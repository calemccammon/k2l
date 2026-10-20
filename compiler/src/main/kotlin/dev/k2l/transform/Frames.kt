package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.psi.KtExpression
import org.jetbrains.kotlin.psi.KtLambdaExpression

/**
 * Where the value of an expression goes: given the Lua value, returns the statements that consume it
 * (assign it, return it, ...). A null `ValueSink?` means statement context: the value is discarded.
 */
internal typealias ValueSink = (LuaExpr) -> List<LuaStmt>

internal class LoopFrame(val label: String?) {
    /** The function or lambda the loop is written in (null at the top level): jumps from frames entered later leave them. */
    var owner: FunctionFrame? = null

    var continueLabel: String? = null
    var breakLabel: String? = null

    /** Lua 5.1 (no goto): flags that carry `break@outer` / `continue@outer` out of inner loops. */
    var breakFlag: String? = null
    var continueFlag: String? = null

    /** Checks emitted right after this loop, in the enclosing loop's body. */
    val checksAfter = mutableListOf<LuaStmt>()

    fun addCheck(check: LuaStmt) {
        if (check !in checksAfter) checksAfter += check
    }
}

/**
 * Functions and lambdas being transformed, innermost last. `return` targets one of these; inlined
 * lambdas (scope functions) and inlined functions don't create a Lua function, so returning from them
 * jumps to [endLabel]. [psi] is the Kotlin function, lambda or accessor the frame stands for, when known.
 */
internal class FunctionFrame(val kind: Kind, val labels: Set<String>, val psi: PsiElement? = null) {
    enum class Kind { Function, Lambda, Inline, InlineFunction }

    /** Whether this frame is a Lua function, which a `return` of an enclosing function cannot cross. */
    val isClosure get() = kind == Kind.Function || kind == Kind.Lambda

    /** Whether a `return` without a label can end here: a Kotlin function, whether called or inlined. */
    val isFunctionBody get() = kind == Kind.Function || kind == Kind.InlineFunction

    var sink: ValueSink? = null
    var endLabel: String? = null

    /** For a lambda returning Unit whose result is used (`runCatching { }`): it returns the Unit object. */
    var unitResult = false

    /** The loops around the frame where it was entered, which a `break` or `continue` in a lambda may leave. */
    var outerLoops: ArrayDeque<LoopFrame>? = null

    /** For a lambda passed to an inline function that stays a Lua function: the call that makes the jumps out of it. */
    var site: JumpSite? = null
}

/** Where a `return`, `break` or `continue` goes: a function or lambda, or a loop. */
internal sealed interface JumpTarget {
    class Return(val frame: FunctionFrame) : JumpTarget
    class Break(val loop: LoopFrame) : JumpTarget
    class Continue(val loop: LoopFrame) : JumpTarget
}

/**
 * A call of an inline function whose lambda arguments ([lambdas]) stay Lua functions: a jump out of one of them raises the
 * call's token (see `Jump.lua`) and the call, run in a pcall, makes the jump. [jumps] are the distinct jumps made, by code.
 */
internal class JumpSite(val lambdas: Set<KtLambdaExpression>) {
    class Jump(val target: JumpTarget, val hasValue: Boolean)

    /** The local holding the token, named when the first jump needs it. */
    var token: String? = null

    val jumps = mutableListOf<Jump>()

    /** The code (1, 2, ...) of the jump to [target]. */
    fun codeOf(target: JumpTarget, hasValue: Boolean): Int {
        val index = jumps.indexOfFirst { it.hasValue == hasValue && sameTarget(it.target, target) }
        if (index >= 0) return index + 1
        jumps += Jump(target, hasValue)
        return jumps.size
    }

    private fun sameTarget(a: JumpTarget, b: JumpTarget) = when (a) {
        is JumpTarget.Return -> b is JumpTarget.Return && a.frame === b.frame
        is JumpTarget.Break -> b is JumpTarget.Break && a.loop === b.loop
        is JumpTarget.Continue -> b is JumpTarget.Continue && a.loop === b.loop
    }
}

/**
 * A lambda argument of an inlined user function, expanded wherever the function's body invokes the parameter it is
 * bound to (see InlineFunctions.kt).
 */
internal class InlinedLambda(
    val expr: KtLambdaExpression,
    /** Whether the lambda reached this function through a parameter of another inlined function. */
    val fromParameter: Boolean,
    /** What `this` meant where the lambda was written: the receiver bindings before any inlined function was entered. */
    val callerBindings: Map<PsiElement, LuaExpr>,
    /** The loops around the lambda where it was written, which a `break` or `continue` in it targets. */
    val callerLoops: ArrayDeque<LoopFrame>,
)

/**
 * Something assignable: a variable, or a property of an object (possibly with accessors). [assignAll] is `target = value`
 * as statements (a primitive array element checks the index first), [update] the write of `target op= value` and `target++`,
 * which follows a [read] of the same target (that already checked an index).
 */
internal open class Target(val read: LuaExpr, val write: (LuaExpr) -> LuaStmt) {
    open fun assignAll(value: LuaExpr): List<LuaStmt> = listOf(write(value))

    open fun update(value: LuaExpr): LuaStmt = write(value)
}

/** A call operand: source still to be transformed (in evaluation order), or an already-built Lua value. */
internal sealed interface Operand {
    class Source(val expr: KtExpression) : Operand
    class Value(val lua: LuaExpr) : Operand
}

internal fun KtExpression.asOperand(): Operand = Operand.Source(this)
internal fun LuaExpr.asOperand(): Operand = Operand.Value(this)
