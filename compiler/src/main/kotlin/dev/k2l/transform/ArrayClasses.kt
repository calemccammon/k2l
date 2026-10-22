package dev.k2l.transform

import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.psi.KtBinaryExpressionWithTypeRHS
import org.jetbrains.kotlin.psi.KtElement

/**
 * `is Array<*>`: whether the value is an array. All arrays are of one Lua class whatever their element type, so a test
 * against a primitive array type (`is IntArray`) is a compile error; a cast to one (`as IntArray`) checks for an array.
 */
internal fun FileTransformer.arrayTypeTest(value: LuaExpr, type: KaType, element: KtElement): LuaExpr = with(session) {
    val id = type.expandedSymbol?.classId
    if (id?.asString() != "kotlin/Array" && element !is KtBinaryExpressionWithTypeRHS) {
        ctx.error(element, "Type test 'is ${id?.shortClassName}' is not supported: all arrays are one Lua class (test `is Array<*>`)")
        return LuaNil
    }
    LuaCall(lualibRef("Collections", "__K2L_IsArray"), listOf(value))
}
