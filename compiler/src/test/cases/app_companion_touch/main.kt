// A companion (or object) with observable initialization is initialized when it is used as a value, also as the receiver of
// a bound reference and when the qualifier of a call is evaluated before arguments that need statements.
val log = mutableListOf<String>()

class Widget(val name: String) {
    companion object {
        init {
            log += "Widget.Companion init"
        }

        fun create(name: String) = Widget(name)
    }
}

object Registry {
    private val names = mutableListOf<String>()

    init {
        log += "Registry init"
    }

    fun add(name: String, factory: (String) -> Widget) {
        names += factory(name).name
    }

    override fun toString() = names.toString()
}

inline fun <reified T> label(): String {
    log += "label ${T::class.simpleName}"
    return "w"
}

fun main() {
    val factory = Widget::create
    log += "reference taken"
    println(factory("a").name)
    Registry.add(label<Widget>(), factory)
    println(log)
    println(Registry)
}
