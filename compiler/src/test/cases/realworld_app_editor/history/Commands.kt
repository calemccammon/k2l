package editor.history

import editor.text.Editable
import editor.text.Pos
import editor.text.Selection

/** A reversible edit. */
sealed interface Command {
    val label: String
    fun apply(doc: Editable): Pos
    fun revert(doc: Editable): Pos

    /** Two consecutive commands may merge into one undo step (typing a word). */
    fun mergeWith(next: Command): Command? = null
}

data class Insert(val at: Pos, val text: String) : Command {
    override val label get() = "insert '${text.replace("\n", "\\n")}' at $at"
    override fun apply(doc: Editable) = doc.insert(at, text)
    override fun revert(doc: Editable): Pos {
        doc.delete(Selection(at, doc.endOf(at, text)))
        return at
    }

    override fun mergeWith(next: Command): Command? = when {
        next is Insert && '\n' !in text && '\n' !in next.text && next.at == Pos(at.line, at.col + text.length) && next.text != " " ->
            Insert(at, text + next.text)
        else -> null
    }
}

class Delete(private val selection: Selection) : Command {
    private var removed: String? = null
    override val label get() = "delete ${selection.start}..${selection.end}" + (removed?.let { " ('$it')" } ?: "")
    override fun apply(doc: Editable): Pos {
        removed = doc.delete(selection)
        return selection.start
    }

    override fun revert(doc: Editable): Pos = doc.insert(selection.start, removed ?: error("not applied: $label"))
}

/** Several commands as one step, reverted in reverse order. */
class Batch(override val label: String, private val parts: List<Command>) : Command {
    override fun apply(doc: Editable): Pos = parts.fold(Pos(0, 0)) { _, c -> c.apply(doc) }
    override fun revert(doc: Editable): Pos = parts.asReversed().fold(Pos(0, 0)) { _, c -> c.revert(doc) }
}

object Noop : Command {
    override val label = "noop"
    override fun apply(doc: Editable) = Pos(0, 0)
    override fun revert(doc: Editable) = Pos(0, 0)
}

/** A bounded stack used for both undo and redo. */
class BoundedStack<T>(private val limit: Int) : Iterable<T> {
    private val items = ArrayDeque<T>()
    val size get() = items.size
    fun push(item: T): T? {
        items.addLast(item)
        return if (items.size > limit) items.removeFirst() else null
    }
    fun pop(): T? = items.removeLastOrNull()
    fun peek(): T? = items.lastOrNull()
    fun replaceTop(item: T) {
        items[items.lastIndex] = item
    }
    fun clear() = items.clear()
    override fun iterator(): Iterator<T> = items.asReversed().iterator()
}

class History(private val doc: Editable, limit: Int = 50) {
    private val undo = BoundedStack<Command>(limit)
    private val redo = BoundedStack<Command>(limit)
    var cursor = Pos(0, 0)
        private set
    private val listeners = mutableListOf<(String) -> Unit>()

    fun onChange(listener: (String) -> Unit) {
        listeners += listener
    }

    private fun notify(event: String) = listeners.forEach { it(event) }

    fun execute(command: Command, merge: Boolean = true) {
        cursor = command.apply(doc)
        val top = undo.peek()
        val merged = if (merge && top != null) top.mergeWith(command) else null
        if (merged != null) {
            undo.replaceTop(merged)
        } else {
            undo.push(command)?.let { notify("forgot ${it.label}") }
        }
        redo.clear()
        notify("did ${command.label}")
    }

    fun undo(): Boolean {
        val c = undo.pop() ?: return false
        cursor = c.revert(doc)
        redo.push(c)
        notify("undid ${c.label}")
        return true
    }

    fun redo(): Boolean {
        val c = redo.pop() ?: return false
        cursor = c.apply(doc)
        undo.push(c)
        notify("redid ${c.label}")
        return true
    }

    val undoLabels get() = undo.map { it.label }
    val redoLabels get() = redo.map { it.label }
}
