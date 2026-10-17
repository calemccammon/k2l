// Enums whose constructors are all secondary.
enum class Color {
    RED("r"),
    GREEN("g", 2),
    BLUE;

    val code: String
    var weight = 1

    constructor() { this.code = "none" }
    constructor(code: String) { this.code = code }
    constructor(code: String, weight: Int) : this(code) { this.weight = weight }

    fun describe() = "$name#$ordinal $code x$weight"
}

fun main() {
    for (c in Color.values()) println(c.describe())
    println(Color.valueOf("GREEN").ordinal)
    println(Color.BLUE)
    println(Color.RED == Color.valueOf("RED"))
}
