package dev.k2l

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.io.File

/**
 * The Lua of the `no_self_global` case, compiled with `noImplicitSelf`, has no `:` call except of the members the runtime
 * calls with self (`toString`, `equals`, `hashCode`, `compareTo`), and defines methods taking `self` only in the tables of
 * classes and interfaces, which instances use and bind (see `transform/NoSelfMembers.kt`).
 */
class NoSelfOutputTest {
    private val lua = File(System.getProperty("k2l.casesDir"), "no_self_global/expected.lua").readText()

    @Test
    fun noColonCalls() {
        val calls = Regex("""[\w)\]]:(\w+)\(""").findAll(lua.lines().filter { !it.trimStart().startsWith("function ") }.joinToString("\n"))
        assertEquals(emptyList<String>(), calls.map { it.groupValues[1] }.filter { it !in RUNTIME_PROTOCOL }.toList())
    }

    @Test
    fun selfOnlyInClassTables() {
        val tables = Regex("""function ([\w.]+):\w+\(""").findAll(lua).map { it.groupValues[1] }.toSet()
        // a class is constructed (`C.new(`) or extended, an interface implemented (`__K2L_Class("name", base, I)`)
        val classes = tables.filter { t ->
            "$t.new(" in lua ||
                Regex("""__K2L_Class\("[^"]+",[^)]*\b${Regex.escape(t)}\b""").containsMatchIn(lua)
        }
        assertEquals(emptyList<String>(), (tables - classes.toSet()).toList())
    }

    private companion object {
        val RUNTIME_PROTOCOL = setOf("toString", "equals", "hashCode", "compareTo")
    }
}
