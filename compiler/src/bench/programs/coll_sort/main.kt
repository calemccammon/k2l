import java.util.TreeMap

// Adapted from realworld_library and realworld_warehouse: sorting records with comparator chains, natural-order sorts
// of strings and numbers, in-place sortWith, binary search, a TreeMap index and top-N queries.

const val SIZE = 30_000 // books

data class Book(val title: String, val author: String, val year: Int, val rating: Double, val pages: Int)

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

val SYLLABLES = listOf("an", "bel", "cor", "dra", "el", "fin", "gor", "hal", "is", "jun", "ka", "lor", "mi", "nor", "ol", "pra")

fun word(rng: Lcg, parts: Int) = (0 until parts).joinToString("") { SYLLABLES[rng.next(SYLLABLES.size)] }

fun main() {
    val rng = Lcg(99)
    val authors = List(300) { word(rng, 2).replaceFirstChar { it.uppercase() } + " " + word(rng, 3).replaceFirstChar { it.uppercase() } }
    val books = List(SIZE) {
        Book(word(rng, 3), authors[rng.next(authors.size)], 1900 + rng.next(124), rng.next(50) / 10.0, 50 + rng.next(900))
    }
    var checksum = 0L
    val byAuthor = books.sortedWith(compareBy<Book> { it.author }.thenByDescending { it.year }.thenBy { it.title })
    checksum += byAuthor.take(50).sumOf { it.year }
    println("first: ${byAuthor.first().author} ${byAuthor.first().year}; last: ${byAuthor.last().author}")

    val byRating = books.sortedWith(compareByDescending<Book> { it.rating }.thenBy { it.pages }.thenBy { it.title })
    checksum += byRating.take(100).sumOf { it.pages }
    val titles = books.map { it.title }.sorted()
    val years = books.map { it.year }.sortedDescending()
    checksum += titles.binarySearch(titles[titles.size / 3]) + years[years.size / 2]
    println("median year ${years[years.size / 2]}, title range ${titles.first()}..${titles.last()}")

    val shelf = books.toMutableList()
    repeat(4) { round ->
        when (round % 4) {
            0 -> shelf.sortBy { it.pages }
            1 -> shelf.sortWith(compareBy({ it.year }, { it.author }, { it.title }))
            2 -> shelf.sortByDescending { it.rating * 1000 + it.pages }
            else -> shelf.sortWith { a, b -> a.title.length - b.title.length }
        }
        checksum += shelf[shelf.size / 2].pages + shelf.first().year
    }
    val index = TreeMap<String, MutableList<Book>>()
    for (b in books) index.getOrPut(b.author) { mutableListOf() }.add(b)
    val prolific = index.entries.sortedWith(compareByDescending<Map.Entry<String, MutableList<Book>>> { it.value.size }.thenBy { it.key })
        .take(5).map { "${it.key}:${it.value.size}" }
    println("prolific: $prolific")
    val newest = index.values.map { list -> list.maxBy { it.year } }.sortedBy { it.year }.distinctBy { it.year }
    checksum += newest.size + index.firstKey().length + index.lastKey().length
    for (decade in 1900..2020 step 10) {
        val inDecade = books.filter { it.year / 10 * 10 == decade }
        val best = inDecade.sortedWith(compareBy<Book>({ -it.rating }, { it.title })).take(3)
        checksum += best.sumOf { it.pages } + inDecade.size
    }
    println("checksum $checksum")
}
