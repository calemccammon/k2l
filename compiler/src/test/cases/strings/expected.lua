local ____lualib = require("lualib_bundle")
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    local name = "Kotlin"
    local version = 2
    local ratio = 0.5
    local ok = true
    local missing = nil
    print("Hello, " .. name .. " " .. version .. "!")
    print("ratio=" .. __K2L_Str(ratio) .. " ok=" .. tostring(ok) .. " missing=" .. __K2L_Str(missing))
    print("expr: " .. version * 10 + 1 .. " " .. #name)
    print(tostring(version))
    print(name:upper() .. " " .. name:lower())
    print(("ab"):rep(3))
    print("quotes \"inside\" and \\backslash\\ and tab\tend")
    print("dollar $name")
    print("unicode: héllo ✓")
    print(#"" == 0)
    print(name .. version)
    print(name .. __K2L_Str(ratio))
    local c = "x"
    print("char " .. c)
    local s = "a"
    s = s .. "b"
    s = s .. 1
    print(s)
    print(tostring(version) .. __K2L_Str(ratio))
end

__K2L_Main(main)
