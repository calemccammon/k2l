package app

import ui.*

fun main() {
    Dispatch.OnMouseWheel(0, 0, 10)
    for (t in listOf(Heart, Alarm("late"), ticker { false })) {
        t.start()
        println(t.status())
    }
    val update = Interface::Update
    update(1.0)
    val label = Clock::label
    println(label(Alarm("ref")))
    println(Book.pages)
}
