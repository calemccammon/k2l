package dev.k2l.codegen

import java.util.IdentityHashMap

/**
 * Lua 5.1 and LuaJIT allow a function at most 60 upvalues. Generated code reads the runtime through chunk-level locals
 * (`local __K2L_X = ____lualib.__K2L_X`), so a large function (a `main` with many loops expanded in place) can need more.
 * [prologues] gives each function written at chunk level that has more than [LIMIT] upvalues the statement
 * `local __K2L_A, __K2L_B = ____lualib.__K2L_A, ____lualib.__K2L_B` for the runtime names it uses: those become its own
 * locals, and it needs only the upvalue `____lualib` for them.
 */
object UpvalueLimit {
    /** Below Lua's 60, for names the count below misses (a chunk local reused as an inner local's name). */
    private const val LIMIT = 50
    private const val RUNTIME = "____lualib"

    /** [extra]: the upvalues a function needs besides the names it uses (hoisted lambdas, see LambdaHoisting). */
    fun prologues(chunk: LuaChunk, runtimeNames: Set<String>, extra: Map<LuaFunction, Int> = emptyMap()): Map<LuaFunction, List<LuaStmt>> {
        if (runtimeNames.isEmpty()) return emptyMap()
        val chunkLocals = HashSet<String>(runtimeNames).also { it += RUNTIME }
        val functions = mutableListOf<LuaFunction>()
        chunk.body.forEach { ChunkScan(chunkLocals, functions).stmt(it) }
        val result = IdentityHashMap<LuaFunction, List<LuaStmt>>()
        for (fn in functions) {
            val free = freeNames(fn)
            val hoisted = free.filter { it in runtimeNames }.sorted()
            if (free.count { it in chunkLocals } + (extra[fn] ?: 0) > LIMIT && hoisted.isNotEmpty()) {
                result[fn] = listOf(LuaLocal(hoisted, hoisted.map { LuaIndex(LuaName(RUNTIME), LuaString(it)) }))
            }
        }
        return result
    }
}
