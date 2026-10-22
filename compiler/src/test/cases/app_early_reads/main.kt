// Code that runs earlier during construction (an initializer calling a method, a superclass constructor calling an
// override) reads 0, false or null from properties whose initializers have not run yet.
class Early {
    val x = compute()
    val y = 5
    val name: String = describe()
    val label = "L"
    val flag = check()
    val ready = true
    val ratio = half()
    val scale = 2.0
    val items: List<Int>? = peek()
    val list = listOf(1)

    fun compute() = y + 1
    fun describe() = "label=$label"
    fun check() = !ready
    fun half() = scale / 2
    fun peek() = list
}

open class Widget(val id: Int) {
    val log = mutableListOf<String>()

    init {
        log += render()
    }

    open fun render() = "widget $id"
}

class Button(id: Int) : Widget(id) {
    private val caption = "OK"
    private var clicks = 3

    override fun render() = "button $id [$caption] clicks=$clicks"
}

object Settings {
    val summary = summarize()
    val retries = 3
    val verbose = true

    private fun summarize() = "retries=$retries verbose=$verbose"
}

fun main() {
    val e = Early()
    println("${e.x} ${e.y} ${e.name} ${e.flag} ${e.ratio} ${e.items} ${e.list}")
    val b = Button(7)
    println("${b.log} ${b.render()}")
    println("${Settings.summary} ${Settings.retries}")
}
