local __K2L_Class = ____lualib.__K2L_Class
local __K2L_RunMain = ____lualib.__K2L_RunMain

Limits = __K2L_Class("app.Limits")

function Limits:____init()
    self.MAX = 20
    self.HALF = 10
    self.NEGATIVE_HALF = -3
    self.REMAINDER = -1
    self.WRAPPED = -2147483648
    self.SHIFTED = -2147483648
    self.BIG = 1099511627776
    self.LONG_WRAPPED = -9223372036854775807 - 1
    self.THIRD = 0.3333333333333333
    self.SUM = 0.30000000000000004
    self.WHOLE = 30.0
    self.FLOAT = 0.3
    self.NEXT = "c"
    self.LABEL = "max=20 third=0.3333333333333333 whole=30.0"
    self.FLAG = true
end

Limits:____init()
Box = __K2L_Class("app.Box")

function Box:____initCompanion()
    self.SIZE = 30
end

Box:____initCompanion()
AREA = 900

local function main()
    print(10)
    print(-3)
    print(-1)
    print(-2147483648)
    print(-2147483648)
    print(1099511627776)
    print(-9223372036854775807 - 1)
    print(0.3333333333333333)
    print(0.30000000000000004)
    print(30.0)
    print(0.3)
    print("c")
    print("max=20 third=0.3333333333333333 whole=30.0")
    print(true)
    print(30)
    print(AREA)
end

__K2L_RunMain(main)
