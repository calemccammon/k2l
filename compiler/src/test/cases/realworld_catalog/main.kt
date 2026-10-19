// A lending-library catalogue: indexes built with computeIfAbsent/merge, loans with due dates
// as day numbers, fines, recommendations from co-borrowing, and a pretty-printed JSON export.

typealias Isbn = String

enum class Genre { FICTION, SCIENCE, HISTORY, KIDS, POETRY }

data class Book(val isbn: Isbn, val title: String, val author: String, val year: Int, val genres: Set<Genre>, val copies: Int = 1)

data class Member(val id: Int, val name: String, val tier: Tier) {
    enum class Tier(val maxLoans: Int, val loanDays: Int, val finePerDay: Int) {
        BASIC(2, 14, 25), PLUS(5, 28, 10), STAFF(10, 60, 0)
    }
}

data class Loan(val isbn: Isbn, val member: Int, val out: Int, val due: Int, var returned: Int? = null) {
    fun daysLate(today: Int) = maxOf(0, (returned ?: today) - due)
}

class LibraryException(message: String) : Exception(message)

class Library {
    private val books = LinkedHashMap<Isbn, Book>()
    private val members = HashMap<Int, Member>()
    private val loans = ArrayList<Loan>()
    private val byAuthor = sortedMapOf<String, MutableList<Isbn>>()
    private val byGenre = HashMap<Genre, MutableSet<Isbn>>()
    private val wordIndex = HashMap<String, MutableSet<Isbn>>()

    fun add(book: Book) {
        books.putIfAbsent(book.isbn, book)?.let { throw LibraryException("duplicate isbn ${book.isbn}") }
        byAuthor.computeIfAbsent(book.author) { mutableListOf() }.add(book.isbn)
        book.genres.forEach { g -> byGenre.getOrPut(g) { linkedSetOf() } += book.isbn }
        book.title.lowercase().split(' ').filter { it.length > 2 }.forEach { w -> wordIndex.computeIfAbsent(w) { sortedSetOf() }.add(book.isbn) }
    }

    fun join(member: Member) {
        members[member.id] = member
    }

    fun available(isbn: Isbn): Int = books.getValue(isbn).copies - loans.count { it.isbn == isbn && it.returned == null }

    fun lend(isbn: Isbn, memberId: Int, today: Int): Loan {
        val member = members[memberId] ?: throw LibraryException("no member $memberId")
        val book = books[isbn] ?: throw LibraryException("no book $isbn")
        val open = loans.filter { it.member == memberId && it.returned == null }
        when {
            open.size >= member.tier.maxLoans -> throw LibraryException("${member.name} has reached ${member.tier.maxLoans} loans")
            open.any { it.daysLate(today) > 0 } -> throw LibraryException("${member.name} has overdue books")
            available(isbn) <= 0 -> throw LibraryException("'${book.title}' is not available")
        }
        return Loan(isbn, memberId, today, today + member.tier.loanDays).also { loans += it }
    }

    fun giveBack(isbn: Isbn, memberId: Int, today: Int): Int {
        val loan = loans.firstOrNull { it.isbn == isbn && it.member == memberId && it.returned == null }
            ?: throw LibraryException("no open loan of $isbn by $memberId")
        loan.returned = today
        return loan.daysLate(today) * members.getValue(memberId).tier.finePerDay
    }

    fun search(query: String): List<Book> = query.lowercase().split(' ').filter { it.length > 2 }
        .map { wordIndex[it].orEmpty() }
        .reduceOrNull { acc, s -> acc intersect s }
        .orEmpty()
        .map(books::getValue)

    fun recommend(isbn: Isbn): List<Pair<String, Int>> {
        val readers = loans.filter { it.isbn == isbn }.map { it.member }.toSet()
        val counts = mutableMapOf<Isbn, Int>()
        loans.filter { it.member in readers && it.isbn != isbn }.distinctBy { it.member to it.isbn }
            .forEach { counts.merge(it.isbn, 1, Int::plus) }
        return counts.entries.sortedWith(compareByDescending<Map.Entry<Isbn, Int>> { it.value }.thenBy { books.getValue(it.key).title })
            .map { books.getValue(it.key).title to it.value }
    }

    fun overdue(today: Int) = loans.filter { it.returned == null && it.daysLate(today) > 0 }
        .groupBy { members.getValue(it.member).name }
        .mapValues { (_, ls) -> ls.map { books.getValue(it.isbn).title to it.daysLate(today) } }
        .toSortedMap()

    fun authors() = byAuthor.mapValues { (_, isbns) -> isbns.size }
    fun genres() = Genre.entries.associateWith { byGenre[it]?.size ?: 0 }.filterValues { it > 0 }

    fun export(): Map<String, Any?> = mapOf(
        "books" to books.values.map { b ->
            mapOf("isbn" to b.isbn, "title" to b.title, "year" to b.year, "genres" to b.genres.map { it.name.lowercase() }, "available" to available(b.isbn))
        },
        "members" to members.values.sortedBy { it.id }.map { mapOf("id" to it.id, "name" to it.name, "tier" to it.tier.name) },
        "openLoans" to loans.count { it.returned == null },
        "note" to null,
    )
}

fun toJson(value: Any?, indent: String = ""): String = when (value) {
    null -> "null"
    is String -> buildString {
        append('"')
        for (c in value) {
            when (c) {
                '"' -> append("\\\"")
                '\\' -> append("\\\\")
                '\n' -> append("\\n")
                else -> if (c.code < 0x20) append("\\u%04x".format(c.code)) else append(c)
            }
        }
        append('"')
    }
    is Number, is Boolean -> value.toString()
    is Map<*, *> -> if (value.isEmpty()) "{}" else value.entries.joinToString(",\n", "{\n", "\n$indent}") { (k, v) ->
        "$indent  ${toJson(k.toString())}: ${toJson(v, "$indent  ")}"
    }
    is Iterable<*> -> {
        val items = value.toList()
        if (items.all { it !is Map<*, *> && it !is Iterable<*> }) items.joinToString(", ", "[", "]") { toJson(it) }
        else items.joinToString(",\n", "[\n", "\n$indent]") { "$indent  ${toJson(it, "$indent  ")}" }
    }
    else -> toJson(value.toString())
}

fun main() {
    val lib = Library()
    listOf(
        Book("978-0", "The Time Machine", "H. G. Wells", 1895, setOf(Genre.FICTION, Genre.SCIENCE), copies = 2),
        Book("978-1", "The War of the Worlds", "H. G. Wells", 1898, setOf(Genre.FICTION)),
        Book("978-2", "A Brief History of Time", "Stephen Hawking", 1988, setOf(Genre.SCIENCE)),
        Book("978-3", "The Story of Art", "E. H. Gombrich", 1950, setOf(Genre.HISTORY)),
        Book("978-4", "A Little History of the World", "E. H. Gombrich", 1936, setOf(Genre.HISTORY, Genre.KIDS)),
        Book("978-5", "The Gruffalo", "Julia Donaldson", 1999, setOf(Genre.KIDS, Genre.POETRY), copies = 3),
        Book("978-6", "Leaves of Grass", "Walt Whitman", 1855, setOf(Genre.POETRY)),
    ).forEach(lib::add)
    try {
        lib.add(Book("978-6", "Dup", "X", 2000, emptySet()))
    } catch (e: LibraryException) {
        println("error: ${e.message}")
    }
    listOf(Member(1, "Ana", Member.Tier.BASIC), Member(2, "Ben", Member.Tier.PLUS), Member(3, "Cy", Member.Tier.STAFF), Member(4, "Di", Member.Tier.PLUS))
        .forEach(lib::join)

    println("authors: ${lib.authors()}")
    println("genres: ${lib.genres()}")
    println("search 'history': ${lib.search("history").map { it.title }}")
    println("search 'the time': ${lib.search("THE time").map { it.title }}")
    println("search 'nothing here': ${lib.search("nothing here")}")

    val actions = listOf(
        Triple("978-0", 1, 1), Triple("978-2", 1, 1), Triple("978-3", 1, 2), Triple("978-0", 2, 2), Triple("978-0", 3, 3),
        Triple("978-2", 2, 3), Triple("978-5", 4, 4), Triple("978-0", 4, 5), Triple("978-9", 2, 5), Triple("978-1", 7, 5),
    )
    for ((isbn, member, day) in actions) {
        try {
            val loan = lib.lend(isbn, member, day)
            println("day $day: lent $isbn to $member, due day ${loan.due}")
        } catch (e: LibraryException) {
            println("day $day: refused ($isbn to $member): ${e.message}")
        }
    }
    println("available: ${listOf("978-0", "978-2", "978-5").associateWith(lib::available)}")
    println("fine Ana: ${lib.giveBack("978-0", 1, 20)} cents")
    println("fine Ben: ${lib.giveBack("978-0", 2, 20)} cents")
    println(runCatching { lib.giveBack("978-0", 2, 21) }.exceptionOrNull()?.message)
    println("overdue on day 40: ${lib.overdue(40)}")
    println(runCatching { lib.lend("978-6", 1, 40) }.exceptionOrNull()?.message)
    println("fine Ana again: ${lib.giveBack("978-2", 1, 41)}")
    println("lend after return: ${lib.lend("978-6", 1, 41).due}")
    println("recommend for 978-0: ${lib.recommend("978-0")}")
    println(toJson(lib.export()))
    println(toJson(mapOf("escaped" to "quote \" backslash \\ newline \n tab\t", "empty" to emptyMap<String, Int>(), "nested" to listOf(listOf(1, 2), emptyList<Int>()))))
}
