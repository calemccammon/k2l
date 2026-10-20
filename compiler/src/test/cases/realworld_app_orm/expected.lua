-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TouchObject = ____lualib.__K2L_TouchObject
local __K2L_Unit = ____lualib.__K2L_Unit

local ____Database = require("orm.Database")
local ____Model = require("model.Model")

local ____lambda_1 = function(self) return self:getId():eq(2) end
local ____lambda_2 = function(____this)
    return ____this:update(__K2L_TouchObject(____Model.Posts), ____Model.Posts:getAuthor():eq(1), __K2L_SingletonMapOf(__K2L_Pair.new(____Model.Posts:getAuthor(), 3)))
end
local ____lambda_3 = function(____this_3) return 1 end
local ____lambda_4 = function(____this_2)
    return ____this_2:transaction(____lambda_3)
end
local ____lambda_5 = function(it) return it.likes end
local ____lambda_6 = function(receiver) return receiver.title end
local function main()
    local db = ____Database.Database.new()
    db:create(__K2L_TouchObject(____Model.Authors))
    db:create(__K2L_TouchObject(____Model.Posts))
    local ____arg = ____Model.Authors:getAllColumns()
    local ____list = ____Model.Posts:getAllColumns()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.name
    end
    print("columns: " .. __K2L_Str(____arg) .. " " .. __K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(____Model.Authors:getId()) .. " " .. __K2L_Str(____Model.Authors:getRole().default) .. " " .. ____Model.Posts:getLikes():ddl())
    local authors = ____Model.AuthorDao.new(db)
    local posts = ____Model.PostDao.new(db)
    local ada = authors:save(____Model.Author.new(1, "Ada", ____Model.Role.ADMIN, "first programmer"))
    local bob = authors:save(____Model.Author.new(2, "Bob O'Neil"))
    authors:save(____Model.Author.new(3, "Cy", ____Model.Role.EDITOR))
    posts:save(____Model.Post.new(10, 1, "Notes on the engine", true, 42))
    posts:save(____Model.Post.new(11, 1, "Draft"))
    posts:save(____Model.Post.new(12, 2, "Hello", true))
    local ____ok, ____result = pcall(function()
        authors:save(____Model.Author.new(1, "Impostor"))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if getmetatable(____error) == ____Database.DatabaseException then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print("admins: " .. __K2L_Str(authors:admins()))
    local ____list_1 = posts:byAuthor(ada)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.title
    end
    local ____arg_1 = __K2L_ListWrap(____out_1, ____count_1)
    local ____list_2 = posts:publishedBy(ada)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it.title
    end
    print("ada's posts: " .. __K2L_Str(____arg_1) .. ", published: " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    print("all authors: " .. __K2L_Str(authors:all()))
    print("same object: " .. tostring(authors:all():first() == ada) .. ", cached " .. authors:getCached())
    authors:rename(bob, "Robert")
    bob:setRole(____Model.Role.EDITOR)
    bob:setRole(____Model.Role.EDITOR)
    print("bob: " .. __K2L_Str(bob) .. " changes=" .. __K2L_Str(bob.changes) .. " reloaded=" .. __K2L_Str(authors:find(____lambda_1)))
    local moved = db:transaction(____lambda_2)
    print("moved " .. moved .. " posts")
    local ____ok_1, ____result_1 = pcall(function()
        db:transaction(function(____this_1)
            ____this_1:insert(__K2L_TouchObject(____Model.Posts), ____Model.Post.new(13, 3, "ok"))
            ____this_1:insert(__K2L_TouchObject(____Model.Posts), ____Model.Post.new(13, 3, "duplicate"))
            return __K2L_Unit
        end)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if getmetatable(____error_1) == ____Database.DatabaseException then
            local e = ____error_1
            local ____receiver = e.cause
            print(__K2L_Str(e.message) .. ": " .. __K2L_Str(____receiver and ____receiver.message) .. "; posts=" .. db:count(__K2L_TouchObject(____Model.Posts)))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = pcall(function()
        db:transaction(____lambda_4)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local ____list_3 = posts:all()
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it.id .. ":" .. it.authorId .. ":" .. it.likes
    end
    print("posts now: " .. __K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
    local ____list_4 = posts:all()
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_4, ____n_4 = ____list_4:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        if it.published then
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out_4, ____count_4):sortedByDescending(____lambda_5, true):map(__K2L_PropertyRef.new("title", "title@562", ____lambda_6))))
    local ____list_5 = db.statements
    for ____i_5 = 1, ____list_5.size do
        local it = ____list_5[____i_5]
        print("  " .. it)
    end
end

main()
-- ==== model/Model.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KProperty = ____lualib.__K2L_KProperty
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local ____Table = require("orm.Table")
local ____Database = require("orm.Database")
local Role = __K2L_Class("db.model.Role")

function Role:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Role:toString()
    return self.name
end

function Role:compareTo(other)
    return self.ordinal - other.ordinal
end

Role.ADMIN = Role.new("ADMIN", 0)
Role.EDITOR = Role.new("EDITOR", 1)
Role.VIEWER = Role.new("VIEWER", 2)
Role.____values = {Role.ADMIN, Role.EDITOR, Role.VIEWER}
local Author = __K2L_Class("db.model.Author")

function Author:____init(id, name, role, bio)
    if role == nil then
        role = Role.VIEWER
    end
    if bio == nil then
        bio = nil
    end
    self.id = id
    self.bio = bio
    self.changes = __K2L_SetOf()
    self.____name_delegate = ____Table.Tracked.new(name, self.changes)
    self.____role_delegate = ____Table.Tracked.new(role, self.changes)
end

Author.____name_property = __K2L_PropertyRef.new("name", "db/model/Author.name")

function Author:getName()
    return self.____name_delegate:getValue(self, Author.____name_property)
end

function Author:setName(value)
    self.____name_delegate:setValue(self, Author.____name_property, value)
end

Author.____role_property = __K2L_PropertyRef.new("role", "db/model/Author.role")

function Author:getRole()
    return self.____role_delegate:getValue(self, Author.____role_property)
end

function Author:setRole(value)
    self.____role_delegate:setValue(self, Author.____role_property, value)
end

function Author:toString()
    local ____receiver = self.bio
    return "Author#" .. self.id .. "(" .. self:getName() .. ", " .. __K2L_Str(self:getRole()) .. (____receiver and ", " .. ____receiver or "") .. ")"
end

local Post = __K2L_Class("db.model.Post")

function Post:____init(id, authorId, title, published, likes)
    if published == nil then
        published = false
    end
    if likes == nil then
        likes = 0
    end
    self.id = id
    self.authorId = authorId
    self.title = title
    self.published = published
    self.likes = likes
end

function Post:toString()
    return "Post(id=" .. self.id .. ", authorId=" .. self.authorId .. ", title=" .. self.title .. ", published=" .. tostring(self.published) .. ", likes=" .. self.likes .. ")"
end

function Post:hashCode()
    return (31 * (31 * (31 * (31 * self.id + self.authorId) + __K2L_Hash(self.title)) + (self.published and 1231 or 1237)) + self.likes + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Post:equals(other)
    return getmetatable(other) == Post and self.id == other.id and self.authorId == other.authorId and self.title == other.title and self.published == other.published and self.likes == other.likes
end

local Authors = __K2L_Class("db.model.Authors", ____Table.Table)

function Authors:____init()
    ____Table.Table.____init(self, "authors")
    self.____id_delegate = self:column(____Table.ColumnType.IntType):primaryKey__1():provideDelegate(self, __K2L_KProperty("id", "db/model/Authors.id"))
    self.____name_delegate = self:column(____Table.ColumnType.TextType):provideDelegate(self, __K2L_KProperty("name", "db/model/Authors.name"))
    self.____role_delegate = self:column(____Table.ColumnType.EnumType.new(__K2L_EnumValues(Role):toList())):default__1(Role.VIEWER):provideDelegate(self, __K2L_KProperty("role", "db/model/Authors.role"))
    self.____bio_delegate = self:column(____Table.ColumnType.TextType):nullable__1():provideDelegate(self, __K2L_KProperty("bio", "db/model/Authors.bio"))
end

Authors.____id_property = __K2L_PropertyRef.new("id", "db/model/Authors.id")

function Authors:getId()
    return self.____id_delegate:getValue(self, Authors.____id_property)
end

Authors.____name_property = __K2L_PropertyRef.new("name", "db/model/Authors.name")

function Authors:getName()
    return self.____name_delegate:getValue(self, Authors.____name_property)
end

Authors.____role_property = __K2L_PropertyRef.new("role", "db/model/Authors.role")

function Authors:getRole()
    return self.____role_delegate:getValue(self, Authors.____role_property)
end

Authors.____bio_property = __K2L_PropertyRef.new("bio", "db/model/Authors.bio")

function Authors:getBio()
    return self.____bio_delegate:getValue(self, Authors.____bio_property)
end

function Authors:toEntity(row)
    return Author.new(row:get(self:getId()), row:get(self:getName()), row:get(self:getRole()), row:getOrNull(self:getBio()))
end

function Authors:toRow(entity)
    return __K2L_ReadOnlyMapOf(__K2L_Pair.new(self:getId(), entity.id), __K2L_Pair.new(self:getName(), entity:getName()), __K2L_Pair.new(self:getRole(), entity:getRole()), __K2L_Pair.new(self:getBio(), entity.bio))
end

__K2L_LazyObject(Authors, "____init")
local Posts = __K2L_Class("db.model.Posts", ____Table.Table)

function Posts:____init()
    ____Table.Table.____init(self, "posts")
    self.____id_delegate = self:column(____Table.ColumnType.IntType):primaryKey__1():provideDelegate(self, __K2L_KProperty("id", "db/model/Posts.id"))
    self.____author_delegate = self:column(____Table.ColumnType.IntType):provideDelegate(self, __K2L_KProperty("author", "db/model/Posts.author"))
    self.____title_delegate = self:column(____Table.ColumnType.TextType):provideDelegate(self, __K2L_KProperty("title", "db/model/Posts.title"))
    self.____published_delegate = self:column(____Table.ColumnType.BoolType):default__1(false):provideDelegate(self, __K2L_KProperty("published", "db/model/Posts.published"))
    self.____likes_delegate = self:column(____Table.ColumnType.IntType):default__1(0):provideDelegate(self, __K2L_KProperty("likes", "db/model/Posts.likes"))
end

Posts.____id_property = __K2L_PropertyRef.new("id", "db/model/Posts.id")

function Posts:getId()
    return self.____id_delegate:getValue(self, Posts.____id_property)
end

Posts.____author_property = __K2L_PropertyRef.new("author", "db/model/Posts.author")

function Posts:getAuthor()
    return self.____author_delegate:getValue(self, Posts.____author_property)
end

Posts.____title_property = __K2L_PropertyRef.new("title", "db/model/Posts.title")

function Posts:getTitle()
    return self.____title_delegate:getValue(self, Posts.____title_property)
end

Posts.____published_property = __K2L_PropertyRef.new("published", "db/model/Posts.published")

function Posts:getPublished()
    return self.____published_delegate:getValue(self, Posts.____published_property)
end

Posts.____likes_property = __K2L_PropertyRef.new("likes", "db/model/Posts.likes")

function Posts:getLikes()
    return self.____likes_delegate:getValue(self, Posts.____likes_property)
end

function Posts:toEntity(row)
    return Post.new(row:get(self:getId()), row:get(self:getAuthor()), row:get(self:getTitle()), row:get(self:getPublished()), row:get(self:getLikes()))
end

function Posts:toRow(entity)
    return __K2L_ReadOnlyMapOf(__K2L_Pair.new(self:getId(), entity.id), __K2L_Pair.new(self:getAuthor(), entity.authorId), __K2L_Pair.new(self:getTitle(), entity.title), __K2L_Pair.new(self:getPublished(), entity.published), __K2L_Pair.new(self:getLikes(), entity.likes))
end

__K2L_LazyObject(Posts, "____init")
local AuthorDao = __K2L_Class("db.model.AuthorDao", ____Database.Dao)

function AuthorDao:____init(db)
    ____Database.Dao.____init(self, db, __K2L_TouchObject(Authors))
end

function AuthorDao:key(entity)
    return entity.id
end

local ____lambda_1 = function(____this)
    return ____this:getRole():eq(Role.ADMIN)
end
function AuthorDao:admins()
    return self:find(____lambda_1)
end

function AuthorDao:rename(author, newName)
    author:setName(newName)
    self.db:update(self.table, self.table:getId():eq(author.id), __K2L_SingletonMapOf(__K2L_Pair.new(self.table:getName(), newName)))
end

local PostDao = __K2L_Class("db.model.PostDao", ____Database.Dao)

function PostDao:____init(db)
    ____Database.Dao.____init(self, db, __K2L_TouchObject(Posts))
end

function PostDao:byAuthor(a)
    return self:find(function(____this_1)
        return ____this_1:getAuthor():eq(a.id)
    end)
end

function PostDao:publishedBy(a)
    return self:find(function(____this_2)
        return ____this_2:getAuthor():eq(a.id):____and(____this_2:getPublished():eq(true))
    end)
end

return {Role = Role, Author = Author, Post = Post, Authors = Authors, Posts = Posts, AuthorDao = AuthorDao, PostDao = PostDao}
-- ==== orm/Database.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____Table = require("orm.Table")
local DatabaseException = __K2L_Class("db.orm.DatabaseException", __K2L_RuntimeException)

function DatabaseException:____init(message, cause)
    if cause == nil then
        cause = nil
    end
    __K2L_RuntimeException.____init(self, message, cause)
end

local Database = __K2L_Class("db.orm.Database")

function Database:____init()
    self.data = __K2L_MapOf()
    self.statements = __K2L_ListOf()
    self.snapshot = nil
end

function Database:create(____table)
    self.statements:add(____table:ddl())
    local ____object = self.data
    local ____key = ____table.tableName
    ____object:set(____key, __K2L_ListOf())
end

function Database:rows(____table)
    local ____value = self.data:get(____table.tableName)
    if ____value == nil then
        error(DatabaseException.new("no such table: " .. ____table.tableName))
    end
    return ____value
end

function Database:render(c, v)
    local ____result_1
    if v ~= nil then
        local ____result
        if getmetatable(c) ~= ____Table.Column then
            __K2L_CastFail(c, "db.orm.Column", "db.orm.Column")
        end
        ____result = c.type:render(v)
        ____result_1 = ____result
    end
    return ____result_1
end

function Database:insert(____table, entity)
    local values = ____table:toRow(entity)
    local ____list = ____table:getAllColumns()
    local ____result_2
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it.primaryKey then
            ____result_2 = it
            break
        end
    end
    local pk = ____result_2
    local ____result_4
    if pk ~= nil then
        local ____result_3
        do
            local ____receiver = self:render(pk, values:get(pk))
            ____result_3 = ____receiver and __K2L_Text.trimChars(____receiver, 3, "'")
        end
        ____result_4 = ____result_3
    end
    local key = ____result_4
    local ____cond = key ~= nil
    if ____cond then
        local ____list_1 = self:rows(____table)
        local ____result_5 = false
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            if it:get(pk.name) == key then
                ____result_5 = true
                break
            end
        end
        ____cond = ____result_5
    end
    if ____cond then
        error(DatabaseException.new("duplicate key " .. key .. " in " .. ____table.tableName))
    end
    local ____list_2 = ____table:getAllColumns()
    local ____mod = ____list_2.____modCount
    for ____i_2 = 1, ____list_2.size do
        local c = ____list_2[____i_2]
        if not c.nullable and values:get(c) == nil and c.default == nil then
            error(DatabaseException.new(__K2L_Str(c) .. " may not be null"))
        end
        if ____list_2.____modCount ~= ____mod and ____list_2:____comodified(____i_2) then
            break
        end
    end
    self.statements:add("INSERT INTO " .. ____table.tableName .. " VALUES (" .. ____table:getAllColumns():joinToString(nil, nil, nil, nil, nil, function(it)
        return self:render(it, values:get(it)) or "NULL"
    end) .. ")")
    self:rows(____table):add(____table:getAllColumns():associate(function(it)
        local ____arg = it.name
        local ____receiver_1 = self:render(it, values:get(it)) or self:render(it, it.default)
        return __K2L_Pair.new(____arg, ____receiver_1 and __K2L_Text.trimChars(self:render(it, values:get(it)) or self:render(it, it.default), 3, "'"))
    end):toMutableMap())
end

function Database:select(____table, where)
    if where == nil then
        where = nil
    end
    self.statements:add("SELECT * FROM " .. ____table.tableName .. (where and " WHERE " .. where.sql or ""))
    local ____list_3 = self:rows(____table)
    local ____out = {}
    local ____count = 0
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____count = ____count + 1
        ____out[____count] = ____Table.Row.new(it)
    end
    local ____list_4 = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = ____list_4:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        local ____result_6
        do
            local ____receiver_2 = where and where.test
            local ____value_1 = ____receiver_2 and ____receiver_2(it)
            if ____value_1 == nil then
                ____value_1 = true
            end
            ____result_6 = ____value_1
        end
        if ____result_6 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1):map(function(...) return ____table:toEntity(...) end)
end

function Database:update(____table, where, changes)
    self.statements:add("UPDATE " .. ____table.tableName .. " SET " .. changes:getEntries():joinToString(nil, nil, nil, nil, nil, function(____destructured)
        local c, v = ____destructured.key, ____destructured.value
        return c.name .. " = " .. __K2L_Str(self:render(c, v))
    end) .. " WHERE " .. where.sql)
    local n = 0
    local ____list_5 = self:rows(____table)
    local ____mod_2 = ____list_5.____modCount
    for ____i_6 = 1, ____list_5.size do
        local row = ____list_5[____i_6]
        do
            if not where.test(____Table.Row.new(row)) then
                goto ____continue
            end
            local ____items_4, ____n_4 = changes:____entryArray()
            local ____mod_1 = changes.____modCount
            for ____i_5 = 1, ____n_4 do
                local ____entry = ____items_4[____i_5]
                do
                    local c, v = ____entry.key, ____entry.value
                    local ____key_1 = c.name
                    local ____receiver_3 = self:render(c, v)
                    row:set(____key_1, ____receiver_3 and __K2L_Text.trimChars(____receiver_3, 3, "'"))
                end
                if changes.____modCount ~= ____mod_1 and changes:____comodified(____i_5, ____n_4) then
                    break
                end
            end
            n = n + 1
        end
        ::____continue::
        if ____list_5.____modCount ~= ____mod_2 and ____list_5:____comodified(____i_6) then
            break
        end
    end
    return n
end

function Database:transaction(block)
    if self.snapshot ~= nil then
        error(__K2L_IllegalStateException.new("nested transactions are not supported"))
    end
    self.snapshot = self.data:mapValues(function(____destructured_1)
        local rows = ____destructured_1.value
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_5, ____n_5 = rows:____array()
        for ____i_7 = 1, ____n_5 do
            local it = ____items_5[____i_7]
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it:toMap()
        end
        return __K2L_ListWrap(____out_2, ____count_2)
    end)
    self.statements:add("BEGIN")
    local ____ok, ____result_7, ____returned = pcall(function()
        local ____value_2 = block(self)
        self.statements:add("COMMIT")
        return true, ____value_2
    end)
    if not ____ok then
        ____ok, ____result_7, ____returned = pcall(function()
            local ____error = __K2L_ToThrowable(____result_7)
            if getmetatable(____error) == DatabaseException then
                local e = ____error
                self.statements:add("ROLLBACK")
                local ____collection = __K2L_NotNull(self.snapshot)
                local ____items_6, ____n_6 = ____collection:____entryArray()
                local ____mod_3 = ____collection.____modCount
                for ____i_9 = 1, ____n_6 do
                    local ____entry_1 = ____items_6[____i_9]
                    do
                        local name, rows = ____entry_1.key, ____entry_1.value
                        local ____object_1 = self.data
                        local ____out_3 = {}
                        local ____count_3 = 0
                        local ____items_7, ____n_7 = rows:____array()
                        for ____i_8 = 1, ____n_7 do
                            local it = ____items_7[____i_8]
                            ____count_3 = ____count_3 + 1
                            ____out_3[____count_3] = it:toMutableMap()
                        end
                        ____object_1:set(name, __K2L_ListWrap(____out_3, ____count_3):toMutableList())
                    end
                    if ____collection.____modCount ~= ____mod_3 and ____collection:____comodified(____i_9, ____n_6) then
                        break
                    end
                end
                error(DatabaseException.new("transaction failed", e))
            else
                error(____error, 0)
            end
        end)
    end
    self.snapshot = nil
    if not ____ok then
        error(____result_7, 0)
    end
    if ____result_7 then
        return ____returned
    end
end

function Database:count(____table)
    return self:rows(____table).size
end

local Dao = __K2L_Class("db.orm.Dao")

function Dao:____init(db, ____table)
    self.db = db
    self.table = ____table
    self.identity = __K2L_MapOf()
end

function Dao:key(entity)
    return __K2L_Hash(entity)
end

function Dao:save(entity)
    self.db:insert(self.table, entity)
    local ____object_2 = self.identity
    local ____key_2 = self:key(entity)
    ____object_2:set(____key_2, entity)
    return entity
end

function Dao:find(predicate)
    local ____list_6 = self.db:select(self.table, predicate(self.table))
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_8, ____n_8 = ____list_6:____array()
    for ____i_10 = 1, ____n_8 do
        local e = ____items_8[____i_10]
        local ____result_8
        ____result_8 = self.identity:getOrPut(self:key(e), function() return e end)
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = ____result_8
    end
    return __K2L_ListWrap(____out_4, ____count_4)
end

local ____lambda_1 = function(it) return true end
local ____lambda_2 = function(____this)
    return ____Table.Predicate.new("1 = 1", ____lambda_1)
end
function Dao:all()
    return self:find(____lambda_2)
end

function Dao:getCached()
    return self.identity.size
end

return {DatabaseException = DatabaseException, Database = Database, Dao = Dao}
-- ==== orm/Table.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text

local Predicate, Table, Row
local ColumnType = __K2L_Class("db.orm.ColumnType")

function ColumnType:____init(sqlName)
    self.sqlName = sqlName
end

function ColumnType.new(sqlName)
    return setmetatable({sqlName = sqlName}, ColumnType)
end

function ColumnType:render(value)
    return __K2L_Str(value)
end

ColumnType.IntType = __K2L_Class("db.orm.ColumnType$IntType", ColumnType)

function ColumnType.IntType:____init()
    ColumnType.____init(self, "INTEGER")
end

function ColumnType.IntType:parse(raw)
    return __K2L_StringToInt(raw)
end

ColumnType.IntType:____init()
ColumnType.TextType = __K2L_Class("db.orm.ColumnType$TextType", ColumnType)

function ColumnType.TextType:____init()
    ColumnType.____init(self, "TEXT")
end

function ColumnType.TextType:parse(raw)
    return raw
end

function ColumnType.TextType:render(value)
    return "'" .. __K2L_StringReplace(value, "'", "''") .. "'"
end

ColumnType.TextType:____init()
ColumnType.BoolType = __K2L_Class("db.orm.ColumnType$BoolType", ColumnType)

function ColumnType.BoolType:____init()
    ColumnType.____init(self, "BOOLEAN")
end

function ColumnType.BoolType:parse(raw)
    return raw == "1"
end

function ColumnType.BoolType:render(value)
    return value and "1" or "0"
end

ColumnType.BoolType:____init()
ColumnType.EnumType = __K2L_Class("db.orm.ColumnType$EnumType", ColumnType)

function ColumnType.EnumType:____init(values)
    ColumnType.____init(self, "TEXT")
    self.values = values
end

function ColumnType.EnumType:parse(raw)
    local ____list = self.values
    local ____result
    local ____found = false
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it.name == raw then
            ____result = it
            ____found = true
            break
        end
    end
    if not ____found then
        error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
    end
    return ____result
end

function ColumnType.EnumType:render(value)
    return "'" .. value.name .. "'"
end

local Column = __K2L_Class("db.orm.Column")

function Column:____init(____table, name, ____type)
    self.table = ____table
    self.name = name
    self.type = ____type
    self.nullable = false
    self.primaryKey = false
    self.default = nil
end

function Column:ddl()
    local ____builder = __K2L_StringBuilder.new()
    do
        ____builder:append(self.name .. " " .. self.type.sqlName)
        if self.primaryKey then
            ____builder:append(" PRIMARY KEY")
        end
        if not self.nullable and not self.primaryKey then
            ____builder:append(" NOT NULL")
        end
        local ____receiver = self.default
        if ____receiver ~= nil then
            ____builder:append(" DEFAULT " .. self.type:render(____receiver))
        end
    end
    return ____builder:toString()
end

function Column:eq(value)
    return Predicate.new(self.name .. " = " .. self.type:render(value), function(row)
        return row:raw(self) == __K2L_Text.trimChars(self.type:render(value), 3, "'")
    end)
end

function Column:toString()
    return self.table.tableName .. "." .. self.name
end

Predicate = __K2L_Class("db.orm.Predicate")

function Predicate:____init(sql, test)
    self.sql = sql
    self.test = test
end

function Predicate.new(sql, test)
    return setmetatable({sql = sql, test = test}, Predicate)
end

function Predicate:____and(other)
    return Predicate.new("(" .. self.sql .. " AND " .. other.sql .. ")", function(it) return self.test(it) and other.test(it) end)
end

Table = __K2L_Class("db.orm.Table")

function Table:____init(tableName)
    self.tableName = tableName
    self.columns = __K2L_ListOf()
end

function Table:getAllColumns()
    return self.columns
end

function Table:column(____type)
    return Table.ColumnProvider.new(self, ____type)
end

Table.ColumnProvider = __K2L_Class("db.orm.Table$ColumnProvider")

function Table.ColumnProvider:____init(____outer, ____type)
    self.____outer = ____outer
    self.type = ____type
    self.primaryKey = false
    self.nullable = false
    self.default = nil
end

function Table.ColumnProvider:primaryKey__1()
    self.primaryKey = true
    return self
end

function Table.ColumnProvider:nullable__1()
    self.nullable = true
    return self
end

function Table.ColumnProvider:default__1(value)
    self.default = value
    return self
end

function Table.ColumnProvider:provideDelegate(thisRef, property)
    local column = Column.new(self.____outer, property.name, self.type)
    column.primaryKey = self.primaryKey
    column.nullable = self.nullable
    column.default = self.default
    self.____outer.columns:add(column)
    return Table.ColumnDelegate.new(column)
end

Table.ColumnDelegate = __K2L_Class("db.orm.Table$ColumnDelegate")

function Table.ColumnDelegate:____init(column)
    self.column = column
end

function Table.ColumnDelegate.new(column)
    return setmetatable({column = column}, Table.ColumnDelegate)
end

function Table.ColumnDelegate:getValue(thisRef, property)
    return self.column
end

local ____lambda_1 = function(it) return it:ddl() end
function Table:ddl()
    return "CREATE TABLE " .. self.tableName .. " (" .. self.columns:joinToString(", ", nil, nil, nil, nil, ____lambda_1) .. ")"
end

Row = __K2L_Class("db.orm.Row")

function Row:____init(values)
    self.values = values
end

function Row.new(values)
    return setmetatable({values = values}, Row)
end

function Row:raw(c)
    return self.values:get(c.name)
end

function Row:get(c)
    local ____receiver_1 = self.values:get(c.name)
    local ____value = ____receiver_1 and c.type:parse(____receiver_1) or c.default
    if ____value == nil then
        error(__K2L_NoSuchElementException.new(__K2L_Str(c) .. " is null"))
    end
    return ____value
end

function Row:getOrNull(c)
    local ____receiver_2 = self.values:get(c.name)
    return ____receiver_2 and c.type:parse(____receiver_2)
end

function Row:toString()
    return __K2L_Str(self.values)
end

local Tracked = __K2L_Class("db.orm.Tracked")

function Tracked:____init(initial, changes)
    self.changes = changes
    self.value = initial
end

function Tracked:getValue(thisRef, property)
    return self.value
end

function Tracked:setValue(thisRef, property, value)
    if not __K2L_Equals(value, self.value) then
        self.changes:add(property.name)
    end
    self.value = value
end

return {ColumnType = ColumnType, Column = Column, Predicate = Predicate, Table = Table, Row = Row, Tracked = Tracked}
