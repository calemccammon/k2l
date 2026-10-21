package dev.k2l.coverage

/**
 * One public function, property or constructor of an [Area]. [key] groups overloads in the report (`Iterable.chunked`,
 * `ArrayList.<init>`); [signature] is the overload, as Kotlin shows it. [probes] call it (with only the required
 * arguments, and with all of them); there are none when it was [skipped] (deprecated, experimental, not callable from a
 * probe), with the reason.
 */
class Api(
    val area: String,
    val key: String,
    val signature: String,
    val probes: List<ProbeSource>,
    val skipped: String? = null,
    /** `kotlin/collections/chunked`, for looking the API up in the mapping tables when it has no probe. */
    val callableId: String? = null,
)

/**
 * A probe: a function named [PROBE_NAME] that calls the API once, and the [imports] it needs. With [checksResolution] the
 * call is the initializer of `val v`, and [ProbeRunner] checks that it resolves to [target], the API's [ApiSignature].
 */
class ProbeSource(val code: String, val imports: Set<String>, val target: String, val checksResolution: Boolean)

const val PROBE_NAME = "__probe__"

const val NEEDS_UTF16 = "needs --strings utf16"

/** What a probe found. */
sealed interface Outcome {
    /** k2l translated the call. */
    data object Supported : Outcome

    /** k2l translates the call with `--strings utf16` (and reports that it needs it without). */
    data object NeedsUtf16 : Outcome

    /** k2l reported [message]. */
    data class Unsupported(val message: String) : Outcome

    /** The probe could not test the API: it does not compile as Kotlin, or it calls another overload. */
    data class Inconclusive(val reason: String) : Outcome
}

/** The outcomes of an [Api]'s probes. */
class ApiResult(val api: Api, val outcomes: List<Outcome>) {
    val tested get() = outcomes.filter { it !is Outcome.Inconclusive }

    val status: Status
        get() = when {
            api.skipped != null || tested.isEmpty() -> Status.Untested
            tested.all { it.translates } -> Status.Supported
            tested.any { it.translates } -> Status.Partial
            else -> Status.Unsupported
        }

    /** Why the API is not (fully) supported: the first k2l message, or why it was not tested. */
    val note: String?
        get() = api.skipped
            ?: NEEDS_UTF16.takeIf { Outcome.NeedsUtf16 in outcomes && status == Status.Supported }
            ?: outcomes.filterIsInstance<Outcome.Unsupported>().firstOrNull()?.message
            ?: if (tested.isEmpty()) outcomes.filterIsInstance<Outcome.Inconclusive>().firstOrNull()?.reason else null
}

private val Outcome.translates get() = this == Outcome.Supported || this == Outcome.NeedsUtf16

enum class Status { Supported, Partial, Unsupported, Untested }
