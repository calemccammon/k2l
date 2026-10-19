package db

import db.model.Author
import db.model.AuthorDao
import db.model.Authors
import db.model.Post
import db.model.PostDao
import db.model.Posts
import db.model.Role
import db.orm.Database
import db.orm.DatabaseException

// A blog backend on a tiny ORM: tables declared with delegated columns, DAOs with an identity map, transactions.

fun main() {
    val db = Database()
    db.create(Authors)
    db.create(Posts)
    println("columns: ${Authors.allColumns} ${Posts.allColumns.map { it.name }}")
    println("${Authors.id} ${Authors.role.default} ${Posts.likes.ddl()}")

    val authors = AuthorDao(db)
    val posts = PostDao(db)
    val ada = authors.save(Author(1, "Ada", Role.ADMIN, "first programmer"))
    val bob = authors.save(Author(2, "Bob O'Neil"))
    authors.save(Author(3, "Cy", Role.EDITOR))
    posts.save(Post(10, 1, "Notes on the engine", published = true, likes = 42))
    posts.save(Post(11, 1, "Draft"))
    posts.save(Post(12, 2, "Hello", published = true))

    try {
        authors.save(Author(1, "Impostor"))
    } catch (e: DatabaseException) {
        println("error: ${e.message}")
    }

    println("admins: ${authors.admins()}")
    println("ada's posts: ${posts.byAuthor(ada).map { it.title }}, published: ${posts.publishedBy(ada).map { it.title }}")
    println("all authors: ${authors.all()}")
    println("same object: ${authors.all().first() === ada}, cached ${authors.cached}")

    authors.rename(bob, "Robert")
    bob.role = Role.EDITOR
    bob.role = Role.EDITOR
    println("bob: $bob changes=${bob.changes} reloaded=${authors.find { id eq 2 }}")

    val moved = db.transaction {
        update(Posts, Posts.author eq 1, mapOf(Posts.author to 3))
    }
    println("moved $moved posts")
    try {
        db.transaction {
            insert(Posts, Post(13, 3, "ok"))
            insert(Posts, Post(13, 3, "duplicate"))
        }
    } catch (e: DatabaseException) {
        println("${e.message}: ${e.cause?.message}; posts=${db.count(Posts)}")
    }
    try {
        db.transaction { transaction { 1 } }
    } catch (e: IllegalStateException) {
        println("error: ${e.message}")
    }
    println("posts now: ${posts.all().map { "${it.id}:${it.authorId}:${it.likes}" }}")
    println(posts.all().filter { it.published }.sortedByDescending { it.likes }.map(Post::title))
    db.statements.forEach { println("  $it") }
}
