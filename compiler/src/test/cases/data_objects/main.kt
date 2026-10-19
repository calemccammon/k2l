package app.cmds

// `data object`: generated toString() and hashCode(), in sealed hierarchies, collections and `when`.

sealed interface Cmd {
    data object Look : Cmd
    data object Quit : Cmd
    data class Say(val text: String) : Cmd
}

data object Settings {
    var verbose = false
}

data object Custom {
    override fun toString() = "custom!"
}

fun describe(c: Cmd) = when (c) {
    Cmd.Look -> "look"
    Cmd.Quit -> "quit"
    is Cmd.Say -> "say ${c.text}"
}

fun main() {
    val cmds = listOf(Cmd.Look, Cmd.Say("hi"), Cmd.Quit, Cmd.Look)
    println(cmds)
    println(cmds.map(::describe))
    println("$Settings ${Settings.verbose} $Custom")
    println(Cmd.Look.hashCode() == "app.cmds.Cmd.Look".hashCode())
    println(Cmd.Quit.hashCode())
    println(cmds.toSet().size)
    println(mapOf(Cmd.Look to 1, Cmd.Quit to 2)[Cmd.Quit])
    println(Cmd.Look == Cmd.Look && Cmd.Look != Cmd.Quit)
    println(Cmd.Look.toString().length)
}
