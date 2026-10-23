package ui

object Status {
    private var shown = 0
    private val labels = mutableListOf<String>()

    private fun format(name: String) = "[$name]"

    fun Show(name: String) {
        shown++
        labels += format(name)
    }

    fun Summary() = "$shown: ${labels.joinToString()}"
}

class Window(val title: String) {
    private var opened = false

    private fun mark(state: Boolean) {
        opened = state
    }

    fun Open() {
        mark(true)
    }

    fun IsOpen() = opened

    fun Describe() = describe(this)

    private fun describe(w: Window) = w.title + if (w.opened) " (open)" else ""

    companion object {
        private val prefix = "win:"

        fun Make(name: String) = Window(prefix + name)
    }
}

data class Slot(val id: Int, val item: String = "empty", val note: String? = "none")

fun main() {
    Status.Show("hp")
    Status.Show("mana")
    println(Status.Summary())
    val w = Window.Make("bag")
    w.Open()
    println(w.IsOpen())
    println(w.Describe())
    val open = w::Open
    open()
    println(Slot(1))
    println(Slot(2, note = null))
    println(Slot(3, "sword").copy(note = null) == Slot(3, "sword", null))
}
