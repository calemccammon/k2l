package lib.model

const val MAX_LOANS = 3

typealias Isbn = String

interface Identified {
    val id: String
    fun describe(): String = "#$id"
}

interface Factory<T> {
    fun create(fields: Map<String, String>): T
}

enum class Genre { FICTION, SCIENCE, HISTORY, KIDS }

abstract class Media(override val id: String, val title: String) : Identified, Comparable<Media> {
    abstract val loanDays: Int
    open val lateFeePerDay: Int get() = 25

    override fun compareTo(other: Media): Int = title.compareTo(other.title, ignoreCase = true)

    override fun describe() = "${super.describe()} \"$title\""

    override fun toString() = "${this::class.simpleName}($id)"
}

class Book(id: String, title: String, val author: String, val isbn: Isbn, val genre: Genre) : Media(id, title) {
    override val loanDays = if (genre == Genre.KIDS) 7 else 21

    override fun describe() = "${super.describe()} by $author"

    companion object : Factory<Book> {
        override fun create(fields: Map<String, String>) = Book(
            fields.getValue("id"),
            fields.getValue("title"),
            fields["author"] ?: "anonymous",
            fields["isbn"].orEmpty(),
            Genre.valueOf(fields["genre"]?.uppercase() ?: "FICTION"),
        )
    }
}

class Dvd(id: String, title: String, val minutes: Int) : Media(id, title) {
    override val loanDays get() = 7
    override val lateFeePerDay = 100

    companion object : Factory<Dvd> {
        override fun create(fields: Map<String, String>) =
            Dvd(fields.getValue("id"), fields.getValue("title"), fields["minutes"]?.toIntOrNull() ?: 90)
    }
}

data class Member(val name: String, val id: Int) {
    var fines: Int = 0
        internal set
    internal val loans = mutableListOf<Loan>()

    val canBorrow get() = loans.size < MAX_LOANS && fines < 500
}

data class Loan(val media: Media, val member: Member, val day: Int) {
    val due get() = day + media.loanDays
}

fun <T : Media> Factory<T>.parse(line: String): T = create(
    line.split(';').associate { field ->
        val (key, value) = field.split('=', limit = 2).map(String::trim)
        key to value
    },
)
