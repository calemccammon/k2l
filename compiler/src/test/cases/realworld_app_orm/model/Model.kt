package db.model

import db.orm.Column
import db.orm.ColumnType
import db.orm.Dao
import db.orm.Database
import db.orm.Row
import db.orm.Table
import db.orm.Tracked

enum class Role { ADMIN, EDITOR, VIEWER }

class Author(val id: Int, name: String, role: Role = Role.VIEWER, val bio: String? = null) {
    val changes = linkedSetOf<String>()
    var name by Tracked(name, changes)
    var role by Tracked(role, changes)

    override fun toString() = "Author#$id($name, $role${bio?.let { ", $it" } ?: ""})"
}

data class Post(val id: Int, val authorId: Int, val title: String, val published: Boolean = false, val likes: Int = 0)

object Authors : Table<Author>("authors") {
    val id by column(ColumnType.IntType).primaryKey()
    val name by column(ColumnType.TextType)
    val role by column(ColumnType.EnumType(Role.values().toList())).default(Role.VIEWER)
    val bio by column(ColumnType.TextType).nullable()

    override fun toEntity(row: Row) = Author(row[id], row[name], row[role], row.getOrNull(bio))
    override fun toRow(entity: Author): Map<Column<*>, Any?> =
        mapOf(id to entity.id, name to entity.name, role to entity.role, bio to entity.bio)
}

object Posts : Table<Post>("posts") {
    val id by column(ColumnType.IntType).primaryKey()
    val author by column(ColumnType.IntType)
    val title by column(ColumnType.TextType)
    val published by column(ColumnType.BoolType).default(false)
    val likes by column(ColumnType.IntType).default(0)

    override fun toEntity(row: Row) = Post(row[id], row[author], row[title], row[published], row[likes])
    override fun toRow(entity: Post): Map<Column<*>, Any?> =
        mapOf(id to entity.id, author to entity.authorId, title to entity.title, published to entity.published, likes to entity.likes)
}

class AuthorDao(db: Database) : Dao<Author, Authors>(db, Authors) {
    override fun key(entity: Author): Any = entity.id

    fun admins() = find { role eq Role.ADMIN }

    fun rename(author: Author, newName: String) {
        author.name = newName
        db.update(table, table.id eq author.id, mapOf(table.name to newName))
    }
}

class PostDao(db: Database) : Dao<Post, Posts>(db, Posts) {
    fun byAuthor(a: Author) = find { author eq a.id }
    fun publishedBy(a: Author) = find { (author eq a.id) and (published eq true) }
}
