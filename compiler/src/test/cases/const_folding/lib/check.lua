-- The definitions, as Lua sees them.
for _, name in ipairs({"HALF", "NEGATIVE_HALF", "REMAINDER", "WRAPPED", "SHIFTED", "BIG", "LONG_WRAPPED", "THIRD", "SUM",
    "WHOLE", "FLOAT", "NEXT", "LABEL", "FLAG"}) do
    print(name, Limits[name])
end
print("SIZE", Box.SIZE)
print("AREA", AREA)
