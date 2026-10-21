-- requires: Class, Exceptions
-- kotlin.DeepRecursiveFunction. Its block runs with the function itself as the DeepRecursiveScope. callRecursive calls the
-- block directly up to LIMIT levels deep in one coroutine; deeper, it yields to the trampoline of invoke, which runs the
-- call in a new coroutine. So the recursion uses a coroutine per LIMIT levels instead of the Lua (or C) stack, and is
-- bounded by memory, as on the JVM. A call that is not resumed through the trampoline (callRecursive across a C function
-- such as table.sort's comparator, or pcall on Lua 5.1 outside a try of the program) fails with Lua's "attempt to yield".
local __K2L_DeepRecursive = __K2L_Class("kotlin.DeepRecursiveFunction")

local create, resume, yield, status = coroutine.create, coroutine.resume, coroutine.yield, coroutine.status

local LIMIT = 100
-- the direct calls under way in the running coroutine of a trampoline
local depth = 0
-- what callRecursive yields to ask the trampoline for a call
local CALL = {}

function __K2L_DeepRecursive.new(block)
    return setmetatable({block = block}, __K2L_DeepRecursive)
end

local function run(fn, value)
    return fn.block(fn, value)
end

-- fn(value): the coroutines of the calls form a stack; a finished call resumes its caller with its result (or error)
function __K2L_DeepRecursive:invoke(value)
    local outer = depth
    local stack, n = {create(run)}, 1
    depth = 0
    local ok, a, b, c = resume(stack[1], self, value)
    while true do
        if ok and a == CALL and status(stack[n]) == "suspended" then
            n = n + 1
            stack[n] = create(run)
            depth = 0
            ok, a, b, c = resume(stack[n], b, c)
        elseif ok and status(stack[n]) == "suspended" then
            depth = outer
            error(__K2L_IllegalStateException.new("A DeepRecursiveFunction can only suspend in callRecursive"))
        else
            stack[n] = nil
            n = n - 1
            if n == 0 then
                depth = outer
                if not ok then
                    error(a, 0)
                end
                return a
            end
            depth = LIMIT
            ok, a, b, c = resume(stack[n], ok, a)
        end
    end
end

function __K2L_DeepRecursive:callRecursive(value)
    if depth < LIMIT then
        depth = depth + 1
        local result = self.block(self, value)
        depth = depth - 1
        return result
    end
    local ok, result = yield(CALL, self, value)
    if not ok then
        error(result, 0)
    end
    return result
end
