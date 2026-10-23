local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Unit = ____lualib.__K2L_Unit

local Direction = __K2L_Class("adventure.Direction")

function Direction:____init(name, ordinal, short)
    self.name = name
    self.ordinal = ordinal
    self.short = short
end

function Direction:getOpposite()
    if self == Direction.NORTH then
        return Direction.SOUTH
    elseif self == Direction.SOUTH then
        return Direction.NORTH
    elseif self == Direction.EAST then
        return Direction.WEST
    elseif self == Direction.WEST then
        return Direction.EAST
    end
end

function Direction:toString()
    return self.name
end

function Direction:compareTo(other)
    return self.ordinal - other.ordinal
end

Direction.NORTH = Direction.new("NORTH", 0, "n")
Direction.SOUTH = Direction.new("SOUTH", 1, "s")
Direction.EAST = Direction.new("EAST", 2, "e")
Direction.WEST = Direction.new("WEST", 3, "w")
Direction.____values = {Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST}
Direction.____companion = true

function Direction:parse(word)
    local ____values = Direction.____values
    local ____result
    for ____i = 1, #____values do
        local it = ____values[____i]
        if __K2L_StringEqualsIgnoreCase(it.name, word) or #word == 1 and it.short == (0 >= 0 and 0 < #word and word:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #word, "string")) then
            ____result = it
            break
        end
    end
    return ____result
end

local Item = __K2L_Class("adventure.Item")

function Item:____init(name, weight)
    self.name = name
    self.weight = weight
end

function Item.new(name, weight)
    return setmetatable({name = name, weight = weight}, Item)
end

Item.Key = __K2L_Class("adventure.Item$Key", Item)

function Item.Key:____init(opens)
    Item.____init(self, "key", 1)
    self.opens = opens
end

Item.Weapon = __K2L_Class("adventure.Item$Weapon", Item)

function Item.Weapon:____init(name, damage)
    Item.____init(self, name, 3)
    self.damage = damage
end

Item.Potion = __K2L_Class("adventure.Item$Potion", Item)

function Item.Potion:____init(heal)
    Item.____init(self, "potion", 1)
    self.heal = heal
end

Item.Treasure = __K2L_Class("adventure.Item$Treasure", Item)

function Item.Treasure:____init(name, value)
    Item.____init(self, name, 2)
    self.value = value
end

function Item:toString()
    return self.name
end

local Monster = __K2L_Class("adventure.Monster")

function Monster.new(name, hp, attack)
    return setmetatable({name = name, hp = hp, attack = attack}, Monster)
end

function Monster:getAlive()
    return self.hp > 0
end

local Room = __K2L_Class("adventure.Room")

function Room:____init(id, description)
    self.id = id
    self.description = description
    self.exits = __K2L_MapOf()
    self.items = __K2L_ListOf()
    self.monster = nil
    self.lockedBy = nil
end

function Room:connect(dir, other)
    local ____object = self.exits
    ____object:set(dir, other)
    local ____object_1 = other.exits
    local ____key = dir:getOpposite()
    ____object_1:set(____key, self)
end

local ____lambda_1 = function(it) return it.name:lower() end
function Room:toString()
    local ____builder = __K2L_StringBuilder.new()
    do
        ____builder:append("[" .. self.id .. "] " .. self.description)
        if self.items:isNotEmpty() then
            ____builder:append(" Items: " .. self.items:joinToString() .. ".")
        end
        local ____receiver = self.monster
        local ____receiver_1 = ____receiver and (____receiver:getAlive() and ____receiver or nil)
        if ____receiver_1 ~= nil then
            ____builder:append(" A " .. ____receiver_1.name .. " blocks the way (hp " .. ____receiver_1.hp .. ").")
        end
        ____builder:append(" Exits: " .. self.exits:getKeys():sorted():joinToString(nil, nil, nil, nil, nil, ____lambda_1) .. ".")
    end
    return ____builder:toString()
end

local Player = __K2L_Class("adventure.Player")

function Player:____init(room)
    self.room = room
    self.hp = 20
    self.inventory = __K2L_ListOf()
    self.maxWeight = 6
    self.score = 0
    self.moves = 0
end

function Player:getCarried()
    local ____list = self.inventory
    local ____sum = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____sum = ____sum + it.weight
    end
    return ____sum
end

local ____lambda_2 = function(x) return getmetatable(x) == Item.Weapon end
local ____lambda_3 = function(it) return it.damage.last end
function Player:getBestWeapon()
    return self.inventory:filter(____lambda_2):maxByOrNull(____lambda_3)
end

local Command = __K2L_Class("adventure.Command")
Command.Go = __K2L_Class("adventure.Command$Go", nil, Command)

function Command.Go.new(dir)
    return setmetatable({dir = dir}, Command.Go)
end

__K2L_DataClass(Command.Go, {"dir"})
Command.Take = __K2L_Class("adventure.Command$Take", nil, Command)

function Command.Take.new(item)
    return setmetatable({item = item}, Command.Take)
end

__K2L_DataClass(Command.Take, {"item"})
Command.Drop = __K2L_Class("adventure.Command$Drop", nil, Command)

function Command.Drop.new(item)
    return setmetatable({item = item}, Command.Drop)
end

__K2L_DataClass(Command.Drop, {"item"})
Command.Use = __K2L_Class("adventure.Command$Use", nil, Command)

function Command.Use.new(item)
    return setmetatable({item = item}, Command.Use)
end

__K2L_DataClass(Command.Use, {"item"})
Command.Look = __K2L_Class("adventure.Command$Look", nil, Command)

function Command.Look:toString()
    return "Look"
end

function Command.Look:hashCode()
    return 1609625024
end

Command.Inventory = __K2L_Class("adventure.Command$Inventory", nil, Command)

function Command.Inventory:toString()
    return "Inventory"
end

function Command.Inventory:hashCode()
    return 333594331
end

Command.Attack = __K2L_Class("adventure.Command$Attack", nil, Command)

function Command.Attack:toString()
    return "Attack"
end

function Command.Attack:hashCode()
    return 351260969
end

Command.Unknown = __K2L_Class("adventure.Command$Unknown", nil, Command)

function Command.Unknown.new(text)
    return setmetatable({text = text}, Command.Unknown)
end

__K2L_DataClass(Command.Unknown, {"text"})

local function parseCommand(line)
    local ____list_1 = __K2L_Regex.new("\\s+", "%s+"):split(__K2L_StringTrim(line):lower())
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        if #it > 0 and not __K2L_SetOf("the", "a", "an"):contains(it) then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local words = __K2L_ListWrap(____out, ____count)
    if words:isEmpty() then
        return Command.Unknown.new(line)
    end
    local ____destructured = __K2L_Pair.new(words:first(), words:drop(1):joinToString(" "))
    local verb, rest = ____destructured.first, ____destructured.second
    if verb == "go" or verb == "walk" then
        local ____receiver_2 = Direction:parse(rest)
        return ____receiver_2 and Command.Go.new(____receiver_2) or Command.Unknown.new(line)
    elseif verb == "n" or verb == "s" or verb == "e" or verb == "w" or verb == "north" or verb == "south" or verb == "east" or verb == "west" then
        return Command.Go.new(__K2L_NotNull(Direction:parse(verb)))
    elseif verb == "take" or verb == "get" then
        return Command.Take.new(rest)
    elseif verb == "drop" then
        return Command.Drop.new(rest)
    elseif verb == "use" or verb == "drink" then
        return Command.Use.new(rest)
    elseif verb == "look" or verb == "l" then
        return Command.Look
    elseif verb == "inventory" or verb == "i" then
        return Command.Inventory
    elseif verb == "attack" or verb == "fight" or verb == "hit" then
        return Command.Attack
    else
        return Command.Unknown.new(line)
    end
end

local Game = __K2L_Class("adventure.Game")
local move, use, attack__1

local function say(self, msg)
    self.out:add(msg)
end

local function findItem(self, items, name)
    local ____result_1
    local ____items_2, ____n_2 = items:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        if it.name == name then
            ____result_1 = it
            break
        end
    end
    return ____result_1
end

local function step(self, cmd)
    local ____object_2 = self.player
    ____object_2.moves = ____object_2.moves + 1
    local ____mt = getmetatable(cmd)
    if ____mt == Command.Go then
        move(self, cmd.dir)
    elseif ____mt == Command.Take then
        local ____value_1 = findItem(self, self.player.room.items, cmd.item)
        if ____value_1 == nil then
            return say(self, "There is no " .. cmd.item .. " here.")
        end
        local item = ____value_1
        if self.player:getCarried() + item.weight > self.player.maxWeight then
            return say(self, "The " .. item.name .. " is too heavy.")
        end
        self.player.room.items:remove(item)
        self.player.inventory:add(item)
        if getmetatable(item) == Item.Treasure then
            local ____object_4 = self.player
            ____object_4.score = ____object_4.score + item.value
        end
        say(self, "Taken: " .. __K2L_Str(item) .. ".")
    elseif ____mt == Command.Drop then
        local ____receiver_3 = findItem(self, self.player.inventory, cmd.item)
        local ____result_2
        if ____receiver_3 ~= nil then
            self.player.inventory:remove(____receiver_3)
            self.player.room.items:add(____receiver_3)
            if getmetatable(____receiver_3) == Item.Treasure then
                local ____object_3 = self.player
                ____object_3.score = ____object_3.score - ____receiver_3.value
            end
            say(self, "Dropped " .. __K2L_Str(____receiver_3) .. ".")
            ____result_2 = __K2L_Unit
        end
        local ____value = ____result_2
        if ____value == nil then
            say(self, "You have no " .. cmd.item .. ".")
            ____value = __K2L_Unit
        end
    elseif ____mt == Command.Use then
        use(self, cmd.item)
    elseif __K2L_Equals(cmd, Command.Look) then
        say(self, self.player.room:toString())
    elseif __K2L_Equals(cmd, Command.Inventory) then
        say(self, self.player.inventory:isEmpty() and "You carry nothing." or "You carry: " .. self.player.inventory:joinToString())
    elseif __K2L_Equals(cmd, Command.Attack) then
        attack__1(self)
    elseif ____mt == Command.Unknown then
        say(self, "I don't understand '" .. cmd.text .. "'.")
    end
end

local ____lambda_4 = function(x) return getmetatable(x) == Item.Key end
function move(self, dir)
    local ____value_2 = self.player.room.exits:get(dir)
    if ____value_2 == nil then
        return say(self, "You can't go " .. dir.name:lower() .. ".")
    end
    local ____next = ____value_2
    local blocker = self.player.room.monster
    if blocker ~= nil and blocker:getAlive() and dir ~= Direction.NORTH then
        return say(self, "The " .. blocker.name .. " won't let you pass.")
    end
    local ____receiver_4 = ____next.lockedBy
    if ____receiver_4 ~= nil then
        do
            local ____list_2 = self.player.inventory:filter(____lambda_4)
            local ____result_3
            local ____items_3, ____n_3 = ____list_2:____array()
            for ____i_4 = 1, ____n_3 do
                local it = ____items_3[____i_4]
                if it.opens == ____receiver_4 then
                    ____result_3 = it
                    break
                end
            end
            if ____result_3 == nil then
                return say(self, "The door to the " .. ____next.id .. " is locked.")
            end
            local key = ____result_3
            ____next.lockedBy = nil
            say(self, "You unlock the door with the " .. key.name .. ".")
        end
    end
    local ____object_5 = self.player
    ____object_5.room = ____next
    say(self, ____next:toString())
end

function use(self, name)
    local item = findItem(self, self.player.inventory, name)
    if item == nil then
        say(self, "You have no " .. name .. ".")
    elseif getmetatable(item) == Item.Potion then
        local before = self.player.hp
        local ____object_6 = self.player
        ____object_6.hp = math.min(20, self.player.hp + item.heal)
        self.player.inventory:remove(item)
        say(self, "You feel better (" .. before .. " -> " .. self.player.hp .. ").")
    else
        say(self, "Nothing happens with the " .. item.name .. ".")
    end
end

function attack__1(self)
    local ____receiver_5 = self.player.room.monster
    local ____value_3 = ____receiver_5 and (____receiver_5:getAlive() and ____receiver_5 or nil)
    if ____value_3 == nil then
        return say(self, "There is nothing to attack.")
    end
    local monster = ____value_3
    local weapon = self.player:getBestWeapon()
    local ____receiver_6 = weapon and weapon.damage
    local damage = ____receiver_6 and self.random:nextInt(____receiver_6.first, ____receiver_6.last + 1) or 1
    monster.hp = monster.hp - damage
    say(self, "You hit the " .. monster.name .. " with " .. __K2L_Str(weapon or "your fists") .. " for " .. damage .. ".")
    if not monster:getAlive() then
        local ____object_7 = self.player
        ____object_7.score = ____object_7.score + 10
        return say(self, "The " .. monster.name .. " dies!")
    end
    local bite = self.random:nextIntRange(monster.attack, false)
    local ____object_8 = self.player
    ____object_8.hp = ____object_8.hp - bite
    say(self, "The " .. monster.name .. " bites you for " .. bite .. " (hp " .. self.player.hp .. ").")
    if self.player.hp <= 0 then
        self.over = true
        say(self, "You died.")
    end
end

function Game:____init(seed)
    self.random = __K2L_Random.seeded(seed)
    self.out = __K2L_ListOf()
    self.over = false
    local hall = Room.new("hall", "A dusty hall.")
    local armory = Room.new("armory", "Racks of old weapons.")
    local cellar = Room.new("cellar", "Damp and dark.")
    local vault = Room.new("vault", "Gold glitters everywhere.")
    hall:connect(Direction.EAST, armory)
    hall:connect(Direction.SOUTH, cellar)
    cellar:connect(Direction.EAST, vault)
    armory.items:add(Item.Weapon.new("sword", __K2L_IntRange.new(3, 6)))
    armory.items:add(Item.Weapon.new("dagger", __K2L_IntRange.new(1, 3)))
    hall.items:add(Item.Potion.new(8))
    cellar.items:add(Item.Key.new("vault"))
    cellar.monster = Monster.new("rat king", 12, __K2L_IntRange.new(1, 4))
    vault.lockedBy = "vault"
    vault.items:addAll(__K2L_ListOf(Item.Treasure.new("crown", 50), Item.Treasure.new("coins", 20)))
    local ____list_3 = __K2L_ListOf(hall, armory, cellar, vault)
    local ____result_4 = __K2L_Map.new()
    local ____items_4, ____n_4 = ____list_3:____array()
    for ____i_5 = 1, ____n_4 do
        local it = ____items_4[____i_5]
        local ____value_4 = it.id
        ____result_4:put(____value_4, it)
    end
    self.rooms = ____result_4
    self.player = Player.new(hall)
end

function Game:run(script)
    say(self, self.player.room:toString())
    for ____i_6 = 1, script.size do
        local line = script[____i_6]
        if self.over then
            break
        end
        say(self, "> " .. line)
        step(self, parseCommand(line))
    end
    say(self, "Final: hp=" .. self.player.hp .. " score=" .. self.player.score .. " moves=" .. self.player.moves .. " carried=" .. self.player:getCarried())
    return self.out
end

function Game:roomCount()
    return self.rooms.size
end

local ____lambda_5 = function(____p1) return print(__K2L_Str(____p1)) end
local function main()
    local script = __K2L_ListOf("look", "take potion", "go east", "take sword", "take dagger", "i", "w", "s", "e", "attack", "attack", "attack", "attack", "attack", "drink potion", "attack", "take the key", "e", "take crown", "take coins", "drop dagger", "take coins", "dance", "go up", "n")
    local game = Game.new(42)
    local ____list_4 = game:run(script)
    for ____i_7 = 1, ____list_4.size do
        local it = ____list_4[____i_7];
        (____lambda_5)(it)
    end
    print("rooms=" .. game:roomCount() .. " alive=" .. tostring(game.player.hp > 0))
    local r1 = __K2L_Random.seeded(7)
    local r2 = __K2L_Random.seeded(7)
    local ____out_1 = {}
    for ____i_8 = 1, 5 do
        local it = ____i_8 - 1
        ____out_1[____i_8] = r1:nextInt(100)
    end
    local ____arg = __K2L_ListWrap(____out_1, 5)
    local ____out_2 = {}
    for ____i_9 = 1, 5 do
        local it = ____i_9 - 1
        ____out_2[____i_9] = r2:nextInt(100)
    end
    print(__K2L_Equals(____arg, __K2L_ListWrap(____out_2, 5)))
    print(__K2L_Str(__K2L_ListOf("n", "go west", "take", "hit", "   ", "walk e"):map(parseCommand)))
end

__K2L_RunMain(main)
return {Direction = Direction, Item = Item, Monster = Monster, Room = Room, Player = Player, Command = Command, parseCommand = parseCommand, Game = Game}
