// An explicit null for a parameter whose default is not null: Lua's nil would select the default, so the call passes a
// marker that the function turns back into null.

data class Tag(val name: String? = "untitled", val weight: Int = 1)

class Box(val value: Int? = 5) {
    constructor(text: String, extra: String? = "extra") : this(text.length) {
        println("secondary $text $extra")
    }
}

fun greet(name: String? = "world"): String = "hello $name"

fun String.suffixed(suffix: String? = "!"): String = this + suffix

fun <T> orElse(value: T, fallback: T = value): T = fallback

open class Base {
    open fun label(text: String? = "base"): String = "label $text"
}

class Derived : Base() {
    override fun label(text: String?): String = "derived $text"
}

inline fun shout(text: String? = "hey"): String = "$text!"

fun twice(first: String? = "a", second: String? = "b") = "$first $second"

// expanded in place (its lambda returns from firstSeen): the expansion binds the null itself
inline fun visit(text: String? = "default", block: (String?) -> Unit) = block(text)

fun firstSeen(value: String?): String {
    visit(value) { return "seen $it" }
    return "unseen"
}

fun main() {
    val tag = Tag("kotlin", 2)
    println(tag.copy(name = null))
    val none: String? = null
    val some: String? = "lua"
    println(tag.copy(name = none))
    println(tag.copy(name = some))
    println(tag.copy(weight = 3))
    println(Tag(name = null))
    println(Tag())
    println(Box(null).value)
    println(Box().value)
    println(Box("four", null).value)
    println(Box("six").value)
    println(greet(null))
    println(greet(none))
    println(greet(some))
    println(greet())
    println("x".suffixed(null))
    println("x".suffixed())
    println(orElse<String?>("a", null))
    println(orElse("a"))
    val base: Base = Derived()
    println(base.label(null))
    println(base.label())
    println(Base().label(null))
    println(shout(null))
    println(shout())
    println(twice(second = null))
    println(twice(null, none))
    println(listOf<String?>("p", null).map { greet(it) })
    println(firstSeen(null))
    println(firstSeen("v"))
}
