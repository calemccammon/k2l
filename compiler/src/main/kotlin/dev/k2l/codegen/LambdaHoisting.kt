package dev.k2l.codegen

import java.util.IdentityHashMap

/**
 * Function values written inside functions that only return an expression and capture nothing (they read only their own
 * parameters, chunk-level locals and globals) are created once, in a chunk-level local declared just before the chunk-level
 * statement that contains them, instead of at each evaluation (a closure allocation each time, and LuaJIT cannot compile
 * closure creation). As on the JVM, where a lambda without captures is a singleton. The printer prints the [names] in place
 * of those functions and the [preludes] before their statements.
 */
class LambdaHoisting(
    val names: Map<LuaFunction, String>,
    val preludes: Map<LuaStmt, List<LuaStmt>>,
    /** How many hoisted functions each chunk-level function refers to (upvalues it needs, see UpvalueLimit). */
    val upvalues: Map<LuaFunction, Int>,
) {
    companion object {
        /** Lua allows a function (the chunk included) 200 active locals; the runtime names and the chunk's own come first. */
        private const val LOCALS = 180
        private const val UPVALUES = 50
        private const val PREFIX = "____lambda_"
        val NONE = LambdaHoisting(emptyMap(), emptyMap(), emptyMap())

        /** [limitUpvalues]: Lua 5.1 and LuaJIT, which allow a function 60 upvalues. */
        fun plan(chunk: LuaChunk, runtimeNames: Set<String>, limitUpvalues: Boolean): LambdaHoisting {
            val chunkLocals = HashSet<String>(runtimeNames)
            ChunkScan(chunkLocals, mutableListOf()).also { scan -> chunk.body.forEach(scan::stmt) }
            val planner = Planner(Names().also { n -> chunk.body.forEach(n::stmt) }.let { it.referenced + it.declared })
            planner.capacity = LOCALS - chunkLocals.size
            for (stmt in chunk.body) {
                val inStatement = Names().also { it.stmt(stmt) }.declared
                val functions = mutableListOf<LuaFunction>().also { ChunkScan(HashSet(), it).stmt(stmt) }
                val hoisted = mutableListOf<LuaStmt>()
                for (fn in functions) {
                    val budget = if (limitUpvalues) UPVALUES - chunkUpvalues(fn, chunkLocals - runtimeNames) else Int.MAX_VALUE
                    hoisted += planner.hoist(fn, inStatement, budget)
                }
                if (hoisted.isNotEmpty()) planner.preludes[stmt] = hoisted
            }
            return LambdaHoisting(planner.names, planner.preludes, planner.upvalues)
        }

        /**
         * Only one-statement functions (selectors, comparators) and those marked [LuaFunction.hoistable] (fused comparators):
         * moving a block away from its use helps no one.
         */
        private fun isCandidate(fn: LuaFunction) = fn.hoistable || (fn.body.size == 1 && fn.body[0] is LuaReturn)

        private class Planner(val taken: Set<String>) {
            val names = IdentityHashMap<LuaFunction, String>()
            val preludes = IdentityHashMap<LuaStmt, List<LuaStmt>>()
            val upvalues = IdentityHashMap<LuaFunction, Int>()
            var capacity = 0
            private var next = 1

            /** The declarations of the functions in [fn] to hoist, at most [budget]; [inStatement] are the statement's names. */
            fun hoist(fn: LuaFunction, inStatement: Set<String>, budget: Int): List<LuaStmt> {
                // a name the statement declares may be a local the function captures
                val hoistable = nestedPostOrder(fn).filter { isCandidate(it) && freeNames(it).none { name -> name in inStatement } }
                return hoistable.take(minOf(budget, capacity).coerceAtLeast(0)).map { inner ->
                    val name = generateSequence { PREFIX + next++ }.first { it !in taken }
                    names[inner] = name
                    upvalues[fn] = (upvalues[fn] ?: 0) + 1
                    capacity--
                    LuaLocal(listOf(name), listOf(inner.copy()))
                }
            }
        }

        private fun chunkUpvalues(fn: LuaFunction, chunkLocals: Set<String>): Int = freeNames(fn).count { it in chunkLocals }

        /** The functions written inside [fn], innermost first (a hoisted function's own hoisted functions are declared before it). */
        private fun nestedPostOrder(fn: LuaFunction): List<LuaFunction> {
            val result = mutableListOf<LuaFunction>()
            fun visitFunction(f: LuaFunction, isRoot: Boolean) {
                val found = mutableListOf<LuaFunction>()
                f.body.forEach { ChunkScan(HashSet(), found).stmt(it) }
                found.forEach { visitFunction(it, isRoot = false) }
                if (!isRoot) result += f
            }
            visitFunction(fn, isRoot = true)
            return result
        }
    }
}
