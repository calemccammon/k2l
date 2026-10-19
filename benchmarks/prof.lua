-- usage: cd runtime/NAME/out && lua5.4 ../../../prof.lua main.lua [line]  : instruction-count sampling profile
-- default: self time by function (definition line, with its text); "line": by current source line
local script, mode = arg[1], arg[2]
local counts, total = {}, 0
local getinfo = debug.getinfo
debug.sethook(function()
  local i = getinfo(2, "Sl")
  if i then
    local key = i.short_src .. ":" .. ((mode == "line" and i.currentline) or i.linedefined or 0)
    counts[key] = (counts[key] or 0) + 1
    total = total + 1
  end
end, "", 1000)
local ok, err = pcall(dofile, script)
debug.sethook()
if not ok then io.stderr:write(tostring(err), "\n") end
local arr = {}
for k, v in pairs(counts) do arr[#arr + 1] = {k, v} end
table.sort(arr, function(a, b) return a[2] > b[2] end)
local cache = {}
local function text(loc)
  local f, l = loc:match("^(.*):(%d+)$")
  if not f or f:sub(1, 1) == "[" then return "" end
  if not cache[f] then
    cache[f] = {}
    for line in io.lines(f) do cache[f][#cache[f] + 1] = line end
  end
  return (cache[f][tonumber(l)] or ""):gsub("^%s+", "")
end
for i = 1, math.min(22, #arr) do io.stderr:write(string.format("%5.1f%%  %s  %s\n", 100 * arr[i][2] / total, arr[i][1], text(arr[i][1]))) end
