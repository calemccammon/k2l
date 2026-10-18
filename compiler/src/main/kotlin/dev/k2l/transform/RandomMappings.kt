package dev.k2l.transform

import dev.k2l.codegen.*

/**
 * kotlin.random.Random. `Random(seed)` is Kotlin's XorWow generator (see `Random.lua`), so seeded sequences
 * match the JVM; `Random.Default` is seeded from the clock.
 */
internal object RandomMappings {
    private val INSTANCE_MEMBERS = listOf("nextInt", "nextBoolean", "nextDouble", "nextFloat", "nextLong")

    fun install(t: MappingTable) {
        t.def("kotlin/random/Random") {
            libMember("Random", "__K2L_Random", if (isLong(argTypes.firstOrNull())) "seededLong" else "seeded", arg(0))
        }
        for (prefix in listOf("kotlin/random/Random", "kotlin/random/Random.Default")) {
            for (member in INSTANCE_MEMBERS) {
                t.def("$prefix.$member") { nextValue(member) }
            }
        }
        t.def("kotlin/random/nextInt") { method(self, "nextIntRange", arg(0)) }
    }

    private fun CallSite.isLong(type: org.jetbrains.kotlin.analysis.api.types.KaType?) =
        type != null && with(session) { type.withoutFlexibility.isLongType }

    private fun CallSite.nextValue(member: String): LuaExpr? {
        // Long ranges would need 64-bit arithmetic on every target
        if (member == "nextLong" && args.isNotEmpty()) return null
        val random = receiver ?: libMember("Random", "__K2L_Random", "default")
        val isRange = args.size == 1 && argTypes.firstOrNull()?.let { with(session) { it.collectionKind() } } == CollectionKind.Range
        return method(random, if (isRange) "nextIntRange" else member, *args.toTypedArray())
    }
}
