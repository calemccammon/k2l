package dev.k2l.transform

/** What a delegated property delegates to, which decides how `getValue`/`setValue` are called. */
internal sealed interface DelegateKind {
    /** `kotlin.Lazy`: `getValue()` ignores its arguments. */
    data object Lazy : DelegateKind

    /** `Delegates.observable` and friends, or any `ReadWriteProperty`/`ReadOnlyProperty` value (lualib objects). */
    data object Library : DelegateKind

    /** `by map`: the property name is the key. */
    data object MapKey : DelegateKind

    /** A class of this program with `operator fun getValue`/`setValue`. */
    data class User(val get: String, val set: String?) : DelegateKind
}
