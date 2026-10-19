local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
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
    return __K2L_EnumValues(Direction):firstOrNull(function(it)
        return __K2L_StringEqualsIgnoreCase(it.name, word) or #word == 1 and it.short == __K2L_StringCharAt(word, 0)
    end)
end

local Item = __K2L_Class("adventure.Item")

function Item:____init(name, weight)
    self.name = name
    self.weight = weight
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

function Monster:____init(name, hp, attack)
    self.name = name
    self.hp = hp
    self.attack = attack
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
        ____builder:append(" Exits: " .. self.exits:getKeys():sorted():joinToString(nil, nil, nil, nil, nil, function(it) return it.name:lower() end) .. ".")
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
    return self.inventory:sumOf(function(it) return it.weight end)
end

function Player:getBestWeapon()
    return self.inventory:filter(function(x) return __K2L_InstanceOf(x, Item.Weapon) end):maxByOrNull(function(it) return it.damage.last end)
end

local Command = __K2L_Class("adventure.Command")
Command.Go = __K2L_Class("adventure.Command$Go", nil, Command)

function Command.Go:____init(dir)
    self.dir = dir
end

function Command.Go:toString()
    return "Go(dir=" .. __K2L_Str(self.dir) .. ")"
end

function Command.Go:hashCode()
    return __K2L_Hash(self.dir)
end

function Command.Go:equals(other)
    return getmetatable(other) == Command.Go and self.dir == other.dir
end

Command.Take = __K2L_Class("adventure.Command$Take", nil, Command)

function Command.Take:____init(item)
    self.item = item
end

function Command.Take:toString()
    return "Take(item=" .. self.item .. ")"
end

function Command.Take:hashCode()
    return __K2L_Hash(self.item)
end

function Command.Take:equals(other)
    return getmetatable(other) == Command.Take and self.item == other.item
end

Command.Drop = __K2L_Class("adventure.Command$Drop", nil, Command)

function Command.Drop:____init(item)
    self.item = item
end

function Command.Drop:toString()
    return "Drop(item=" .. self.item .. ")"
end

function Command.Drop:hashCode()
    return __K2L_Hash(self.item)
end

function Command.Drop:equals(other)
    return getmetatable(other) == Command.Drop and self.item == other.item
end

Command.Use = __K2L_Class("adventure.Command$Use", nil, Command)

function Command.Use:____init(item)
    self.item = item
end

function Command.Use:toString()
    return "Use(item=" .. self.item .. ")"
end

function Command.Use:hashCode()
    return __K2L_Hash(self.item)
end

function Command.Use:equals(other)
    return getmetatable(other) == Command.Use and self.item == other.item
end

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

function Command.Unknown:____init(text)
    self.text = text
end

function Command.Unknown:toString()
    return "Unknown(text=" .. self.text .. ")"
end

function Command.Unknown:hashCode()
    return __K2L_Hash(self.text)
end

function Command.Unknown:equals(other)
    return getmetatable(other) == Command.Unknown and self.text == other.text
end

local function parseCommand(line)
    local words = __K2L_Regex.new("\\s+"):split(__K2L_StringTrim(line):lower()):filter(function(it)
        return #it > 0 and not __K2L_ReadOnlySetOf("the", "a", "an"):contains(it)
    end)
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
    vault.items:addAll(__K2L_ReadOnlyListOf(Item.Treasure.new("crown", 50), Item.Treasure.new("coins", 20)))
    self.rooms = __K2L_ReadOnlyListOf(hall, armory, cellar, vault):associateBy(function(it) return it.id end)
    self.player = Player.new(hall)
end

function Game:say(msg)
    self.out:add(msg)
end

function Game:run(script)
    self:say(self.player.room:toString())
    local ____mod = script.____modCount
    for ____i = 1, script.size do
        local line = script[____i]
        if self.over then
            break
        end
        self:say("> " .. line)
        self:step(parseCommand(line))
        if script.____modCount ~= ____mod and script:____comodified(____i) then
            break
        end
    end
    self:say("Final: hp=" .. self.player.hp .. " score=" .. self.player.score .. " moves=" .. self.player.moves .. " carried=" .. self.player:getCarried())
    return self.out
end

function Game:findItem(items, name)
    return items:firstOrNull(function(it) return it.name == name end)
end

function Game:step(cmd)
    local ____object_2 = self.player
    ____object_2.moves = ____object_2.moves + 1
    if __K2L_InstanceOf(cmd, Command.Go) then
        self:move(cmd.dir)
    elseif __K2L_InstanceOf(cmd, Command.Take) then
        local ____value_1 = self:findItem(self.player.room.items, cmd.item)
        if ____value_1 == nil then
            return self:say("There is no " .. cmd.item .. " here.")
        end
        local item = ____value_1
        if self.player:getCarried() + item.weight > self.player.maxWeight then
            return self:say("The " .. item.name .. " is too heavy.")
        end
        self.player.room.items:remove(item)
        self.player.inventory:add(item)
        if __K2L_InstanceOf(item, Item.Treasure) then
            local ____object_4 = self.player
            ____object_4.score = ____object_4.score + item.value
        end
        self:say("Taken: " .. __K2L_Str(item) .. ".")
    elseif __K2L_InstanceOf(cmd, Command.Drop) then
        local ____receiver_3 = self:findItem(self.player.inventory, cmd.item)
        local ____result
        if ____receiver_3 ~= nil then
            self.player.inventory:remove(____receiver_3)
            self.player.room.items:add(____receiver_3)
            if __K2L_InstanceOf(____receiver_3, Item.Treasure) then
                local ____object_3 = self.player
                ____object_3.score = ____object_3.score - ____receiver_3.value
            end
            self:say("Dropped " .. __K2L_Str(____receiver_3) .. ".")
            ____result = __K2L_Unit
        end
        local ____value = ____result
        if ____value == nil then
            self:say("You have no " .. cmd.item .. ".")
            ____value = __K2L_Unit
        end
    elseif __K2L_InstanceOf(cmd, Command.Use) then
        self:use(cmd.item)
    elseif __K2L_Equals(cmd, Command.Look) then
        self:say(self.player.room:toString())
    elseif __K2L_Equals(cmd, Command.Inventory) then
        self:say(self.player.inventory:isEmpty() and "You carry nothing." or "You carry: " .. self.player.inventory:joinToString())
    elseif __K2L_Equals(cmd, Command.Attack) then
        self:attack()
    elseif __K2L_InstanceOf(cmd, Command.Unknown) then
        self:say("I don't understand '" .. cmd.text .. "'.")
    end
end

function Game:move(dir)
    local ____value_2 = self.player.room.exits:get(dir)
    if ____value_2 == nil then
        return self:say("You can't go " .. dir.name:lower() .. ".")
    end
    local ____next = ____value_2
    local blocker = self.player.room.monster
    if blocker ~= nil and blocker:getAlive() and dir ~= Direction.NORTH then
        return self:say("The " .. blocker.name .. " won't let you pass.")
    end
    local ____receiver_4 = ____next.lockedBy
    if ____receiver_4 ~= nil then
        do
            local ____value_3 = self.player.inventory:filter(function(x) return __K2L_InstanceOf(x, Item.Key) end):find(function(it) return it.opens == ____receiver_4 end)
            if ____value_3 == nil then
                return self:say("The door to the " .. ____next.id .. " is locked.")
            end
            local key = ____value_3
            ____next.lockedBy = nil
            self:say("You unlock the door with the " .. key.name .. ".")
        end
    end
    local ____object_5 = self.player
    ____object_5.room = ____next
    self:say(____next:toString())
end

function Game:use(name)
    local item = self:findItem(self.player.inventory, name)
    if item == nil then
        self:say("You have no " .. name .. ".")
    elseif __K2L_InstanceOf(item, Item.Potion) then
        local before = self.player.hp
        local ____object_6 = self.player
        ____object_6.hp = math.min(20, self.player.hp + item.heal)
        self.player.inventory:remove(item)
        self:say("You feel better (" .. before .. " -> " .. self.player.hp .. ").")
    else
        self:say("Nothing happens with the " .. item.name .. ".")
    end
end

function Game:attack()
    local ____receiver_5 = self.player.room.monster
    local ____value_4 = ____receiver_5 and (____receiver_5:getAlive() and ____receiver_5 or nil)
    if ____value_4 == nil then
        return self:say("There is nothing to attack.")
    end
    local monster = ____value_4
    local weapon = self.player:getBestWeapon()
    local ____receiver_6 = weapon and weapon.damage
    local damage = ____receiver_6 and self.random:nextInt(____receiver_6.first, ____receiver_6.last + 1) or 1
    monster.hp = monster.hp - damage
    self:say("You hit the " .. monster.name .. " with " .. __K2L_Str(weapon or "your fists") .. " for " .. damage .. ".")
    if not monster:getAlive() then
        local ____object_7 = self.player
        ____object_7.score = ____object_7.score + 10
        return self:say("The " .. monster.name .. " dies!")
    end
    local bite = monster.attack:random(self.random)
    local ____object_8 = self.player
    ____object_8.hp = ____object_8.hp - bite
    self:say("The " .. monster.name .. " bites you for " .. bite .. " (hp " .. self.player.hp .. ").")
    if self.player.hp <= 0 then
        self.over = true
        self:say("You died.")
    end
end

function Game:roomCount()
    return self.rooms.size
end

local function main()
    local script = __K2L_ReadOnlyListOf("look", "take potion", "go east", "take sword", "take dagger", "i", "w", "s", "e", "attack", "attack", "attack", "attack", "attack", "drink potion", "attack", "take the key", "e", "take crown", "take coins", "drop dagger", "take coins", "dance", "go up", "n")
    local game = Game.new(42)
    local ____list = game:run(script)
    local ____mod_1 = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local it = ____list[____i_1];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
            break
        end
    end
    print("rooms=" .. game:roomCount() .. " alive=" .. tostring(game.player.hp > 0))
    local r1 = __K2L_Random.seeded(7)
    local r2 = __K2L_Random.seeded(7)
    print(__K2L_Equals(__K2L_ListOfSize(5, function(it) return r1:nextInt(100) end), __K2L_ListOfSize(5, function(it) return r2:nextInt(100) end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("n", "go west", "take", "hit", "   ", "walk e"):map(parseCommand)))
end

main()
return {Direction = Direction, Item = Item, Monster = Monster, Room = Room, Player = Player, Command = Command, parseCommand = parseCommand, Game = Game}
