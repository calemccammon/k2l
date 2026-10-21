package dev.k2l.transform

import dev.k2l.codegen.*

/** The `Throwable` helpers that print or describe an exception, and its suppressed exceptions. */
internal object ThrowableMappings {
    fun install(t: MappingTable) {
        t.def("kotlin/Throwable.printStackTrace", "kotlin/printStackTrace") {
            LuaMethodCall(luaPath("io", "stderr"), "write", listOf(LuaBinary(LuaBinOp.Concat, method(self, "toString"), LuaString("\n"))))
        }
        t.def("kotlin/stackTraceToString") { LuaBinary(LuaBinOp.Concat, method(self, "toString"), LuaString("\n")) }
        t.def("kotlin/Throwable.localizedMessage") { LuaIndex(self, LuaString("message")) }
        t.def("kotlin/addSuppressed") { method(self, "addSuppressed", arg(0)) }
        t.def("kotlin/suppressedExceptions") { lualib("Suppressed", self) }
    }
}
