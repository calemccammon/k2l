-- requires: Collections
-- The ArrayList of the `n` elements of the 1-based table `arr`, which it takes over: `map { }`, `filter { }` and the like,
-- compiled to a loop, fill a plain table and make it a list at the end (as the lualib's own `map` does).
local function __K2L_ListWrap(arr, n)
    arr.size, arr.____modCount = n, 0
    return setmetatable(arr, __K2L_List)
end
