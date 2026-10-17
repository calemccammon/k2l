local log = ""

local function trace(label, value)
    log = log .. label
    return value
end

local function add(a, b, c)
    return a + b + c
end

local function main()
    local ____arg = trace("a", 1)
    local ____temp
    if trace("b", 0) > 0 then
        ____temp = 10
    else
        log = log .. "!"
        ____temp = 20
    end
    local r = add(____arg, ____temp, trace("c", 3))
    print(r)
    print(log)
    local i = 0
    local ____old = i
    i = i + 1
    local old = ____old
    i = i + 1
    local new = i
    print(old .. " " .. new .. " " .. i)
    log = ""
    local ____cond = trace("x", 0) > 0
    if ____cond then
        local ____temp_1
        local ____subject = trace("y", 1)
        if ____subject == 1 then
            ____temp_1 = true
        else
            ____temp_1 = false
        end
        ____cond = ____temp_1
    end
    local both = ____cond
    print(tostring(both) .. " " .. log)
    log = ""
    local ____cond_1 = trace("x", 1) > 0
    if not ____cond_1 then
        local ____temp_2
        local ____subject_1 = trace("y", 1)
        if ____subject_1 == 1 then
            ____temp_2 = true
        else
            ____temp_2 = false
        end
        ____cond_1 = ____temp_2
    end
    local either = ____cond_1
    print(tostring(either) .. " " .. log)
end

main()
return {log = log, trace = trace, add = add}
