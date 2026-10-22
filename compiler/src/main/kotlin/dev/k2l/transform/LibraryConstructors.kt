package dev.k2l.transform

import dev.k2l.codegen.LuaExpr

/** The constructors of library classes (exceptions aside, see `LIBRARY_CLASSES`): calls, and references such as `::ArrayList`. */
internal object LibraryConstructors {
    /** A constructor call `ArrayList(xs)`, or the call a constructor reference `::ArrayList` makes; null when it is not mapped. */
    fun call(classId: String?, site: CallSite): LuaExpr? = CoreConstructors.construct(classId, site)
        ?: CollectionExtrasMappings.construct(classId, site)
        ?: KotlinMiscMappings.construct(classId, site)
}
