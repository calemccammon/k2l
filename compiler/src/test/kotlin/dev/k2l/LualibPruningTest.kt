package dev.k2l

import dev.k2l.codegen.LualibPruning
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.io.File

/** The runtime keeps what the program's code uses (see [LualibPruning]). */
class LualibPruningTest {
    private val feature = """
        local __K2L_Box = __K2L_Class("Box")

        -- a helper only `get` calls
        local function check(value)
            return value
        end

        local function unused()
            return 1
        end

        function __K2L_Box:get()
            return check(self.value)
        end

        function __K2L_Box:set(value)
            self.value = value
        end

        function __K2L_Box:__tostring()
            return "Box"
        end

        __K2L_Box.read = __K2L_Box.get
        __K2L_Box.write = __K2L_Box.set

        setmetatable(__K2L_Box, {__call = function(_, value) return __K2L_Box.new(value) end})

        local __K2L_Other = {}

        function __K2L_Other.get()
            return 2
        end

        do

        local LIMIT = 10

        function __K2L_Box:limit()
            return LIMIT
        end

        end
    """.trimIndent()

    private fun prune(code: String, roots: List<String> = emptyList()): String =
        LualibPruning.prune(listOf(LualibPruning.statements(feature)), LualibPruning.uses(listOf(code)), roots).single()

    @Test
    fun keepsWhatIsReachable() {
        val kept = prune("local box = __K2L_Box.new()\nprint(box:read())")
        // `read` is used, and it reads `get`, which calls `check`; metamethods and what changes the table stay with it
        listOf(
            "function __K2L_Box:get()",
            "local function check",
            "__K2L_Box.read = ",
            "function __K2L_Box:__tostring()",
            "setmetatable(__K2L_Box",
        )
            .forEach { assertTrue(it in kept, "missing $it in:\n$kept") }
        // no one names `set`, `write` or `limit`, refers to `unused` or to __K2L_Other
        listOf("function __K2L_Box:set", "__K2L_Box.write", "local function unused", "__K2L_Other", "LIMIT", "do\n")
            .forEach { assertFalse(it in kept, "unexpected $it in:\n$kept") }
    }

    @Test
    fun namesUsedInStringsAndBlocks() {
        val kept = prune("local box = __K2L_Box.new()\nlocal f = box[\"limit\"]")
        assertTrue("do\n\nlocal LIMIT = 10\n\nfunction __K2L_Box:limit()" in kept, kept)
        assertTrue(kept.trimEnd().endsWith("end"), kept)
    }

    @Test
    fun runtimeNamesAreRoots() {
        assertTrue("local __K2L_Other = {}" in prune("", listOf("__K2L_Other")))
        assertEquals("", prune(""))
    }

    /** Splitting a feature into statements loses no code (only comments after the last statement). */
    @Test
    fun statementsCoverEveryFeature() {
        val dir = File(System.getProperty("k2l.casesDir"), "../../main/resources/dev/k2l/lualib")
        for (file in dir.listFiles().orEmpty()) {
            val code = file.readText().lines().dropWhile { it.startsWith("-- requires:") }.joinToString("\n").trim()
            assertEquals(code, LualibPruning.statements(code).joinToString("", transform = ::text).trimEnd(), file.name)
        }
    }

    private fun text(s: LualibPruning.Statement): String = s.text + s.children?.joinToString("", transform = ::text).orEmpty() + s.footer
}
