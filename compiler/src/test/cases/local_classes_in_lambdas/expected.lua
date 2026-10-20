local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Greeter = __K2L_Class("Greeter")

local function main()
    local ____list = __K2L_ReadOnlyListOf(1, 2)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local n = ____items[____i]
        local ____result
        do
            local MyEx = __K2L_Class("MainKt$main$errors$1$MyEx", __K2L_Exception)
            function MyEx:____init(m)
                __K2L_Exception.____init(self, m)
            end
            ____result = MyEx.new("failure " .. n)
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    local errors = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = errors:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.message
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____value = errors:first()
    print(__K2L_InstanceOf(____value, __K2L_Exception))
    local ____list_1 = __K2L_ReadOnlyListOf("a", "b")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_1:____array()
    for ____i_2 = 1, ____n_2 do
        local s = ____items_2[____i_2]
        local ____result_1
        do
            local Oops = __K2L_Class("MainKt$main$outcomes$1$Oops", __K2L_RuntimeException)
            function Oops:____init(code)
                __K2L_RuntimeException.____init(self, "oops " .. s)
                self.code = code
            end
            local ____ok, ____result_2 = __K2L_DeepPcall(function()
                error(Oops.new(#s))
            end)
            if not ____ok then
                local ____error = __K2L_ToThrowable(____result_2)
                if getmetatable(____error) == Oops then
                    local e = ____error
                    ____result_1 = __K2L_Str(e.message) .. "/" .. e.code
                else
                    error(____error, 0)
                end
            end
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result_1
    end
    local outcomes = __K2L_ListWrap(____out_2, ____count_2)
    print(__K2L_Str(outcomes))
    local ____result_3
    do
        local English = __K2L_Class("MainKt$main$greeting$1$English", nil, Greeter)
        function English:____init(who)
            self.who = who
        end
        function English:greet()
            return "Hello, " .. self.who
        end
        ____result_3 = English.new("lambda"):greet()
    end
    local greeting = ____result_3
    print(greeting)
    local make = function(n)
        local Box = __K2L_Class("MainKt$main$make$1$Box")
        function Box:____init(v)
            self.v = v
        end
        return Box.new(n * 2)
    end
    local ____value_1 = make(2)
    print(____value_1 ~= nil)
end

__K2L_DeepMain(main)
return {Greeter = Greeter}
