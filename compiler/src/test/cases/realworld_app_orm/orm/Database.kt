package db.orm

class DatabaseException(message: String, cause: Throwable? = null) : RuntimeException(message, cause)

/** An in-memory database that logs the SQL it would run. */
class Database {
    private val data = linkedMapOf<String, MutableList<MutableMap<String, String?>>>()
    val statements = mutableListOf<String>()
    private var snapshot: Map<String, List<Map<String, String?>>>? = null

    fun create(table: Table<*>) {
        statements += table.ddl()
        data[table.tableName] = mutableListOf()
    }

    private fun rows(table: Table<*>) = data[table.tableName] ?: throw DatabaseException("no such table: ${table.tableName}")

    @Suppress("UNCHECKED_CAST")
    private fun render(c: Column<*>, v: Any?): String? = v?.let { (c as Column<Any?>).type.render(it) }

    fun <E : Any> insert(table: Table<E>, entity: E) {
        val values = table.toRow(entity)
        val pk = table.allColumns.firstOrNull { it.primaryKey }
        val key = pk?.let { render(it, values[it])?.trim('\'') }
        if (key != null && rows(table).any { it[pk.name] == key }) {
            throw DatabaseException("duplicate key $key in ${table.tableName}")
        }
        for (c in table.allColumns) {
            if (!c.nullable && values[c] == null && c.default == null) throw DatabaseException("$c may not be null")
        }
        statements += "INSERT INTO ${table.tableName} VALUES (" + table.allColumns.joinToString { render(it, values[it]) ?: "NULL" } + ")"
        rows(table) += table.allColumns.associate { it.name to (render(it, values[it]) ?: render(it, it.default))?.trim('\'') }.toMutableMap()
    }

    fun <E : Any> select(table: Table<E>, where: Predicate? = null): List<E> {
        statements += "SELECT * FROM ${table.tableName}" + (where?.let { " WHERE ${it.sql}" } ?: "")
        return rows(table).map { Row(it) }.filter { where?.test?.invoke(it) ?: true }.map(table::toEntity)
    }

    fun <E : Any> update(table: Table<E>, where: Predicate, changes: Map<Column<*>, Any?>): Int {
        statements += "UPDATE ${table.tableName} SET " + changes.entries.joinToString { (c, v) -> "${c.name} = ${render(c, v)}" } +
            " WHERE ${where.sql}"
        var n = 0
        for (row in rows(table)) {
            if (!where.test(Row(row))) continue
            changes.forEach { (c, v) -> row[c.name] = render(c, v)?.trim('\'') }
            n++
        }
        return n
    }

    fun <R> transaction(block: Database.() -> R): R {
        check(snapshot == null) { "nested transactions are not supported" }
        snapshot = data.mapValues { (_, rows) -> rows.map { it.toMap() } }
        statements += "BEGIN"
        try {
            return block().also { statements += "COMMIT" }
        } catch (e: DatabaseException) {
            statements += "ROLLBACK"
            snapshot!!.forEach { (name, rows) -> data[name] = rows.map { it.toMutableMap() }.toMutableList() }
            throw DatabaseException("transaction failed", e)
        } finally {
            snapshot = null
        }
    }

    fun count(table: Table<*>) = rows(table).size
}

/** Data access for one table, with an identity map so a row loads into one object. */
open class Dao<E : Any, T : Table<E>>(protected val db: Database, val table: T) {
    private val identity = mutableMapOf<Any, E>()

    open fun key(entity: E): Any = entity.hashCode()

    fun save(entity: E): E {
        db.insert(table, entity)
        identity[key(entity)] = entity
        return entity
    }

    fun find(predicate: T.() -> Predicate): List<E> = db.select(table, table.predicate()).map { e -> identity.getOrPut(key(e)) { e } }

    fun all(): List<E> = find { Predicate("1 = 1") { true } }

    val cached get() = identity.size
}
