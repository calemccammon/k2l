package editor

import editor.history.Batch
import editor.history.Command
import editor.history.Delete
import editor.history.History
import editor.history.Insert
import editor.history.Noop
import editor.text.Editable
import editor.text.Pos
import editor.text.Selection

// A text editor core: a document, reversible commands with merging, bounded undo/redo and macros.

class Macro(val name: String) {
    private val steps = mutableListOf<(Pos) -> Command>()

    fun record(step: (Pos) -> Command) = apply { steps += step }

    fun play(history: History, times: Int = 1) {
        repeat(times) {
            val commands = steps.map { it(history.cursor) }
            history.execute(Batch("macro $name", commands), merge = false)
        }
    }
}

fun describe(c: Command): String = when (c) {
    is Insert -> "Insert(${c.text.length} chars)"
    is Delete -> "Delete"
    is Batch -> "Batch"
    Noop -> "Noop"
}

fun Editable.show(title: String) {
    println("-- $title (rev $revision, $lineCount lines)")
    println(this)
}

fun main() {
    val doc = Editable("hello world\nsecond line")
    val events = mutableListOf<String>()
    val history = History(doc, limit = 4)
    history.onChange { events += it }
    history.onChange { if (it.startsWith("forgot")) println("  ! $it") }

    doc.show("start")
    history.execute(Insert(Pos(0, 5), ","))
    history.execute(Insert(Pos(0, 12), "!"))
    "abc".forEachIndexed { i, ch -> history.execute(Insert(Pos(1, 11 + i), ch.toString())) }
    history.execute(Insert(Pos(1, 14), " "))
    history.execute(Insert(Pos(1, 15), "x"))
    doc.show("typed")
    println("undo: ${history.undoLabels}")

    history.execute(Delete(Selection(Pos(0, 13), Pos(1, 6))))
    doc.show("joined")
    println("cursor ${history.cursor}, undo: ${history.undoLabels}")

    while (history.undo()) {
        println("  undo -> ${doc.text.replace("\n", "|")} @${history.cursor}")
    }
    println("redo: ${history.redoLabels}")
    history.redo()
    history.redo()
    doc.show("redone twice")

    history.execute(Insert(Pos(2, 0), "\nthird\nfourth"))
    doc.show("multi-line insert")
    val macro = Macro("bullet")
        .record { Insert(Pos(it.line, 0), "* ") }
        .record { p -> Insert(Pos(p.line, p.col + 2), ";") }
    macro.play(history, times = 2)
    doc.show("macro")
    history.undo()
    doc.show("macro undone once")
    history.execute(Noop)
    println("after noop redo: ${history.redoLabels}, undo: ${history.undoLabels}")
    println("events: ${events.size}")
    events.takeLast(5).forEach { println("  $it") }

    val sel = Selection(Pos(3, 4), Pos(1, 2))
    println("selection ${sel.start}..${sel.end} empty=${sel.isEmpty} ${Selection(Pos(1, 1), Pos(1, 1)).isEmpty}")
    println("extract: '${doc.extract(doc.clamp(sel.start), doc.clamp(sel.end)).replace("\n", "|")}'")
    println("clamp: ${doc.clamp(Pos(99, 99))} ${doc.clamp(Pos(-3, 2))}")
    println(listOf(Insert(Pos(0, 0), "x"), Delete(sel), Batch("b", emptyList()), Noop).map(::describe))
    println(Insert(Pos(1, 1), "ab") == Insert(Pos(1, 1), "ab"))
    try {
        Delete(sel).revert(doc)
    } catch (e: IllegalStateException) {
        println("error: ${e.message}")
    }
    println(listOf(Pos(2, 1), Pos(0, 9), Pos(2, 0)).sorted())
}
