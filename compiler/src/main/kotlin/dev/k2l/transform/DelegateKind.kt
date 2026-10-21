package dev.k2l.transform

import org.jetbrains.kotlin.psi.KtNamedFunction

/** What a delegated property delegates to, which decides how `getValue`/`setValue` are called. */
internal sealed interface DelegateKind {
    /** `kotlin.Lazy`: `getValue()` ignores its arguments. */
    data object Lazy : DelegateKind

    /** `Delegates.observable` and friends, or any `ReadWriteProperty`/`ReadOnlyProperty` value (lualib objects). */
    data object Library : DelegateKind

    /**
     * A property reference: `by ::other` or `by obj::other` (a KProperty0, read with `get()`) or `by Owner::other` (a
     * KProperty1 of the receiver, read with `get(thisRef)`).
     */
    data class Property(val unbound: Boolean) : DelegateKind

    /** `by map`: the property name is the key. */
    data object MapKey : DelegateKind

    /** A class of this program with `operator fun getValue`/`setValue`, as members or extensions. */
    data class User(val get: Operator, val set: Operator?) : DelegateKind
}

/** An operator function of a delegate: a method of its class, or a top-level extension function. */
internal sealed interface Operator {
    data class Method(val name: String) : Operator

    data class Extension(val function: KtNamedFunction) : Operator
}
