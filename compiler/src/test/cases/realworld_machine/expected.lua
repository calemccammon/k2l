local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Ushr = ____lualib.__K2L_Ushr
local __K2L_WithDefault = ____lualib.__K2L_WithDefault

local Operand
local Instr = __K2L_Class("Instr")
Instr.Set = __K2L_Class("Instr$Set", Instr)

function Instr.Set.new(reg, value)
    return setmetatable({reg = reg, value = value}, Instr.Set)
end

__K2L_DataClass(Instr.Set, {"reg", "value"})
Instr.Add = __K2L_Class("Instr$Add", Instr)

function Instr.Add.new(reg, value)
    return setmetatable({reg = reg, value = value}, Instr.Add)
end

__K2L_DataClass(Instr.Add, {"reg", "value"})
Instr.Mul = __K2L_Class("Instr$Mul", Instr)

function Instr.Mul.new(reg, value)
    return setmetatable({reg = reg, value = value}, Instr.Mul)
end

__K2L_DataClass(Instr.Mul, {"reg", "value"})
Instr.Mod = __K2L_Class("Instr$Mod", Instr)

function Instr.Mod.new(reg, value)
    return setmetatable({reg = reg, value = value}, Instr.Mod)
end

__K2L_DataClass(Instr.Mod, {"reg", "value"})
Instr.Jnz = __K2L_Class("Instr$Jnz", Instr)

function Instr.Jnz.new(test, offset)
    return setmetatable({test = test, offset = offset}, Instr.Jnz)
end

__K2L_DataClass(Instr.Jnz, {"test", "offset"})
Instr.Out = __K2L_Class("Instr$Out", Instr)

function Instr.Out.new(value)
    return setmetatable({value = value}, Instr.Out)
end

__K2L_DataClass(Instr.Out, {"value"})
Instr.Halt = __K2L_Class("Instr$Halt", Instr)

function Instr.Halt:toString()
    return "Halt"
end

Operand = __K2L_Class("Operand")
Operand.Lit = __K2L_Class("Operand$Lit", nil, Operand)

function Operand.Lit.new(v)
    return setmetatable({v = v}, Operand.Lit)
end

__K2L_DataClass(Operand.Lit, {"v"})
Operand.Reg = __K2L_Class("Operand$Reg", nil, Operand)

function Operand.Reg.new(r)
    return setmetatable({r = r}, Operand.Reg)
end

__K2L_DataClass(Operand.Reg, {"r"})

local function parseOperand(s)
    local ____receiver = __K2L_StringToIntOrNull(s, nil, true)
    return ____receiver and Operand.Lit.new(____receiver) or Operand.Reg.new(__K2L_Text.single(s))
end

local OP = __K2L_Regex.new("\\w{3}", "[%w_][%w_][%w_]")

local ____lambda_1 = function(it) return "" end
local function parseProgram(text)
    local ____list = __K2L_StringLines(text)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringTrim(__K2L_Text.substringBefore(it, "#"))
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if #it > 0 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    local ____list_2 = __K2L_ListWrap(____out_1, ____count_1)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_3 = 1, ____n_2 do
        local line = ____items_2[____i_3]
        local ____result
        do
            local parts = __K2L_Regex.new("\\s+", "%s+"):split(line)
            if parts.size > 3 or not OP:matches(parts:get(0)) then
                error(__K2L_IllegalArgumentException.new("bad line: '" .. line .. "'"))
            end
            local ____out_3 = {}
            for ____i_2 = 1, 3 do
                local it = ____i_2 - 1
                local ____result_1
                ____result_1 = parts:getOrElse(it, ____lambda_1)
                ____out_3[____i_2] = ____result_1
            end
            local ____destructured = __K2L_ListWrap(____out_3, 3)
            local op, a, b = ____destructured[1], ____destructured[2], ____destructured[3]
            if op == "set" then
                ____result = Instr.Set.new(0 >= 0 and 0 < #a and a:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #a, "string"), parseOperand(b))
            elseif op == "add" then
                ____result = Instr.Add.new(0 >= 0 and 0 < #a and a:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #a, "string"), parseOperand(b))
            elseif op == "mul" then
                ____result = Instr.Mul.new(0 >= 0 and 0 < #a and a:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #a, "string"), parseOperand(b))
            elseif op == "mod" then
                ____result = Instr.Mod.new(0 >= 0 and 0 < #a and a:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #a, "string"), parseOperand(b))
            elseif op == "jnz" then
                ____result = Instr.Jnz.new(parseOperand(a), parseOperand(b))
            elseif op == "out" then
                ____result = Instr.Out.new(parseOperand(a))
            elseif op == "hlt" then
                ____result = Instr.Halt
            else
                error(__K2L_IllegalStateException.new("unknown op " .. op))
            end
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result
    end
    return __K2L_ListWrap(____out_2, ____count_2)
end

local Machine = __K2L_Class("Machine")

local ____lambda_2 = function(it) return 0 end
function Machine:____init(program)
    self.program = program
    self.registers = __K2L_WithDefault(__K2L_MapOf(), ____lambda_2)
    self.output = __K2L_ListOf()
    self.steps = 0
end

function Machine:value(____this)
    local ____mt = getmetatable(____this)
    if ____mt == Operand.Lit then
        return ____this.v
    elseif ____mt == Operand.Reg then
        return self.registers:getValue(____this.r)
    end
end

function Machine:run(limit)
    if limit == nil then
        limit = 10000
    end
    do
        local pc = 0
        while self.program:getIndices():contains(pc) and self.steps < limit do
            do
                self.steps = self.steps + 1
                local ins = self.program:get(pc)
                local ____mt_1 = getmetatable(ins)
                if ____mt_1 == Instr.Set then
                    local ____object_3 = self.registers
                    local ____key_3 = ins.reg
                    ____object_3:set(____key_3, self:value(ins.value))
                elseif ____mt_1 == Instr.Add then
                    local ____object_2 = self.registers
                    local ____key_2 = ins.reg
                    ____object_2:set(____key_2, self.registers:getValue(ins.reg) + self:value(ins.value))
                elseif ____mt_1 == Instr.Mul then
                    local ____object_1 = self.registers
                    local ____key_1 = ins.reg
                    ____object_1:set(____key_1, self.registers:getValue(ins.reg) * self:value(ins.value))
                elseif ____mt_1 == Instr.Mod then
                    local ____object = self.registers
                    local ____key = ins.reg
                    ____object:set(____key, self.registers:getValue(ins.reg) % self:value(ins.value))
                elseif ____mt_1 == Instr.Jnz then
                    if self:value(ins.test) ~= 0 then
                        pc = pc + self:value(ins.offset)
                        goto ____continue
                    end
                elseif ____mt_1 == Instr.Out then
                    self.output:add(self:value(ins.value))
                elseif __K2L_Equals(ins, Instr.Halt) then
                    goto ____inline_end
                end
                pc = pc + 1
            end
            ::____continue::
        end
        ::____inline_end::
    end
    return self
end

local PROGRAM = "\n    set a 10      # counter\n    set b 1\n    set f 0\n    mul b 3       # loop start\n    mod b 1000\n    add f b\n    out b\n    add a -1\n    jnz a -5\n    out f\n    hlt\n    out 999       # never reached\n"

local function applyMask(mask, value)
    local result = value
    local ____chars = __K2L_StringToList(mask:reverse())
    for ____bit = 0, ____chars.size - 1 do
        local c = ____chars[____bit + 1]
        if c == "1" then
            result = result | 1 << ____bit
        elseif c == "0" then
            result = result & ~(1 << ____bit)
        end
    end
    return result
end

local ____lambda_3 = function(____bit, acc, c)
    return c == "1" and acc | 1 << ____bit or acc
end
local ____lambda_4 = function(it) return it.value == "X" end
local function floatingAddresses(mask, address)
    local base = __K2L_StringToList(mask:reverse()):foldIndexed(address, ____lambda_3)
    local ____list_3 = __K2L_StringToList(mask:reverse()):withIndex():filter(____lambda_4)
    local ____out_4 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        ____count_3 = ____count_3 + 1
        ____out_4[____count_3] = it.index
    end
    local floating = __K2L_ListWrap(____out_4, ____count_3)
    return __K2L_IntRange.new(0, __K2L_Shl(1, floating.size) - 1):map(function(combo)
        return floating:foldIndexed(base, function(i, acc, ____bit)
            return combo & __K2L_Shl(1, i) ~= 0 and acc | 1 << ____bit or acc & ~(1 << ____bit)
        end)
    end):sorted()
end

local MEMORY = __K2L_Text.trimIndent("\n    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X\n    mem[8] = 11\n    mem[7] = 101\n    mem[8] = 0\n    mask = 000000000000000000000000000000X1001X\n    mem[42] = 100\n")

local ____lambda_5 = function(____p1)
    return __K2L_StringToInt(____p1, nil, true)
end
local function runMemory(text)
    local mem = __K2L_SortedMapOf(nil)
    local mask = ""
    local memLine = __K2L_Regex.new("mem\\[(\\d+)] = (\\d+)", "mem%[(%d+)%] = (%d+)")
    for _, line in __K2L_AsSequence(__K2L_StringLines(text)):iter() do
        do
            if __K2L_StringStartsWith(line, "mask") then
                mask = __K2L_Text.substringAfter(line, "= ")
                goto ____continue_1
            end
            local ____destructured_1 = __K2L_NotNull(memLine:find(line)).groupValues:drop(1):map(____lambda_5)
            local addr, value = ____destructured_1[1], ____destructured_1[2]
            mem:set(addr, applyMask(mask, value))
        end
        ::____continue_1::
    end
    return __K2L_Pair.new(mem:getValues():sum(), mem)
end

local CIRCUIT = __K2L_Text.trimIndent("\n    123 -> x\n    456 -> y\n    x AND y -> d\n    x OR y -> e\n    x LSHIFT 2 -> f\n    y RSHIFT 2 -> g\n    NOT x -> h\n    NOT y -> i\n    d OR f -> j\n    j AND e -> a\n")
local Circuit = __K2L_Class("Circuit")

function Circuit:____init(text)
    self.rules = __K2L_StringLines(text):associate(function(line)
        local ____destructured_2 = __K2L_StringSplit(line, " -> ")
        local expr, target = ____destructured_2[1], ____destructured_2[2]
        return __K2L_Pair.new(target, __K2L_StringSplit(expr, " "))
    end)
    self.cache = __K2L_Map.new()
    self.evaluations = 0
end

function Circuit:signal(wire)
    local ____receiver_1 = __K2L_StringToIntOrNull(wire)
    if ____receiver_1 ~= nil then
        local ____result_2
        return ____receiver_1
    end
    return self.cache:getOrPut(wire, function()
        self.evaluations = self.evaluations + 1
        local ____value = self.rules:get(wire)
        if ____value == nil then
            error(__K2L_NoSuchElementException.new("no wire " .. wire))
        end
        local parts = ____value
        local value
        local ____subject = parts.size
        if ____subject == 1 then
            value = self:signal(parts:get(0))
        elseif ____subject == 2 then
            value = ~self:signal(parts:get(1))
        else
            local l, op, r = parts[1], parts[2], parts[3]
            if op == "AND" then
                value = self:signal(l) & self:signal(r)
            elseif op == "OR" then
                value = self:signal(l) | self:signal(r)
            elseif op == "LSHIFT" then
                value = __K2L_Shl(self:signal(l), self:signal(r))
            elseif op == "RSHIFT" then
                value = __K2L_Ushr(self:signal(l), self:signal(r))
            else
                error(__K2L_IllegalStateException.new("bad op " .. op))
            end
        end
        return value & 65535
    end)
end

local ____lambda_6 = function(it) return __K2L_SimpleName(it) end
local ____lambda_7 = function(it) return __K2L_Num.countOneBits(it) end
local function main()
    local program = parseProgram(PROGRAM)
    print(program.size .. " instructions; first: " .. __K2L_Str(program:first()) .. ", last: " .. __K2L_Str(program:last()))
    print(__K2L_Str(program:groupingBy(____lambda_6):eachCount()))
    local m = Machine.new(program):run()
    print("output=" .. __K2L_Str(m.output))
    print("registers=" .. __K2L_Str(m.registers:toSortedMap()) .. " steps=" .. m.steps)
    print("a=" .. m.registers:getValue("a") .. " z=" .. m.registers:getValue("z"))
    local looping = parseProgram("set a 1\njnz a 0")
    print("looping steps: " .. Machine.new(looping):run(50).steps)
    local ____ok, ____result_3 = pcall(function()
        parseProgram("set a\nfoo")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error, __K2L_RuntimeException) then
            local e = ____error
            print("error: " .. __K2L_Str(e))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_4 = pcall(function()
        parseProgram("set a 1\nfoo bar baz qux")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_5 = pcall(function()
        parseProgram("xyz a 1")
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local ____destructured_3 = runMemory(MEMORY)
    local sum, mem = ____destructured_3.first, ____destructured_3.second
    print("memory sum=" .. sum .. " mem=" .. __K2L_Str(mem))
    print("floating: " .. __K2L_Str(floatingAddresses("000000000000000000000000000000X1001X", 42)))
    print("mask bits: " .. #__K2L_Num.toRadix(applyMask(("1"):rep(36), 0), 2) .. " " .. __K2L_Num.toRadix(applyMask("X1X0", 9), 2))
    local bits = __K2L_IntRange.new(0, 16):map(____lambda_7)
    print("bit counts: " .. __K2L_Str(bits) .. " highest=" .. __K2L_Bits.highest32(100) .. " trailing=" .. __K2L_Num.countTrailingZeroBits(96))
    local circuit = Circuit.new(CIRCUIT)
    local ____list_4 = __K2L_ListOf("d", "e", "f", "g", "h", "i", "x", "y", "a")
    for ____i_5 = 1, ____list_4.size do
        local w = ____list_4[____i_5]
        io.write(w .. "=" .. circuit:signal(w) .. " ")
    end
    print()
    print("evaluations=" .. circuit.evaluations)
    print(__K2L_Str(__K2L_RunCatching(function() return circuit:signal("zz") end):exceptionOrNull()))
end

__K2L_RunMain(main)
return {Instr = Instr, Operand = Operand, parseOperand = parseOperand, parseProgram = parseProgram, Machine = Machine, PROGRAM = PROGRAM, applyMask = applyMask, floatingAddresses = floatingAddresses, MEMORY = MEMORY, runMemory = runMemory, CIRCUIT = CIRCUIT, Circuit = Circuit}
