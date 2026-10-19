import java.util.PriorityQueue
import kotlin.random.Random

// A discrete-event simulation of a bank with tellers, plus a cellular automaton and an
// elevator state machine. Randomness comes from a seeded generator, so runs are reproducible.

sealed class SimEvent(val time: Int) : Comparable<SimEvent> {
    abstract val priority: Int
    override fun compareTo(other: SimEvent): Int = compareValuesBy(this, other, { it.time }, { it.priority })

    class Arrival(time: Int, val customer: Customer) : SimEvent(time) {
        override val priority = 1
    }

    class Departure(time: Int, val teller: Int, val customer: Customer) : SimEvent(time) {
        override val priority = 0
    }
}

data class Customer(val id: Int, val arrival: Int, val serviceTime: Int, val vip: Boolean)

class BankStats {
    var served = 0
    var totalWait = 0L
    var maxWait = 0
    var maxQueue = 0
    val waits = mutableListOf<Int>()

    fun record(wait: Int) {
        served++
        totalWait += wait
        maxWait = maxOf(maxWait, wait)
        waits += wait
    }

    val averageWait get() = if (served == 0) 0.0 else totalWait.toDouble() / served
}

class Bank(private val tellers: Int, private val log: Boolean = false) {
    private val events = PriorityQueue<SimEvent>()
    private val queue = ArrayDeque<Customer>()
    private val busy = BooleanArray(tellers)
    private val busyTime = IntArray(tellers)
    val stats = BankStats()
    var clock = 0
        private set

    fun schedule(e: SimEvent) {
        events.add(e)
    }

    private fun startService(teller: Int, c: Customer) {
        busy[teller] = true
        busyTime[teller] += c.serviceTime
        stats.record(clock - c.arrival)
        schedule(SimEvent.Departure(clock + c.serviceTime, teller, c))
        if (log) println("  t=$clock teller $teller serves #${c.id} (waited ${clock - c.arrival})")
    }

    fun run(): Bank = apply {
        while (events.isNotEmpty()) {
            val e = events.poll()
            clock = e.time
            when (e) {
                is SimEvent.Arrival -> {
                    val free = busy.indexOfFirst { !it }
                    if (free >= 0) {
                        startService(free, e.customer)
                    } else {
                        if (e.customer.vip) queue.addFirst(e.customer) else queue.addLast(e.customer)
                        stats.maxQueue = maxOf(stats.maxQueue, queue.size)
                    }
                }
                is SimEvent.Departure -> {
                    busy[e.teller] = false
                    queue.removeFirstOrNull()?.let { startService(e.teller, it) }
                }
            }
        }
    }

    fun utilisation(): List<String> = busyTime.map { "%.0f%%".format(100.0 * it / clock) }
}

fun customers(n: Int, seed: Int): List<Customer> {
    val rnd = Random(seed)
    var t = 0
    return List(n) { id ->
        t += rnd.nextInt(1, 6)
        Customer(id + 1, t, rnd.nextInt(2, 12), rnd.nextInt(10) == 0)
    }
}

// Conway's game of life on a small torus.
class Life(private val w: Int, private val h: Int, alive: Set<Pair<Int, Int>>) {
    private var cells = Array(h) { y -> BooleanArray(w) { x -> (x to y) in alive } }
    var generation = 0
        private set

    val population get() = cells.sumOf { row -> row.count { it } }

    private fun neighbours(x: Int, y: Int) = (-1..1).sumOf { dy ->
        (-1..1).count { dx -> (dx != 0 || dy != 0) && cells[(y + dy).mod(h)][(x + dx).mod(w)] }
    }

    fun step() {
        cells = Array(h) { y ->
            BooleanArray(w) { x ->
                val n = neighbours(x, y)
                n == 3 || (n == 2 && cells[y][x])
            }
        }
        generation++
    }

    override fun toString() = cells.joinToString("\n") { row -> row.joinToString("") { if (it) "#" else "." } }
}

enum class Motion { IDLE, UP, DOWN, DOORS_OPEN }

class Elevator(private val floors: IntRange) {
    var floor = floors.first
        private set
    var motion = Motion.IDLE
        private set
    private val requests = sortedSetOf<Int>()
    val trace = mutableListOf<String>()

    fun call(f: Int) {
        require(f in floors) { "floor $f out of range $floors" }
        requests += f
    }

    fun tick() {
        motion = when {
            floor in requests -> {
                requests -= floor
                Motion.DOORS_OPEN
            }
            requests.isEmpty() -> Motion.IDLE
            motion == Motion.UP && requests.any { it > floor } -> Motion.UP
            motion == Motion.DOWN && requests.any { it < floor } -> Motion.DOWN
            requests.first() > floor || requests.last() > floor && floor - requests.first() > requests.last() - floor -> Motion.UP
            else -> Motion.DOWN
        }
        when (motion) {
            Motion.UP -> floor++
            Motion.DOWN -> floor--
            else -> {}
        }
        trace += "${motion.name.first()}$floor"
    }
}

fun main() {
    val people = customers(40, seed = 2024)
    println("first customers: ${people.take(3)}")
    println("vips: ${people.filter { it.vip }.map { it.id }}")
    for (tellers in 1..3) {
        val bank = Bank(tellers)
        people.forEach { bank.schedule(SimEvent.Arrival(it.arrival, it)) }
        bank.run()
        val s = bank.stats
        val p90 = s.waits.sorted()[(s.waits.size * 9) / 10]
        println(
            "tellers=$tellers served=${s.served} avgWait=${"%.2f".format(s.averageWait)} maxWait=${s.maxWait} " +
                "p90=$p90 maxQueue=${s.maxQueue} end=${bank.clock} util=${bank.utilisation()}",
        )
    }
    val small = Bank(2, log = true)
    customers(6, seed = 7).forEach { small.schedule(SimEvent.Arrival(it.arrival, it)) }
    small.run()

    val rnd = Random(99)
    println("dice: ${List(10) { rnd.nextInt(1, 7) }} coin: ${List(8) { if (rnd.nextBoolean()) 'H' else 'T' }.joinToString("")}")
    val shuffled = (1..10).shuffled(Random(5))
    println("shuffled: $shuffled sorted back: ${shuffled.sorted() == (1..10).toList()}")
    val histogram = IntArray(6)
    repeat(600) { histogram[Random(it).nextInt(6)]++ }
    println("histogram total=${histogram.sum()} min>50=${histogram.all { it > 50 }}")

    val glider = setOf(1 to 0, 2 to 1, 0 to 2, 1 to 2, 2 to 2)
    val life = Life(8, 6, glider)
    println("gen ${life.generation}, population ${life.population}\n$life")
    repeat(4) { life.step() }
    println("gen ${life.generation}, population ${life.population}\n$life")
    val blinker = Life(5, 5, setOf(1 to 2, 2 to 2, 3 to 2))
    val history = generateSequence { blinker.step(); blinker.toString() }.take(4).toList()
    println("blinker period 2: ${history[0] == history[2] && history[1] == history[3] && history[0] != history[1]}")

    val elevator = Elevator(0..9)
    elevator.call(5)
    elevator.call(2)
    repeat(4) { elevator.tick() }
    elevator.call(8)
    elevator.call(1)
    repeat(16) { elevator.tick() }
    println("elevator: ${elevator.trace.joinToString(" ")}")
    println("ended at ${elevator.floor} ${elevator.motion}")
    try {
        elevator.call(12)
    } catch (e: IllegalArgumentException) {
        println("rejected: ${e.message}")
    }
    val counts = elevator.trace.groupingBy { it.first() }.eachCount()
    println("motion counts: ${Motion.entries.associate { m -> m to (counts[m.name.first()] ?: 0) }}")
}
