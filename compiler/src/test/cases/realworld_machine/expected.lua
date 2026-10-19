local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unsigned = ____lualib.__K2L_Unsigned
local __K2L_Ushr = ____lualib.__K2L_Ushr

local Operand
local Instr = __K2L_Class("Instr")
__K2L_ClassInfo(Instr, "Instr", "Instr", "class")
Instr.Set = __K2L_Class("Instr$Set", Instr)
__K2L_ClassInfo(Instr.Set, "Instr.Set", "Instr$Set", "class")

function Instr.Set:____init(reg, value)
    self.reg = reg
    self.value = value
end

function Instr.Set:toString()
    return "Set(reg=" .. self.reg .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Instr.Set:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.reg) + __K2L_Hash(self.value))
end

function Instr.Set:equals(other)
    return getmetatable(other) == Instr.Set and self.reg == other.reg and __K2L_Equals(self.value, other.value)
end

Instr.Add = __K2L_Class("Instr$Add", Instr)
__K2L_ClassInfo(Instr.Add, "Instr.Add", "Instr$Add", "class")

function Instr.Add:____init(reg, value)
    self.reg = reg
    self.value = value
end

function Instr.Add:toString()
    return "Add(reg=" .. self.reg .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Instr.Add:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.reg) + __K2L_Hash(self.value))
end

function Instr.Add:equals(other)
    return getmetatable(other) == Instr.Add and self.reg == other.reg and __K2L_Equals(self.value, other.value)
end

Instr.Mul = __K2L_Class("Instr$Mul", Instr)
__K2L_ClassInfo(Instr.Mul, "Instr.Mul", "Instr$Mul", "class")

function Instr.Mul:____init(reg, value)
    self.reg = reg
    self.value = value
end

function Instr.Mul:toString()
    return "Mul(reg=" .. self.reg .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Instr.Mul:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.reg) + __K2L_Hash(self.value))
end

function Instr.Mul:equals(other)
    return getmetatable(other) == Instr.Mul and self.reg == other.reg and __K2L_Equals(self.value, other.value)
end

Instr.Mod = __K2L_Class("Instr$Mod", Instr)
__K2L_ClassInfo(Instr.Mod, "Instr.Mod", "Instr$Mod", "class")

function Instr.Mod:____init(reg, value)
    self.reg = reg
    self.value = value
end

function Instr.Mod:toString()
    return "Mod(reg=" .. self.reg .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Instr.Mod:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.reg) + __K2L_Hash(self.value))
end

function Instr.Mod:equals(other)
    return getmetatable(other) == Instr.Mod and self.reg == other.reg and __K2L_Equals(self.value, other.value)
end

Instr.Jnz = __K2L_Class("Instr$Jnz", Instr)
__K2L_ClassInfo(Instr.Jnz, "Instr.Jnz", "Instr$Jnz", "class")

function Instr.Jnz:____init(test, offset)
    self.test = test
    self.offset = offset
end

function Instr.Jnz:toString()
    return "Jnz(test=" .. __K2L_Str(self.test) .. ", offset=" .. __K2L_Str(self.offset) .. ")"
end

function Instr.Jnz:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.test) + __K2L_Hash(self.offset))
end

function Instr.Jnz:equals(other)
    return getmetatable(other) == Instr.Jnz and __K2L_Equals(self.test, other.test) and __K2L_Equals(self.offset, other.offset)
end

Instr.Out = __K2L_Class("Instr$Out", Instr)
__K2L_ClassInfo(Instr.Out, "Instr.Out", "Instr$Out", "class")

function Instr.Out:____init(value)
    self.value = value
end

function Instr.Out:toString()
    return "Out(value=" .. __K2L_Str(self.value) .. ")"
end

function Instr.Out:hashCode()
    return __K2L_Hash(self.value)
end

function Instr.Out:equals(other)
    return getmetatable(other) == Instr.Out and __K2L_Equals(self.value, other.value)
end

Instr.Halt = __K2L_Class("Instr$Halt", Instr)
__K2L_ClassInfo(Instr.Halt, "Instr.Halt", "Instr$Halt", "class")

function Instr.Halt:toString()
    return "Halt"
end

Operand = __K2L_Class("Operand")
__K2L_ClassInfo(Operand, "Operand", "Operand", "interface")
Operand.Lit = __K2L_Class("Operand$Lit", nil, Operand)
__K2L_ClassInfo(Operand.Lit, "Operand.Lit", "Operand$Lit", "class")

function Operand.Lit:____init(v)
    self.v = v
end

function Operand.Lit:toString()
    return "Lit(v=" .. self.v .. ")"
end

function Operand.Lit:hashCode()
    return __K2L_Hash(self.v)
end

function Operand.Lit:equals(other)
    return getmetatable(other) == Operand.Lit and self.v == other.v
end

Operand.Reg = __K2L_Class("Operand$Reg", nil, Operand)
__K2L_ClassInfo(Operand.Reg, "Operand.Reg", "Operand$Reg", "class")

function Operand.Reg:____init(r)
    self.r = r
end

function Operand.Reg:toString()
    return "Reg(r=" .. self.r .. ")"
end

function Operand.Reg:hashCode()
    return __K2L_Hash(self.r)
end

function Operand.Reg:equals(other)
    return getmetatable(other) == Operand.Reg and self.r == other.r
end

local function parseOperand(s)
    local ____receiver = __K2L_StringToIntOrNull(s, nil, true)
    return ____receiver and Operand.Lit.new(____receiver) or Operand.Reg.new(__K2L_Text.single(s))
end

local INSTR = __K2L_Regex.new("^(\\w{3})(?:\\s+(\\S+))?(?:\\s+(\\S+))?$")

local function parseProgram(text)
    return __K2L_StringLines(text):map(function(it)
        return __K2L_StringTrim(__K2L_Text.substringBefore(it, "#"))
    end):filter(function(it) return #it > 0 end):map(function(line)
        local ____value = INSTR:matchEntire(line)
        if ____value == nil then
            error(__K2L_IllegalArgumentException.new("bad line: '" .. line .. "'"))
        end
        local match = ____value
        local ____destructured = match.destructured
        local op, a, b = ____destructured[1], ____destructured[2], ____destructured[3]
        if op == "set" then
            return Instr.Set.new(__K2L_StringCharAt(a, 0), parseOperand(b))
        elseif op == "add" then
            return Instr.Add.new(__K2L_StringCharAt(a, 0), parseOperand(b))
        elseif op == "mul" then
            return Instr.Mul.new(__K2L_StringCharAt(a, 0), parseOperand(b))
        elseif op == "mod" then
            return Instr.Mod.new(__K2L_StringCharAt(a, 0), parseOperand(b))
        elseif op == "jnz" then
            return Instr.Jnz.new(parseOperand(a), parseOperand(b))
        elseif op == "out" then
            return Instr.Out.new(parseOperand(a))
        elseif op == "hlt" then
            return Instr.Halt
        else
            error(__K2L_IllegalStateException.new("unknown op " .. op))
        end
    end)
end

local Machine = __K2L_Class("Machine")
__K2L_ClassInfo(Machine, "Machine", "Machine", "class")

function Machine:____init(program)
    self.program = program
    self.registers = __K2L_JdkCollections.withDefault(__K2L_MapOf(), function(it) return 0 end)
    self.output = __K2L_ListOf()
    self.steps = 0
end

function Machine:value(____this)
    if __K2L_InstanceOf(____this, Operand.Lit) then
        return ____this.v
    elseif __K2L_InstanceOf(____this, Operand.Reg) then
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
                if __K2L_InstanceOf(ins, Instr.Set) then
                    local ____object_3 = self.registers
                    local ____key_3 = ins.reg
                    ____object_3:set(____key_3, self:value(ins.value))
                elseif __K2L_InstanceOf(ins, Instr.Add) then
                    local ____object_2 = self.registers
                    local ____key_2 = ins.reg
                    ____object_2:set(____key_2, self.registers:getValue(ins.reg) + self:value(ins.value))
                elseif __K2L_InstanceOf(ins, Instr.Mul) then
                    local ____object_1 = self.registers
                    local ____key_1 = ins.reg
                    ____object_1:set(____key_1, self.registers:getValue(ins.reg) * self:value(ins.value))
                elseif __K2L_InstanceOf(ins, Instr.Mod) then
                    local ____object = self.registers
                    local ____key = ins.reg
                    ____object:set(____key, __K2L_IRem(self.registers:getValue(ins.reg), self:value(ins.value)))
                elseif __K2L_InstanceOf(ins, Instr.Jnz) then
                    if self:value(ins.test) ~= 0 then
                        pc = pc + __K2L_ToInt32(self:value(ins.offset))
                        goto ____continue
                    end
                elseif __K2L_InstanceOf(ins, Instr.Out) then
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
    for bit = 0, ____chars.size - 1 do
        local c = ____chars[bit + 1]
        if c == "1" then
            result = result | 1 << bit
        elseif c == "0" then
            result = result & ~(1 << bit)
        end
    end
    return result
end

local function floatingAddresses(mask, address)
    local base = __K2L_StringToList(mask:reverse()):foldIndexed(address, function(bit, acc, c)
        return c == "1" and acc | 1 << bit or acc
    end)
    local floating = __K2L_StringToList(mask:reverse()):withIndex():filter(function(it) return it.value == "X" end):map(function(it) return it.index end)
    return __K2L_IntRange.new(0, __K2L_Shl(1, floating.size) - 1):map(function(combo)
        return floating:foldIndexed(base, function(i, acc, bit)
            return combo & __K2L_Shl(1, i) ~= 0 and acc | 1 << bit or acc & ~(1 << bit)
        end)
    end):sorted()
end

local MEMORY = __K2L_Text.trimIndent("\n    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X\n    mem[8] = 11\n    mem[7] = 101\n    mem[8] = 0\n    mask = 000000000000000000000000000000X1001X\n    mem[42] = 100\n")

local function runMemory(text)
    local mem = __K2L_SortedMapOf()
    local mask = ""
    local memLine = __K2L_Regex.new("mem\\[(\\d+)] = (\\d+)")
    for _, line in __K2L_AsSequence(__K2L_StringLines(text)):iter() do
        do
            if __K2L_StringStartsWith(line, "mask") then
                mask = __K2L_Text.substringAfter(line, "= ")
                goto ____continue_1
            end
            local ____destructured_1 = __K2L_NotNull(memLine:find(line)).groupValues:drop(1):map(function(____p1)
                return __K2L_StringToInt(____p1, nil, true)
            end)
            local addr, value = ____destructured_1[1], ____destructured_1[2]
            mem:set(addr, applyMask(mask, value))
        end
        ::____continue_1::
    end
    return __K2L_Pair.new(mem:getValues():sum(), mem)
end

local CIRCUIT = __K2L_Text.trimIndent("\n    123 -> x\n    456 -> y\n    x AND y -> d\n    x OR y -> e\n    x LSHIFT 2 -> f\n    y RSHIFT 2 -> g\n    NOT x -> h\n    NOT y -> i\n    d OR f -> j\n    j AND e -> a\n")
local Circuit = __K2L_Class("Circuit")
__K2L_ClassInfo(Circuit, "Circuit", "Circuit", "class")

function Circuit:____init(text)
    self.rules = __K2L_StringLines(text):associate(function(line)
        local ____destructured_2 = __K2L_StringSplit(line, " -> ")
        local expr, target = ____destructured_2[1], ____destructured_2[2]
        return __K2L_Pair.new(target, __K2L_StringSplit(expr, " "))
    end)
    self.cache = __K2L_HashMap.new()
    self.evaluations = 0
end

function Circuit:signal(wire)
    local ____receiver_1 = __K2L_StringToIntOrNull(wire)
    if ____receiver_1 ~= nil then
        local ____result
        return ____receiver_1
    end
    return self.cache:getOrPut(wire, function()
        self.evaluations = self.evaluations + 1
        local ____value_1 = self.rules:get(wire)
        if ____value_1 == nil then
            error(__K2L_NoSuchElementException.new("no wire " .. wire))
        end
        local parts = ____value_1
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

local function main()
    local program = parseProgram(PROGRAM)
    print(program.size .. " instructions; first: " .. __K2L_Str(program:first()) .. ", last: " .. __K2L_Str(program:last()))
    print(__K2L_Str(program:groupingBy(function(it) return __K2L_KClassOfValue(it).simpleName end):eachCount()))
    local m = Machine.new(program):run()
    print("output=" .. __K2L_Str(m.output))
    print("registers=" .. __K2L_Str(m.registers:toSortedMap()) .. " steps=" .. m.steps)
    print("a=" .. m.registers:getValue("a") .. " z=" .. m.registers:getValue("z"))
    local looping = parseProgram("set a 1\njnz a 0")
    print("looping steps: " .. Machine.new(looping):run(50).steps)
    local ____ok, ____result_1 = pcall(function()
        parseProgram("set a\nfoo")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_RuntimeException) then
            local e = ____error
            print("error: " .. __K2L_Str(e))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_2 = pcall(function()
        parseProgram("set a 1\nfoo bar baz qux")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_3 = pcall(function()
        parseProgram("xyz a 1")
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_3)
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
    print("mask bits: " .. #__K2L_Num.toRadix(applyMask(("1"):rep(36), 0), 2) .. " " .. __K2L_Str(__K2L_Unsigned.toRadix(applyMask("X1X0", 9), 2)))
    local bits = __K2L_IntRange.new(0, 16):map(function(it) return __K2L_Num.countOneBits(it) end)
    print("bit counts: " .. __K2L_Str(bits) .. " highest=" .. __K2L_Bits.highest32(100) .. " trailing=" .. __K2L_Num.countTrailingZeroBits(96))
    local circuit = Circuit.new(CIRCUIT)
    for _, w in ipairs(__K2L_ReadOnlyListOf("d", "e", "f", "g", "h", "i", "x", "y", "a")) do
        io.write(w .. "=" .. circuit:signal(w) .. " ")
    end
    print()
    print("evaluations=" .. circuit.evaluations)
    print(__K2L_Str(__K2L_RunCatching(function() return circuit:signal("zz") end):exceptionOrNull()))
end

main()
return {Instr = Instr, Operand = Operand, parseOperand = parseOperand, parseProgram = parseProgram, Machine = Machine, PROGRAM = PROGRAM, applyMask = applyMask, floatingAddresses = floatingAddresses, MEMORY = MEMORY, runMemory = runMemory, CIRCUIT = CIRCUIT, Circuit = Circuit}
