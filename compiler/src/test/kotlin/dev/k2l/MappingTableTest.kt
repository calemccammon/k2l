package dev.k2l

import dev.k2l.transform.Long64Mappings
import dev.k2l.transform.StdlibMappings
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

/**
 * A mapping registered again under an id that already has one silently replaces it. These are the ids for which that
 * happens today; the later definition is the one in use, so a new entry here means a mapping was probably shadowed by mistake.
 */
class MappingTableTest {
    private val stdlibOverwrites =
        // ReflectionMappings: `isSuspend` needs kotlin-reflect both as a KCallable and as a KFunction member
        listOf("kotlin/reflect/KFunction.isSuspend") +
            (0..22).flatMap { listOf("kotlin/reflect/KFunction$it.isSuspend", "kotlin/reflect/KSuspendFunction$it.isSuspend") }

    private val long64Overwrites = listOf<String>()

    @Test
    fun stdlibMappingsAreDefinedOnce() {
        assertEquals(stdlibOverwrites, StdlibMappings.overwrites)
    }

    @Test
    fun long64MappingsAreDefinedOnce() {
        assertEquals(long64Overwrites, Long64Mappings.overwrites)
    }
}
