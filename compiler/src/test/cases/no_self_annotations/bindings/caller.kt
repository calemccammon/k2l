@file:LuaRequire("lib.caller")

package bindings

import app.Handler
import dev.k2l.lua.LuaRequire

// Hand-written Lua that calls a Handler's function with `.`.
external fun callTwice(handler: Handler, value: Int): String
