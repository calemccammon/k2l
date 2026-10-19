package db.orm

import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

/** A column type converts between Kotlin values and the stored text. */
sealed class ColumnType<T>(val sqlName: String) {
    abstract fun parse(raw: String): T
    open fun render(value: T): String = value.toString()

    object IntType : ColumnType<Int>("INTEGER") {
        override fun parse(raw: String) = raw.toInt()
    }

    object TextType : ColumnType<String>("TEXT") {
        override fun parse(raw: String) = raw
        override fun render(value: String) = "'" + value.replace("'", "''") + "'"
    }

    object BoolType : ColumnType<Boolean>("BOOLEAN") {
        override fun parse(raw: String) = raw == "1"
        override fun render(value: Boolean) = if (value) "1" else "0"
    }

    class EnumType<E : Enum<E>>(private val values: List<E>) : ColumnType<E>("TEXT") {
        override fun parse(raw: String) = values.first { it.name == raw }
        override fun render(value: E) = "'${value.name}'"
    }
}

class Column<T>(val table: Table<*>, val name: String, val type: ColumnType<T>) {
    var nullable = false
        internal set
    var primaryKey = false
        internal set
    var default: T? = null
        internal set

    fun ddl(): String = buildString {
        append("$name ${type.sqlName}")
        if (primaryKey) append(" PRIMARY KEY")
        if (!nullable && !primaryKey) append(" NOT NULL")
        default?.let { append(" DEFAULT ${type.render(it)}") }
    }

    infix fun eq(value: T): Predicate = Predicate("$name = ${type.render(value)}") { row -> row.raw(this) == type.render(value).trim('\'') }

    override fun toString() = "${table.tableName}.$name"
}

class Predicate(val sql: String, val test: (Row) -> Boolean) {
    infix fun and(other: Predicate) = Predicate("($sql AND ${other.sql})") { test(it) && other.test(it) }
}

/** A table is declared as an object whose properties are columns, named after the properties. */
abstract class Table<E : Any>(val tableName: String) {
    private val columns = mutableListOf<Column<*>>()
    val allColumns: List<Column<*>> get() = columns

    protected fun <T> column(type: ColumnType<T>) = ColumnProvider(type)

    inner class ColumnProvider<T>(private val type: ColumnType<T>) {
        private var primaryKey = false
        private var nullable = false
        private var default: T? = null

        fun primaryKey() = apply { primaryKey = true }
        fun nullable() = apply { nullable = true }
        fun default(value: T) = apply { default = value }

        operator fun provideDelegate(thisRef: Table<E>, property: KProperty<*>): ColumnDelegate<T> {
            val column = Column(this@Table, property.name, type)
            column.primaryKey = primaryKey
            column.nullable = nullable
            column.default = default
            columns += column
            return ColumnDelegate(column)
        }
    }

    class ColumnDelegate<T>(private val column: Column<T>) {
        operator fun getValue(thisRef: Any, property: KProperty<*>): Column<T> = column
    }

    abstract fun toEntity(row: Row): E
    abstract fun toRow(entity: E): Map<Column<*>, Any?>

    fun ddl() = "CREATE TABLE $tableName (" + columns.joinToString(", ") { it.ddl() } + ")"
}

/** A stored row: raw text by column name. */
class Row internal constructor(private val values: Map<String, String?>) {
    fun raw(c: Column<*>): String? = values[c.name]
    operator fun <T> get(c: Column<T>): T = values[c.name]?.let { c.type.parse(it) } ?: c.default ?: throw NoSuchElementException("$c is null")
    fun <T> getOrNull(c: Column<T>): T? = values[c.name]?.let { c.type.parse(it) }
    override fun toString() = values.toString()
}

/** Tracks dirty properties of an entity: a delegate per property that records writes. */
class Tracked<T>(initial: T, private val changes: MutableSet<String>) : ReadWriteProperty<Any?, T> {
    private var value = initial
    override fun getValue(thisRef: Any?, property: KProperty<*>): T = value
    override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        if (value != this.value) changes += property.name
        this.value = value
    }
}
