package dev.k2l.transform

import dev.k2l.codegen.*

/** `kotlin.time.Instant` and `Clock`: construction, arithmetic with Durations, ISO-8601 `toString` and `parse`. */
internal object InstantMappings {
    private const val INSTANT = "kotlin/time/Instant."
    private const val COMPANION = "kotlin/time/Instant.Companion."

    /** Instant members that are methods of the same name in `Instant.lua`. */
    private val METHODS = setOf("plus", "minus", "toEpochMilliseconds")

    fun map(callableId: String?, site: CallSite): LuaExpr? {
        if (callableId == null || !callableId.startsWith("kotlin/time/")) return null
        // epochSeconds and toEpochMilliseconds are Longs: not translated with --long64 emulate, as Duration
        if (site.emulatesLong) return null
        return when {
            callableId.startsWith(COMPANION) -> companion(callableId.removePrefix(COMPANION), site)
            callableId.startsWith(INSTANT) -> member(callableId.removePrefix(INSTANT), site)
            else -> other(callableId, site)
        }
    }

    private fun CallSite.instant(member: String, vararg args: LuaExpr): LuaExpr = libMember(INSTANT_FEATURE, "__K2L_Instant", member, *args)

    private fun companion(name: String, site: CallSite): LuaExpr? = with(site) {
        when (name) {
            "fromEpochSeconds", "fromEpochMilliseconds" -> instant(name, *args.dropTrailingNil().toTypedArray())
            "parse" -> instant("parse", arg(0), LuaBool(false))
            "parseOrNull" -> instant("parse", arg(0), LuaBool(true))
            "DISTANT_PAST", "DISTANT_FUTURE" -> luaField(ref(INSTANT_FEATURE, "__K2L_Instant"), name)
            else -> null
        }
    }

    private fun member(name: String, site: CallSite): LuaExpr? = with(site) {
        if (receiver == null) return null
        when (name) {
            "epochSeconds" -> LuaIndex(self, LuaString("s"))
            "nanosecondsOfSecond" -> LuaIndex(self, LuaString("n"))
            "equals" -> lualib("Equals", self, arg(0))
            "hashCode" -> lualib("Hash", self)
            in METHODS -> LuaMethodCall(self, name, args)
            else -> null
        }
    }

    private fun other(callableId: String, site: CallSite): LuaExpr? = with(site) {
        when (callableId) {
            "kotlin/time/isDistantPast", "kotlin/time/isDistantFuture" ->
                receiver?.let { LuaMethodCall(it, callableId.substringAfterLast('/'), emptyList()) }

            "kotlin/time/Clock.now", "kotlin/time/Clock.System.now" -> receiver?.let { LuaMethodCall(it, "now", emptyList()) }

            "kotlin/time/asClock" -> receiver?.let { instant("asClock", it, arg(0)) }

            else -> null
        }
    }
}
