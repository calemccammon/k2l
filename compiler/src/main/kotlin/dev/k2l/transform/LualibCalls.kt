package dev.k2l.transform

import dev.k2l.codegen.*

// Builders for calls into the lualib runtime. Each goes through FileTransformer.lualibRef, which loads the feature (and
// what it implies: FloatToString with Floats about, Utf16 for Strings and Regex under --strings utf16).

/** `target.name`. */
internal fun luaField(target: LuaExpr, name: String): LuaExpr = LuaIndex(target, LuaString(name))

/** The local holding [table]; using it loads the table's feature. */
internal fun FileTransformer.lualibRef(table: LualibTable): LuaExpr = lualibRef(table.feature, table.name)

/** `__K2L_Table.member(args)`, the [table] of lualib [feature]. */
internal fun FileTransformer.libCall(feature: String, table: String, member: String, args: List<LuaExpr>): LuaExpr =
    LuaCall(luaField(lualibRef(feature, table), member), args)

internal fun FileTransformer.libCall(table: LualibTable, member: String, args: List<LuaExpr>): LuaExpr =
    libCall(table.feature, table.name, member, args)

/** `__K2L_Class.new(args)`: an instance of the runtime class [cls] of lualib [feature]. */
internal fun FileTransformer.libNew(feature: String, cls: String, args: List<LuaExpr>): LuaExpr = libCall(feature, cls, "new", args)

internal fun FileTransformer.libNew(table: LualibTable, args: List<LuaExpr>): LuaExpr = libNew(table.feature, table.name, args)

internal fun CallSite.ref(table: LualibTable): LuaExpr = transformer.lualibRef(table)

/** A call to `member` of a lualib table such as `__K2L_Num`, e.g. `__K2L_Num.sinh(x)`. */
internal fun CallSite.libMember(feature: String, table: String, member: String, vararg args: LuaExpr): LuaExpr =
    transformer.libCall(feature, table, member, args.toList())

internal fun CallSite.libMember(table: LualibTable, member: String, vararg args: LuaExpr): LuaExpr =
    transformer.libCall(table, member, args.toList())

internal fun CallSite.libCall(feature: String, table: String, member: String, args: List<LuaExpr>): LuaExpr =
    transformer.libCall(feature, table, member, args)

internal fun CallSite.libCall(table: LualibTable, member: String, args: List<LuaExpr>): LuaExpr = transformer.libCall(table, member, args)

internal fun CallSite.libNew(feature: String, cls: String, args: List<LuaExpr>): LuaExpr = transformer.libNew(feature, cls, args)

internal fun CallSite.libNew(table: LualibTable, args: List<LuaExpr>): LuaExpr = transformer.libNew(table, args)

/** `Random.Default`, for the functions whose `random` argument is optional. */
internal fun CallSite.defaultRandom(): LuaExpr = libMember(RANDOM_TABLE, "default")
