package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.KtClassOrObject
import org.jetbrains.kotlin.psi.KtNamedFunction

/** Members of `Random` whose overloads are one Lua method of `Random.lua` that dispatches on the arguments. */
private val OVERLOADED_MEMBERS = setOf("nextInt", "nextLong", "nextDouble", "nextBytes")

/**
 * A class extending `Random()` overrides `nextBits`, from which the lualib base draws everything else, and may override the
 * members without overloads (`nextBoolean`, `nextFloat`). An override of an overloaded one (`nextInt()`) would replace the
 * Lua method behind all of its overloads.
 */
internal fun FileTransformer.checkRandomOverrides(c: KtClassOrObject) {
    for (fn in c.declarations.filterIsInstance<KtNamedFunction>()) {
        if (fn.hasModifier(KtTokens.OVERRIDE_KEYWORD) && fn.name in OVERLOADED_MEMBERS) unsupported(fn, "Overriding 'Random.${fn.name}'")
    }
}

/**
 * kotlin.random.Random. `Random(seed)` is Kotlin's XorWow generator (see `Random.lua`), so seeded sequences
 * match the JVM; `Random.Default` is seeded from the clock.
 */
internal object RandomMappings {
    private val INSTANCE_MEMBERS = listOf("nextInt", "nextBoolean", "nextDouble", "nextFloat", "nextLong", "nextBits", "nextBytes")

    fun install(t: MappingTable) {
        t.def("kotlin/random/Random") {
            libMember(RANDOM_TABLE, if (isLong(argTypes.firstOrNull())) "seededLong" else "seeded", arg(0))
        }
        for (prefix in listOf("kotlin/random/Random", "kotlin/random/Random.Default")) {
            for (member in INSTANCE_MEMBERS) {
                t.def("$prefix.$member") { nextValue(member) }
            }
        }
        t.def("kotlin/random/nextInt") { method(self, "nextIntRange", arg(0)) }
        t.def("kotlin/random/nextLong") { libMember(RANDOM_LONG_TABLE, "nextLongIn", self, arg(0)) }
        t.def("kotlin/random/nextUInt") { longs("nextUInt", self) }
        t.def("kotlin/random/nextULong") { longs("nextULong", self) }
        t.def("kotlin/ranges/random") { rangeRandom(orNull = false) }
        t.def("kotlin/ranges/randomOrNull") { rangeRandom(orNull = true) }
    }

    private fun CallSite.isLong(type: KaType?) = type != null && with(session) { type.withoutFlexibility.isLongType }

    /** `nextLong(until)`, `nextLong(from, until)`, `nextUInt(...)` and `nextULong(...)`: `RandomLong.lua`, called as (random, from, until). */
    private fun CallSite.longs(member: String, random: LuaExpr): LuaExpr {
        val bounds = when (args.size) {
            0 -> emptyList()
            1 -> listOf(LuaNil, arg(0))
            else -> listOf(arg(0), arg(1))
        }
        return libMember(RANDOM_LONG_TABLE, member, random, *bounds.toTypedArray())
    }

    /**
     * `IntRange.random(random)` and `LongRange.random(random)` draw as `random.nextInt(range)` and `nextLong(range)` do, which
     * differs from a collection's `random` at the bounds of Int and in the draws of a Long range; other ranges are collections.
     */
    private fun CallSite.rangeRandom(orNull: Boolean): LuaExpr? {
        val classId = receiverType?.let { with(session) { (it.withoutFlexibility as? KaClassType)?.classId?.asString() } }
        val random = args.firstOrNull() ?: defaultRandom()
        return when (classId) {
            "kotlin/ranges/IntRange" -> method(random, "nextIntRange", self, LuaBool(orNull))
            "kotlin/ranges/LongRange" -> libMember(RANDOM_LONG_TABLE, "nextLongIn", random, self, LuaBool(orNull))
            else -> null
        }
    }

    private fun CallSite.nextValue(member: String): LuaExpr? {
        val random = receiver ?: defaultRandom()
        if (member == "nextLong" && args.isNotEmpty()) return longs("nextLong", random)
        if (member == "nextBytes" && args.size == 1 && isIntegral(argTypes.firstOrNull())) {
            // nextBytes(size) fills a new ByteArray
            val array = LuaCall(ref("Collections", "__K2L_ListOfSize"), listOf(arg(0), LuaNumber("0"), LuaString("[B")))
            return method(random, member, array)
        }
        val isRange = args.size == 1 && kindOf(argTypes.firstOrNull()) == CollectionKind.Range
        return method(random, if (isRange) "nextIntRange" else member, *args.toTypedArray())
    }
}
