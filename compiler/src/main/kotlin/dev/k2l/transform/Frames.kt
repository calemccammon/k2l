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
)

/** Something assignable: a variable, or a property of an object (possibly with accessors). */
internal class Target(val read: LuaExpr, val write: (LuaExpr) -> LuaStmt)

/** A call operand: source still to be transformed (in evaluation order), or an already-built Lua value. */
internal sealed interface Operand {
    class Source(val expr: KtExpression) : Operand
    class Value(val lua: LuaExpr) : Operand
}

internal fun KtExpression.asOperand(): Operand = Operand.Source(this)
internal fun LuaExpr.asOperand(): Operand = Operand.Value(this)
