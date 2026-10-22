local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Insn = __K2L_Class("Insn")
Insn.Push = __K2L_Class("Insn$Push", Insn)

function Insn.Push:____init(v)
    self.v = v
end

function Insn.Push.new(v)
    return setmetatable({v = v}, Insn.Push)
end

function Insn.Push:toString()
    return "Push(v=" .. self.v .. ")"
end

function Insn.Push:hashCode()
    return self.v
end

function Insn.Push:equals(other)
    return getmetatable(other) == Insn.Push and self.v == other.v
end

Insn.Load = __K2L_Class("Insn$Load", Insn)

function Insn.Load:____init(slot)
    self.slot = slot
end

function Insn.Load.new(slot)
    return setmetatable({slot = slot}, Insn.Load)
end

function Insn.Load:toString()
    return "Load(slot=" .. self.slot .. ")"
end

function Insn.Load:hashCode()
    return self.slot
end

function Insn.Load:equals(other)
    return getmetatable(other) == Insn.Load and self.slot == other.slot
end

Insn.Store = __K2L_Class("Insn$Store", Insn)

function Insn.Store:____init(slot)
    self.slot = slot
end

function Insn.Store.new(slot)
    return setmetatable({slot = slot}, Insn.Store)
end

function Insn.Store:toString()
    return "Store(slot=" .. self.slot .. ")"
end

function Insn.Store:hashCode()
    return self.slot
end

function Insn.Store:equals(other)
    return getmetatable(other) == Insn.Store and self.slot == other.slot
end

Insn.Jump = __K2L_Class("Insn$Jump", Insn)

function Insn.Jump:____init(target)
    self.target = target
end

function Insn.Jump.new(target)
    return setmetatable({target = target}, Insn.Jump)
end

function Insn.Jump:toString()
    return "Jump(target=" .. self.target .. ")"
end

function Insn.Jump:hashCode()
    return self.target
end

function Insn.Jump:equals(other)
    return getmetatable(other) == Insn.Jump and self.target == other.target
end

Insn.JumpIfZero = __K2L_Class("Insn$JumpIfZero", Insn)

function Insn.JumpIfZero:____init(target)
    self.target = target
end

function Insn.JumpIfZero.new(target)
    return setmetatable({target = target}, Insn.JumpIfZero)
end

function Insn.JumpIfZero:toString()
    return "JumpIfZero(target=" .. self.target .. ")"
end

function Insn.JumpIfZero:hashCode()
    return self.target
end

function Insn.JumpIfZero:equals(other)
    return getmetatable(other) == Insn.JumpIfZero and self.target == other.target
end

Insn.Call = __K2L_Class("Insn$Call", Insn)

function Insn.Call:____init(target)
    self.target = target
end

function Insn.Call.new(target)
    return setmetatable({target = target}, Insn.Call)
end

function Insn.Call:toString()
    return "Call(target=" .. self.target .. ")"
end

function Insn.Call:hashCode()
    return self.target
end

function Insn.Call:equals(other)
    return getmetatable(other) == Insn.Call and self.target == other.target
end

Insn.Arith = __K2L_Class("Insn$Arith", Insn)

function Insn.Arith:____init(op)
    self.op = op
end

function Insn.Arith.new(op)
    return setmetatable({op = op}, Insn.Arith)
end

function Insn.Arith:toString()
    return "Arith(op=" .. self.op .. ")"
end

function Insn.Arith:hashCode()
    return __K2L_Hash(self.op)
end

function Insn.Arith:equals(other)
    return getmetatable(other) == Insn.Arith and self.op == other.op
end

Insn.Cmp = __K2L_Class("Insn$Cmp", Insn)

function Insn.Cmp:____init(op)
    self.op = op
end

function Insn.Cmp.new(op)
    return setmetatable({op = op}, Insn.Cmp)
end

function Insn.Cmp:toString()
    return "Cmp(op=" .. self.op .. ")"
end

function Insn.Cmp:hashCode()
    return __K2L_Hash(self.op)
end

function Insn.Cmp:equals(other)
    return getmetatable(other) == Insn.Cmp and self.op == other.op
end

Insn.Ret = __K2L_Class("Insn$Ret", Insn)

function Insn.Ret:toString()
    return "Ret"
end

function Insn.Ret:hashCode()
    return 612684787
end

Insn.Dup = __K2L_Class("Insn$Dup", Insn)

function Insn.Dup:toString()
    return "Dup"
end

function Insn.Dup:hashCode()
    return 612671825
end

Insn.Swap = __K2L_Class("Insn$Swap", Insn)

function Insn.Swap:toString()
    return "Swap"
end

function Insn.Swap:hashCode()
    return 1813405825
end

Insn.Pop = __K2L_Class("Insn$Pop", Insn)

function Insn.Pop:toString()
    return "Pop"
end

function Insn.Pop:hashCode()
    return 612683171
end

Insn.Print = __K2L_Class("Insn$Print", Insn)

function Insn.Print:toString()
    return "Print"
end

function Insn.Print:hashCode()
    return 378093951
end

Insn.Emit = __K2L_Class("Insn$Emit", Insn)

function Insn.Emit:toString()
    return "Emit"
end

function Insn.Emit:hashCode()
    return 1812979393
end

Insn.Halt = __K2L_Class("Insn$Halt", Insn)

function Insn.Halt:toString()
    return "Halt"
end

function Insn.Halt:hashCode()
    return 1813057327
end

local AsmError = __K2L_Class("AsmError", __K2L_Exception)

function AsmError:____init(lineNo, msg)
    __K2L_Exception.____init(self, "asm line " .. lineNo .. ": " .. msg)
    self.lineNo = lineNo
end

local VmFault = __K2L_Class("VmFault", __K2L_Exception)

function VmFault:____init(pc, msg)
    __K2L_Exception.____init(self, "fault at pc=" .. pc .. ": " .. msg)
    self.pc = pc
end

local Assembler = __K2L_Class("Assembler")

function Assembler:____init()
    self.labelDef = __K2L_Regex.new("^([A-Za-z_][\\w.]*):$", "^([A-Za-z_][%w_%.]*):$")
    self.arithOps = __K2L_MapOf(__K2L_Pair.new("add", "+"), __K2L_Pair.new("sub", "-"), __K2L_Pair.new("mul", "*"), __K2L_Pair.new("div", "/"), __K2L_Pair.new("mod", "%"), __K2L_Pair.new("and", "&"), __K2L_Pair.new("or", "|"), __K2L_Pair.new("xor", "^"), __K2L_Pair.new("shl", "<"))
    self.cmpOps = __K2L_MapOf(__K2L_Pair.new("eq", "=="), __K2L_Pair.new("ne", "!="), __K2L_Pair.new("lt", "<"), __K2L_Pair.new("le", "<="), __K2L_Pair.new("gt", ">"), __K2L_Pair.new("ge", ">="))
end

function Assembler:cleaned(src)
    local ____list = __K2L_StringLines(src)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local l = ____items[____i]
        local n = ____i - 1
        ____count = ____count + 1
        ____out[____count] = __K2L_Pair.new(n + 1, __K2L_StringTrim(__K2L_Text.substringBefore(l, ";")))
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if #it.second > 0 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

function Assembler:assemble(src)
    local labels = __K2L_Map.new()
    local addr = 0
    local ____list_2 = self:cleaned(src)
    for ____i_2 = 1, ____list_2.size do
        local ____item = ____list_2[____i_2]
        local n, l = ____item.first, ____item.second
        local m = self.labelDef:matchEntire(l)
        if m ~= nil then
            local name = m.groupValues:get(1)
            if labels:put(name, addr) ~= nil then
                error(AsmError.new(n, "duplicate label '" .. name .. "'"))
            end
        else
            addr = addr + 1
        end
    end
    local out = __K2L_List.new()
    local ____list_3 = self:cleaned(src)
    for ____i_3 = 1, ____list_3.size do
        local ____item_1 = ____list_3[____i_3]
        local n, l = ____item_1.first, ____item_1.second
        do
            if self.labelDef:matches(l) then
                goto ____continue
            end
            local parts = __K2L_Regex.new("\\s+", "%s+"):split(l, 2)
            local op = parts:get(0):lower()
            local arg = parts:getOrNull(1)
            local function need()
                if arg == nil then
                    error(AsmError.new(n, "'" .. op .. "' needs an operand"))
                end
                return arg
            end
            local function num()
                local ____value = need()
                local ____result
                do
                    local ____temp
                    if __K2L_StringStartsWith(____value, "'") and __K2L_StringEndsWith(____value, "'") and #____value == 3 then
                        ____temp = (1 >= 0 and 1 < #____value and ____value:sub(1 + 1, 1 + 1) or __K2L_IndexError(1, #____value, "string")):byte()
                    elseif __K2L_StringStartsWith(____value, "0x") then
                        ____temp = __K2L_StringToIntOrNull(__K2L_Text.substring(____value, 2), 16)
                    else
                        ____temp = __K2L_StringToIntOrNull(____value)
                    end
                    local ____value_1 = ____temp
                    if ____value_1 == nil then
                        error(AsmError.new(n, "bad number '" .. ____value .. "'"))
                    end
                    ____result = ____value_1
                end
                return ____result
            end
            local function label()
                local ____value_2 = labels:get(need())
                if ____value_2 == nil then
                    error(AsmError.new(n, "unknown label '" .. need() .. "'"))
                end
                return ____value_2
            end
            local ____temp_1
            if op == "push" then
                ____temp_1 = Insn.Push.new(num())
            elseif op == "load" then
                ____temp_1 = Insn.Load.new(num())
            elseif op == "store" then
                ____temp_1 = Insn.Store.new(num())
            elseif op == "jmp" then
                ____temp_1 = Insn.Jump.new(label())
            elseif op == "jz" then
                ____temp_1 = Insn.JumpIfZero.new(label())
            elseif op == "call" then
                ____temp_1 = Insn.Call.new(label())
            elseif self.arithOps:containsKey(op) then
                ____temp_1 = Insn.Arith.new(self.arithOps:getValue(op))
            elseif self.cmpOps:containsKey(op) then
                ____temp_1 = Insn.Cmp.new(self.cmpOps:getValue(op))
            elseif op == "ret" then
                ____temp_1 = Insn.Ret
            elseif op == "dup" then
                ____temp_1 = Insn.Dup
            elseif op == "swap" then
                ____temp_1 = Insn.Swap
            elseif op == "pop" then
                ____temp_1 = Insn.Pop
            elseif op == "print" then
                ____temp_1 = Insn.Print
            elseif op == "emit" then
                ____temp_1 = Insn.Emit
            elseif op == "halt" then
                ____temp_1 = Insn.Halt
            else
                error(AsmError.new(n, "unknown mnemonic '" .. parts:get(0) .. "'"))
            end
            out:add(____temp_1)
        end
        ::____continue::
    end
    return out
end

__K2L_LazyObject(Assembler, "____init")

local function disassemble(code)
    return __K2L_SequenceBuilder(function(self)
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_2, ____n_2 = code:____array()
        for ____i_4 = 1, ____n_2 do
            local it = ____items_2[____i_4]
            local ____result_1
            do
                local ____mt = getmetatable(it)
                if ____mt == Insn.Jump then
                    ____result_1 = it.target
                elseif ____mt == Insn.JumpIfZero then
                    ____result_1 = it.target
                elseif ____mt == Insn.Call then
                    ____result_1 = it.target
                else
                    ____result_1 = nil
                end
            end
            local ____value_3 = ____result_1
            if ____value_3 ~= nil then
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = ____value_3
            end
        end
        local targets = __K2L_ListWrap(____out_2, ____count_2):toSortedSet()
        for pc = 0, code.size - 1 do
            local insn = code[pc + 1]
            if targets:contains(pc) then
                self:yield("L" .. pc .. ":")
            end
            local text
            local ____mt_1 = getmetatable(insn)
            if ____mt_1 == Insn.Push then
                text = "push " .. insn.v
            elseif ____mt_1 == Insn.Load then
                text = "load r" .. insn.slot
            elseif ____mt_1 == Insn.Store then
                text = "store r" .. insn.slot
            elseif ____mt_1 == Insn.Jump then
                text = "jmp L" .. insn.target
            elseif ____mt_1 == Insn.JumpIfZero then
                text = "jz L" .. insn.target
            elseif ____mt_1 == Insn.Call then
                text = "call L" .. insn.target
            elseif ____mt_1 == Insn.Arith then
                text = "arith '" .. insn.op .. "'"
            elseif ____mt_1 == Insn.Cmp then
                text = "cmp " .. insn.op
            else
                text = __K2L_Str(insn):lower()
            end
            self:yield(string.format("  %03d  %s", pc, text))
        end
    end)
end

local Vm = __K2L_Class("Vm")

function Vm:____init(code, maxSteps)
    if maxSteps == nil then
        maxSteps = 100000
    end
    self.code = code
    self.maxSteps = maxSteps
    self.stack = __K2L_ListOfSize(64, 0, true)
    self.sp = 0
    self.regs = __K2L_ListOfSize(8, 0, true)
    self.calls = __K2L_ArrayDeque.new()
    self.output = __K2L_StringBuilder.new()
    self.steps = 0
end

function Vm:push(pc, v)
    if self.sp == self.stack.size then
        error(VmFault.new(pc, "stack overflow"))
    end
    local ____arg = self.stack
    local ____old = self.sp
    self.sp = self.sp + 1
    local ____key = ____old
    if ____key < 0 or ____key >= ____arg.size then
        __K2L_IndexError(____key, ____arg.size, "array")
    end
    ____arg[____key + 1] = v
end

function Vm:pop(pc)
    if self.sp == 0 then
        error(VmFault.new(pc, "stack underflow"))
    else
        local ____arg_1 = self.stack
        self.sp = self.sp - 1
        return ____arg_1[self.sp + 1] or __K2L_IndexError(self.sp, ____arg_1.size, "array")
    end
end

function Vm:slot(pc, s)
    if self.regs:getIndices():contains(s) then
        return s
    else
        error(VmFault.new(pc, "bad register r" .. s))
    end
end

function Vm:run()
    local pc = 0
    while true do
        if not self.code:getIndices():contains(pc) then
            error(VmFault.new(pc, "pc out of range"))
        end
        self.steps = self.steps + 1
        if self.steps > self.maxSteps then
            error(VmFault.new(pc, "step budget of " .. self.maxSteps .. " exhausted"))
        end
        local insn = self.code:get(pc)
        local ____next = pc + 1
        local ____mt_2 = getmetatable(insn)
        if ____mt_2 == Insn.Push then
            self:push(pc, insn.v)
        elseif ____mt_2 == Insn.Load then
            self:push(pc, self.regs:get(self:slot(pc, insn.slot)))
        elseif ____mt_2 == Insn.Store then
            local ____object = self.regs
            local ____key_1 = self:slot(pc, insn.slot)
            local ____value_6 = self:pop(pc)
            if ____key_1 < 0 or ____key_1 >= ____object.size then
                __K2L_IndexError(____key_1, ____object.size, "array")
            end
            ____object[____key_1 + 1] = ____value_6
        elseif ____mt_2 == Insn.Jump then
            ____next = insn.target
        elseif ____mt_2 == Insn.JumpIfZero then
            if self:pop(pc) == 0 then
                ____next = insn.target
            end
        elseif ____mt_2 == Insn.Call then
            if self.calls.size >= 32 then
                error(VmFault.new(pc, "call depth exceeded"))
            end
            self.calls:addLast(____next)
            ____next = insn.target
        elseif __K2L_Equals(insn, Insn.Ret) then
            local ____value_5 = self.calls:removeLastOrNull()
            if ____value_5 == nil then
                error(VmFault.new(pc, "return with empty call stack"))
            end
            ____next = ____value_5
        elseif ____mt_2 == Insn.Arith then
            local b = self:pop(pc)
            local a = self:pop(pc)
            self:push(pc, self:arith(pc, insn.op, a, b))
        elseif ____mt_2 == Insn.Cmp then
            local b = self:pop(pc)
            local a = self:pop(pc)
            local r
            local ____subject = insn.op
            if ____subject == "==" then
                r = a == b
            elseif ____subject == "!=" then
                r = a ~= b
            elseif ____subject == "<" then
                r = a < b
            elseif ____subject == "<=" then
                r = a <= b
            elseif ____subject == ">" then
                r = a > b
            else
                r = a >= b
            end
            self:push(pc, r and 1 or 0)
        elseif __K2L_Equals(insn, Insn.Dup) then
            local ____value_4 = self:pop(pc)
            self:push(pc, ____value_4)
            self:push(pc, ____value_4)
        elseif __K2L_Equals(insn, Insn.Swap) then
            local b = self:pop(pc)
            local a = self:pop(pc)
            self:push(pc, b)
            self:push(pc, a)
        elseif __K2L_Equals(insn, Insn.Pop) then
            self:pop(pc)
        elseif __K2L_Equals(insn, Insn.Print) then
            self.output:append(tostring(self:pop(pc))):append(" ")
        elseif __K2L_Equals(insn, Insn.Emit) then
            self.output:append(string.char(self:pop(pc)))
        elseif __K2L_Equals(insn, Insn.Halt) then
            return self.sp > 0 and (self.stack[self.sp] or __K2L_IndexError(self.sp - 1, self.stack.size, "array")) or 0
        end
        pc = ____next
    end
end

function Vm:arith(pc, op, a, b)
    if op == "+" then
        return a + b
    elseif op == "-" then
        return a - b
    elseif op == "*" then
        return a * b
    elseif op == "/" or op == "%" then
        if b == 0 then
            error(VmFault.new(pc, "division by zero"))
        else
            return op == "/" and a // b or a % b
        end
    elseif op == "&" then
        return a & b
    elseif op == "|" then
        return a | b
    elseif op == "^" then
        return a ~ b
    else
        return __K2L_Shl(a, b)
    end
end

local programs = __K2L_MapOf(__K2L_Pair.new("factorial", "\n        push 10\n        store 0        ; n\n        push 1\n        store 1        ; acc\n    loop:\n        load 0\n        jz done\n        load 1\n        load 0\n        mul\n        store 1\n        load 0\n        push 1\n        sub\n        store 0\n        jmp loop\n    done:\n        load 1\n        print\n        load 1\n        halt\n    "), __K2L_Pair.new("gcd_calls", "\n        push 1071\n        push 462\n        call gcd\n        print\n        push 'O'\n        emit\n        push 'K'\n        emit\n        halt\n    gcd:                 ; (a b -- gcd)\n        dup\n        jz gcd.end\n        swap\n        store 7\n        dup\n        load 7\n        swap\n        mod\n        jmp gcd\n    gcd.end:\n        pop\n        ret\n    "), __K2L_Pair.new("bits", "\n        push 1\n        push 31\n        shl\n        dup\n        print\n        push 0x7fffffff\n        add\n        print\n        push -7\n        push 2\n        div\n        print\n        push -7\n        push 2\n        mod\n        print\n        push 12\n        push 10\n        xor\n        push 3\n        lt\n        print\n        halt\n    "), __K2L_Pair.new("underflow", "push 1\nadd\nhalt"), __K2L_Pair.new("divzero", "push 4\npush 0\ndiv\nhalt"), __K2L_Pair.new("spin", "top:\njmp top"), __K2L_Pair.new("recurse", "f:\ncall f"), __K2L_Pair.new("badret", "ret"), __K2L_Pair.new("badreg", "push 1\nstore 9"), __K2L_Pair.new("falloff", "push 1"))

local ____lambda_1 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_2 = function(it) return __K2L_SimpleName(it) end
local ____lambda_3 = function(____a, ____b)
    local ____x_1, ____y_1 = ____b.value, ____a.value
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return __K2L_CompareValues(____a.key, ____b.key)
end
local function main()
    local ____map = programs
    local ____keys, ____values, ____n_3 = ____map:____arrays()
    for ____i_5 = 1, ____n_3 do
        local name, src = ____keys[____i_5], ____values[____i_5]
        local code = Assembler:assemble(__K2L_Text.trimIndent(src))
        if name == "gcd_calls" then
            for _, it in disassemble(code):iter() do
                (____lambda_1)(it)
            end
        end
        local vm = Vm.new(code, 500)
        local ____ok, ____result_2 = pcall(function()
            local top = vm:run()
            print(name .. ": out=[" .. __K2L_StringTrim(vm.output:toString()) .. "] top=" .. top .. " steps=" .. vm.steps)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_2)
            if getmetatable(____error) == VmFault then
                local f = ____error
                print(name .. ": " .. __K2L_Str(f.message) .. " (out=[" .. __K2L_Str(vm.output) .. "], steps=" .. vm.steps .. ")")
            else
                error(____error, 0)
            end
        end
    end
    local bad = __K2L_ListOf("push", "jmp nowhere", "a:\na:\nhalt", "frob 3", "push 12z", "push 'ab'")
    for ____i_6 = 1, bad.size do
        local src = bad[____i_6]
        local r = __K2L_RunCatching(function() return Assembler:assemble(src) end)
        local ____receiver = r:exceptionOrNull()
        print(____receiver and ____receiver.message or "assembled " .. __K2L_Str(r:getOrNull()))
    end
    local ____list_4 = programs:getValues()
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_4 = ____list_4:____array()
    for ____i_7 = 1, ____n_4 do
        local it = ____items_3[____i_7]
        local ____inner, ____m = Assembler:assemble(__K2L_Text.trimIndent(it)):____array()
        for ____j = 1, ____m do
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____inner[____j]
        end
    end
    local counts = __K2L_ListWrap(____out_3, ____count_3):groupingBy(____lambda_2):eachCount()
    print(__K2L_Str(counts:getEntries():sortedWith(____lambda_3):take(5)))
    print(__K2L_Equals(Insn.Halt, Assembler:assemble("halt"):single()) and Insn.Push.new(3):equals(Insn.Push.new(3)))
end

__K2L_RunMain(main)
return {Insn = Insn, AsmError = AsmError, VmFault = VmFault, Assembler = Assembler, disassemble = disassemble, Vm = Vm, programs = programs}
