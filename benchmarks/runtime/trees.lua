local function make(d) if d == 0 then return {} end return {left=make(d-1), right=make(d-1)} end
local function check(n) if n.left == nil then return 1 end return 1 + check(n.left) + check(n.right) end
local maxDepth = 15
print("stretch tree of depth "..(maxDepth+1).." check: "..check(make(maxDepth+1)))
local long = make(maxDepth)
local d = 4
while d <= maxDepth do
  local it = 1 << (maxDepth - d + 4)
  local sum = 0
  for i = 1, it do sum = sum + check(make(d)) end
  print(it.." trees of depth "..d.." check: "..sum)
  d = d + 4
end
print("long lived tree of depth "..maxDepth.." check: "..check(long))
