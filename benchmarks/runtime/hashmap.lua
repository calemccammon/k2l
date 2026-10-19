local m = {}
for i = 0, 299999 do m[i] = i*2 end
local s = 0
for i = 0, 299999 do s = s + m[i] end
print(s)
local sm = {}
for i = 0, 99999 do sm["key"..i] = i end
local t = 0
for i = 0, 99999 do t = t + sm["key"..i] end
print(t)
local set, n = {}, 0
for i = 0, 199999 do local k = i % 1000; if not set[k] then set[k] = true; n = n + 1 end end
print(n)
local counts = {}
for i = 0, 299999 do local k = i % 100; counts[k] = (counts[k] or 0) + 1 end
print(counts[7])
