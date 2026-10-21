local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text

local Element = __K2L_Class("Element")

function Element:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Element:toString()
    return self.name
end

function Element:compareTo(other)
    return self.ordinal - other.ordinal
end

Element.FIRE = Element.new("FIRE", 0)
Element.ICE = Element.new("ICE", 1)
Element.POISON = Element.new("POISON", 2)
Element.NONE = Element.new("NONE", 3)
Element.____values = {Element.FIRE, Element.ICE, Element.POISON, Element.NONE}
local Item = __K2L_Class("Item")

function Item:____init(name, attack, defense, heal, element)
    if attack == nil then
        attack = 0
    end
    if defense == nil then
        defense = 0
    end
    if heal == nil then
        heal = 0
    end
    if element == nil then
        element = Element.NONE
    end
    self.name = name
    self.attack = attack
    self.defense = defense
    self.heal = heal
    self.element = element
end

function Item:toString()
    return "Item(name=" .. self.name .. ", attack=" .. self.attack .. ", defense=" .. self.defense .. ", heal=" .. self.heal .. ", element=" .. __K2L_Str(self.element) .. ")"
end

function Item:hashCode()
    return (31 * (31 * (31 * (31 * __K2L_Hash(self.name) + self.attack) + self.defense) + self.heal) + __K2L_Hash(self.element) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.attack == other.attack and self.defense == other.defense and self.heal == other.heal and self.element == other.element
end

local Effect = __K2L_Class("Effect")
Effect.Burn = __K2L_Class("Effect$Burn", nil, Effect)

function Effect.Burn:____init(turns, damage)
    self.turns = turns
    self.damage = damage
end

function Effect.Burn.new(turns, damage)
    return setmetatable({turns = turns, damage = damage}, Effect.Burn)
end

function Effect.Burn:toString()
    return "Burn(turns=" .. self.turns .. ", damage=" .. self.damage .. ")"
end

function Effect.Burn:hashCode()
    return (31 * self.turns + self.damage + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Effect.Burn:equals(other)
    return getmetatable(other) == Effect.Burn and self.turns == other.turns and self.damage == other.damage
end

Effect.Freeze = __K2L_Class("Effect$Freeze", nil, Effect)

function Effect.Freeze:____init(turns)
    self.turns = turns
end

function Effect.Freeze.new(turns)
    return setmetatable({turns = turns}, Effect.Freeze)
end

function Effect.Freeze:toString()
    return "Freeze(turns=" .. self.turns .. ")"
end

function Effect.Freeze:hashCode()
    return self.turns
end

function Effect.Freeze:equals(other)
    return getmetatable(other) == Effect.Freeze and self.turns == other.turns
end

Effect.Poison = __K2L_Class("Effect$Poison", nil, Effect)

function Effect.Poison:____init(turns, percent)
    self.turns = turns
    self.percent = percent
end

function Effect.Poison.new(turns, percent)
    return setmetatable({turns = turns, percent = percent}, Effect.Poison)
end

function Effect.Poison:toString()
    return "Poison(turns=" .. self.turns .. ", percent=" .. self.percent .. ")"
end

function Effect.Poison:hashCode()
    return (31 * self.turns + self.percent + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Effect.Poison:equals(other)
    return getmetatable(other) == Effect.Poison and self.turns == other.turns and self.percent == other.percent
end

local Fighter = __K2L_Class("Fighter")

function Fighter:____init(name, maxHp, baseAttack, baseDefense, agility)
    self.name = name
    self.maxHp = maxHp
    self.baseAttack = baseAttack
    self.baseDefense = baseDefense
    self.agility = agility
    self.hp = self.maxHp
    self.inventory = __K2L_ListOf()
    self.effects = __K2L_ListOf()
    self.weapon = nil
    self.armor = nil
    self.kills = 0
end

function Fighter:getAlive()
    return self.hp > 0
end

function Fighter:getAttack()
    local ____arg = self.baseAttack
    local ____receiver = self.weapon
    return ____arg + (____receiver and ____receiver.attack or 0)
end

function Fighter:getDefense()
    local ____arg_1 = self.baseDefense
    local ____receiver_1 = self.armor
    return ____arg_1 + (____receiver_1 and ____receiver_1.defense or 0)
end

local ____lambda_1 = function(it) return it.attack end
local ____lambda_2 = function(it) return it.defense end
function Fighter:equipBest()
    local ____list = self.inventory
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it.attack > 0 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    self.weapon = __K2L_ListWrap(____out, ____count):maxByOrNull(____lambda_1) or self.weapon
    local ____list_1 = self.inventory
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it.defense > 0 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    self.armor = __K2L_ListWrap(____out_1, ____count_1):maxByOrNull(____lambda_2) or self.armor
end

function Fighter:toString()
    return self.name .. "(" .. math.max(self.hp, 0) .. "/" .. self.maxHp .. ")"
end

local LootTable = __K2L_Class("LootTable")

function LootTable:____init(entries)
    self.entries = entries
    local ____list_2 = self.entries
    local ____sum = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____sum = ____sum + it.second
    end
    self.total = ____sum
end

function LootTable:roll(rng)
    local pick = rng:nextInt(self.total)
    local ____list_3 = self.entries
    local ____mod = ____list_3.____modCount
    for ____i_3 = 1, ____list_3.size do
        local ____item = ____list_3[____i_3]
        local item, weight = ____item.first, ____item.second
        if pick < weight then
            return item
        end
        pick = pick - weight
        if ____list_3.____modCount ~= ____mod and ____list_3:____comodified(____i_3) then
            break
        end
    end
    error(__K2L_IllegalStateException.new("unreachable"))
end

local loot = LootTable.new(__K2L_ReadOnlyListOf(__K2L_Pair.new(Item.new("potion", nil, nil, 25), 40), __K2L_Pair.new(Item.new("dagger", 3), 20), __K2L_Pair.new(Item.new("flame sword", 7, nil, nil, Element.FIRE), 8), __K2L_Pair.new(Item.new("frost axe", 6, nil, nil, Element.ICE), 8), __K2L_Pair.new(Item.new("venom blade", 5, nil, nil, Element.POISON), 8), __K2L_Pair.new(Item.new("leather", nil, 2), 20), __K2L_Pair.new(Item.new("plate", nil, 6), 6)))
local Battle = __K2L_Class("Battle")

function Battle:____init(rng, log)
    self.rng = rng
    self.log = log
    self.rounds = 0
end

function Battle:say(s)
    if self.log then
        print(s)
    end
end

function Battle:tickEffects(f)
    local frozen = false
    local remaining = __K2L_ListOf()
    local ____list_4 = f.effects
    local ____mod_1 = ____list_4.____modCount
    for ____i_4 = 1, ____list_4.size do
        local e = ____list_4[____i_4]
        local ____mt = getmetatable(e)
        if ____mt == Effect.Burn then
            local ____value_1 = e.damage
            self:say("  " .. f.name .. " burns for " .. ____value_1)
            f.hp = f.hp - ____value_1
        elseif ____mt == Effect.Poison then
            local ____dividend = f.maxHp * e.percent
            local ____value = math.max(1, ____dividend >= 0 and ____dividend // 100 or 0 - -____dividend // 100)
            self:say("  " .. f.name .. " takes " .. ____value .. " poison")
            f.hp = f.hp - ____value
        elseif ____mt == Effect.Freeze then
            self:say("  " .. f.name .. " is frozen")
            frozen = true
        end
        if e.turns > 1 then
            local ____temp
            local ____mt_1 = getmetatable(e)
            if ____mt_1 == Effect.Burn then
                ____temp = Effect.Burn.new(e.turns - 1, e.damage)
            elseif ____mt_1 == Effect.Freeze then
                ____temp = Effect.Freeze.new(e.turns - 1)
            elseif ____mt_1 == Effect.Poison then
                ____temp = Effect.Poison.new(e.turns - 1, e.percent)
            end
            remaining:add(____temp)
        end
        if ____list_4.____modCount ~= ____mod_1 and ____list_4:____comodified(____i_4) then
            break
        end
    end
    f.effects:clear()
    f.effects:addAll(remaining)
    return frozen
end

function Battle:strike(a, d)
    if self.rng:nextInt(100) < d.agility then
        self:say("  " .. d.name .. " dodges " .. a.name)
        return
    end
    local variance = self.rng:nextDouble(0.85, 1.15)
    local crit = self.rng:nextDouble() < 0.1
    local damage = __K2L_Num.roundToInt((a:getAttack() * a:getAttack() + 0.0) / (a:getAttack() + d:getDefense()) * variance)
    if crit then
        damage = __K2L_Num.roundToInt(damage * 1.75)
    end
    damage = math.max(1, damage)
    d.hp = d.hp - damage
    self:say("  " .. a.name .. " hits " .. d.name .. " for " .. damage .. (crit and " (critical)" or ""))
    local ____receiver_2 = a.weapon
    local ____subject = ____receiver_2 and ____receiver_2.element
    if ____subject == Element.FIRE then
        if self.rng:nextBoolean() then
            d.effects:add(Effect.Burn.new(2, 3))
        end
    elseif ____subject == Element.ICE then
        if self.rng:nextInt(4) == 0 then
            d.effects:add(Effect.Freeze.new(1))
        end
    elseif ____subject == Element.POISON then
        local ____list_5 = d.effects
        local ____result = true
        local ____items_3, ____n_3 = ____list_5:____array()
        for ____i_5 = 1, ____n_3 do
            local it = ____items_3[____i_5]
            if getmetatable(it) == Effect.Poison then
                ____result = false
                break
            end
        end
        if ____result then
            d.effects:add(Effect.Poison.new(3, 5))
        end
    end
    if not d:getAlive() then
        a.kills = a.kills + 1
        self:say("  " .. d.name .. " falls")
    end
end

local ____lambda_3 = function(it) return it.agility end
function Battle:fight(heroes, ____monsters)
    while true do
        local ____result_1 = false
        local ____items_4, ____n_4 = heroes:____array()
        for ____i_6 = 1, ____n_4 do
            local it = ____items_4[____i_6]
            if it:getAlive() then
                ____result_1 = true
                break
            end
        end
        local ____cond = ____result_1
        if ____cond then
            local ____result_2 = false
            local ____items_5, ____n_5 = ____monsters:____array()
            for ____i_7 = 1, ____n_5 do
                local it = ____items_5[____i_7]
                if it:getAlive() then
                    ____result_2 = true
                    break
                end
            end
            ____cond = ____result_2
        end
        if not (____cond and self.rounds < 50) then
            break
        end
        self.rounds = self.rounds + 1
        self:say("round " .. self.rounds)
        local ____list_6 = heroes:plusAll(____monsters)
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_6, ____n_6 = ____list_6:____array()
        for ____i_8 = 1, ____n_6 do
            local it = ____items_6[____i_8]
            if it:getAlive() then
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = it
            end
        end
        local order = __K2L_ListWrap(____out_2, ____count_2):shuffled(self.rng):sortedByDescending(____lambda_3, true)
        local ____mod_2 = order.____modCount
        for ____i_11 = 1, order.size do
            local f = order[____i_11]
            do
                if not f:getAlive() then
                    goto ____continue
                end
                if self:tickEffects(f) or not f:getAlive() then
                    goto ____continue
                end
                local ____list_7 = heroes:contains(f) and ____monsters or heroes
                local ____out_3 = {}
                local ____count_3 = 0
                local ____items_7, ____n_7 = ____list_7:____array()
                for ____i_9 = 1, ____n_7 do
                    local it = ____items_7[____i_9]
                    if it:getAlive() then
                        ____count_3 = ____count_3 + 1
                        ____out_3[____count_3] = it
                    end
                end
                local foes = __K2L_ListWrap(____out_3, ____count_3)
                if foes:isEmpty() then
                    break
                end
                local ____list_8 = f.inventory
                local ____result_3
                local ____items_8, ____n_8 = ____list_8:____array()
                for ____i_10 = 1, ____n_8 do
                    local it = ____items_8[____i_10]
                    if it.heal > 0 then
                        ____result_3 = it
                        break
                    end
                end
                local potion = ____result_3
                if potion ~= nil and f.hp < (f.maxHp >= 0 and f.maxHp // 3 or 0 - -f.maxHp // 3) then
                    f.inventory:remove(potion)
                    f.hp = math.min(f.maxHp, f.hp + potion.heal)
                    self:say("  " .. f.name .. " drinks a " .. potion.name)
                    goto ____continue
                end
                self:strike(f, foes:random(self.rng))
            end
            ::____continue::
            if order.____modCount ~= ____mod_2 and order:____comodified(____i_11) then
                break
            end
        end
    end
    local ____result_4 = false
    local ____items_9, ____n_9 = heroes:____array()
    for ____i_12 = 1, ____n_9 do
        local it = ____items_9[____i_12]
        if it:getAlive() then
            ____result_4 = true
            break
        end
    end
    return ____result_4
end

local function party()
    return __K2L_ReadOnlyListOf(Fighter.new("Knight", 60, 9, 5, 10), Fighter.new("Rogue", 40, 8, 2, 35), Fighter.new("Mage", 35, 11, 1, 15))
end

local function monsters(rng, depth)
    local ____size = rng:nextInt(2, 4)
    local ____out_4 = {}
    for ____i_13 = 1, ____size do
        local i = ____i_13 - 1
        local ____result_5
        do
            local hp = 20 + depth * 6 + rng:nextInt(10)
            ____result_5 = Fighter.new("Goblin" .. depth .. "_" .. i, hp, 6 + depth, 1 + (depth >= 0 and depth // 2 or 0 - -depth // 2), rng:nextInt(5, 20))
        end
        ____out_4[____i_13] = ____result_5
    end
    return __K2L_ListWrap(____out_4, ____size)
end

local function crawl(seed, log)
    local rng = __K2L_Random.seeded(seed)
    local heroes = party()
    local ____mod_3 = heroes.____modCount
    for ____i_14 = 1, heroes.size do
        local h = heroes[____i_14]
        for it = 0, 1 do
            h.inventory:add(loot:roll(rng))
        end
        if heroes.____modCount ~= ____mod_3 and heroes:____comodified(____i_14) then
            break
        end
    end
    local ____mod_4 = heroes.____modCount
    for ____i_15 = 1, heroes.size do
        local it = heroes[____i_15]
        it:equipBest()
        if heroes.____modCount ~= ____mod_4 and heroes:____comodified(____i_15) then
            break
        end
    end
    local depth = 0
    local totalRounds = 0
    while depth < 10 do
        depth = depth + 1
        local battle = Battle.new(rng, log)
        if log then
            local ____arg_2 = depth
            local ____out_5 = {}
            local ____count_4 = 0
            local ____items_10, ____n_10 = heroes:____array()
            for ____i_16 = 1, ____n_10 do
                local it = ____items_10[____i_16]
                if it:getAlive() then
                    ____count_4 = ____count_4 + 1
                    ____out_5[____count_4] = it
                end
            end
            print("== depth " .. ____arg_2 .. ": " .. __K2L_Str(__K2L_ListWrap(____out_5, ____count_4)))
        end
        local won = battle:fight(heroes, monsters(rng, depth))
        totalRounds = totalRounds + battle.rounds
        if not won then
            break
        end
        local ____out_6 = {}
        local ____count_5 = 0
        local ____items_11, ____n_11 = heroes:____array()
        for ____i_17 = 1, ____n_11 do
            local it = ____items_11[____i_17]
            if it:getAlive() then
                ____count_5 = ____count_5 + 1
                ____out_6[____count_5] = it
            end
        end
        local ____list_9 = __K2L_ListWrap(____out_6, ____count_5)
        local ____mod_5 = ____list_9.____modCount
        for ____i_18 = 1, ____list_9.size do
            local h = ____list_9[____i_18]
            if rng:nextInt(3) == 0 then
                h.inventory:add(loot:roll(rng))
            end
            h:equipBest()
            h.hp = math.min(h.maxHp, h.hp + (h.maxHp >= 0 and h.maxHp // 10 or 0 - -h.maxHp // 10))
            if ____list_9.____modCount ~= ____mod_5 and ____list_9:____comodified(____i_18) then
                break
            end
        end
    end
    local ____out_7 = {}
    local ____count_6 = 0
    local ____items_12, ____n_12 = heroes:____array()
    for ____i_19 = 1, ____n_12 do
        local it = ____items_12[____i_19]
        if it:getAlive() then
            ____count_6 = ____count_6 + 1
            ____out_7[____count_6] = it
        end
    end
    local survivors = __K2L_ListWrap(____out_7, ____count_6)
    local gear = heroes:joinToString(" ", nil, nil, nil, nil, function(it)
        local ____receiver_3 = it.weapon
        local ____receiver_4 = it.armor
        return it.name .. ":" .. (____receiver_3 and ____receiver_3.name or "-") .. "/" .. (____receiver_4 and ____receiver_4.name or "-") .. "/" .. it.inventory.size
    end)
    local ____arg_3 = depth
    local ____arg_4 = totalRounds
    local ____arg_5 = __K2L_Str(survivors)
    local ____out_8 = {}
    local ____count_7 = 0
    local ____items_13, ____n_13 = heroes:____array()
    for ____i_20 = 1, ____n_13 do
        local it = ____items_13[____i_20]
        ____count_7 = ____count_7 + 1
        ____out_8[____count_7] = it.kills
    end
    return "seed " .. seed .. " reached depth " .. ____arg_3 .. " in " .. ____arg_4 .. " rounds; survivors " .. ____arg_5 .. "; kills " .. __K2L_Str(__K2L_ListWrap(____out_8, ____count_7)) .. "; " .. gear
end

local ____lambda_4 = function(it) return crawl(it * 97, false) end
local ____lambda_5 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_6 = function(it) return it end
local function main()
    local ____value_2 = crawl(1, true)
    print("\n" .. ____value_2)
    print("-- tournament")
    local results = __K2L_IntRange.new(2, 13):map(____lambda_4)
    local ____mod_6 = results.____modCount
    for ____i_21 = 1, results.size do
        local it = results[____i_21];
        (____lambda_5)(it)
        if results.____modCount ~= ____mod_6 and results:____comodified(____i_21) then
            break
        end
    end
    local ____out_9 = {}
    local ____count_8 = 0
    local ____items_14, ____n_14 = results:____array()
    for ____i_22 = 1, ____n_14 do
        local it = ____items_14[____i_22]
        ____count_8 = ____count_8 + 1
        ____out_9[____count_8] = __K2L_StringToInt(__K2L_Text.substringBefore(__K2L_Text.substringAfter(it, "depth "), " "))
    end
    local depths = __K2L_ListWrap(____out_9, ____count_8)
    local ____arg_6 = __K2L_StringFormat("%.2f", depths:average())
    local ____arg_7 = depths:max()
    local ____result_6 = 0
    local ____items_15, ____n_15 = depths:____array()
    for ____i_23 = 1, ____n_15 do
        local it = ____items_15[____i_23]
        if it == 10 then
            ____result_6 = ____result_6 + 1
        end
    end
    print("average depth " .. ____arg_6 .. ", best " .. ____arg_7 .. ", cleared " .. ____result_6)
    local rng = __K2L_Random.seeded(5)
    local ____out_10 = {}
    for ____i_24 = 1, 1000 do
        local it = ____i_24 - 1
        ____out_10[____i_24] = loot:roll(rng).name
    end
    local drops = __K2L_ListWrap(____out_10, 1000):groupingBy(____lambda_6):eachCount():toSortedMap()
    print("loot distribution " .. __K2L_Str(drops))
end

__K2L_Main(main)
return {Element = Element, Item = Item, Effect = Effect, Fighter = Fighter, LootTable = LootTable, loot = loot, Battle = Battle, party = party, monsters = monsters, crawl = crawl}
