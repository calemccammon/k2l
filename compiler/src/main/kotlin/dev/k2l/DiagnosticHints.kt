package dev.k2l

/**
 * One-line workarounds for the diagnostics that have a cheap and correct one: an equivalent supported form, or the option
 * that makes the construct supported. Diagnostics without a safe workaround get no hint.
 */
internal object DiagnosticHints {
    private class Rule(val pattern: Regex, val hint: (MatchResult) -> String)

    private const val UTF16 = "compile with --strings utf16 (k2l.json: \"strings\": \"utf16\") to get the JVM's UTF-16 strings"
    private const val GOTO = "target Lua 5.2 or newer, or LuaJIT, which have goto (-t 5.4, k2l.json: \"luaTarget\")"
    private const val LAMBDA = "use a lambda instead of the reference"

    private val rules = listOf(
        Rule(Regex("without --strings utf16")) { UTF16 },
        Rule(Regex("needs goto")) { GOTO },
        Rule(Regex("^Reference to the library constructor '(?:[\\w$]+[/.])*([\\w$]+)'")) { "$LAMBDA, e.g. { ${it.groupValues[1]}() }" },
        Rule(Regex("^Reference to library property '(\\w+)'")) {
            "$LAMBDA, e.g. { it.${it.groupValues[1]} } (or { x.${it.groupValues[1]} })"
        },
        Rule(Regex("^(Reference to a member extension function|This callable reference|This property reference)")) { LAMBDA },
        Rule(Regex("^Delegating the library interface")) {
            "implement the interface's members in the class and forward each one to the delegate"
        },
        Rule(Regex("^Extending '(java\\.util\\.)?Vector<")) {
            "extend java.util.ArrayList instead (Lua has one thread, so Vector's locking adds nothing)"
        },
        // Reflection has no Lua function to bind; other library APIs can be written in Kotlin or bound to Lua.
        Rule(Regex("^Library API '(?!java\\.lang\\.Class\\.|kotlin\\.reflect\\.)")) {
            "implement it in Kotlin, or bind a Lua function with @LuaExternal (see \"Calling Lua from Kotlin\" in the README)"
        },
        Rule(Regex("^Passing a nullable value for '(\\w+)', which has a default")) {
            "declare the parameter with '= null' and apply the real default in the body (${it.groupValues[1]} ?: ...)"
        },
        Rule(Regex("^(Overrides of .* share the Lua name|Overloads of .* clash in Lua|A function and a property both named)")) {
            "rename one of them"
        },
        Rule(Regex("^A member named '.*' clashes with the generated Lua class table")) { "rename the member" },
        Rule(Regex("^Overriding 'Random\\.")) {
            "override only nextBits(bitCount): Random's other members draw from it, as Kotlin's defaults do"
        },
    )

    fun hintFor(message: String): String? = rules.firstOrNull { it.pattern.containsMatchIn(message) }?.let { rule ->
        rule.hint(rule.pattern.find(message)!!)
    }
}
