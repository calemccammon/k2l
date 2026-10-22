package dev.k2l

import dev.k2l.transform.StdlibMappings
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.condition.EnabledIf

/**
 * A mapping registered again under an id that already has one silently replaces it: no id is defined twice, so a mapping
 * cannot be shadowed by mistake.
 */
@EnabledIf(TARGET_FREE)
class MappingTableTest {
    @Test
    fun stdlibMappingsAreDefinedOnce() {
        assertEquals(emptyList<String>(), StdlibMappings.overwrites)
    }
}
