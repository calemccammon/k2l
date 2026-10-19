package app.di

import app.di.core.Container
import app.di.core.Provider
import app.di.core.ResolutionException
import app.di.events.Delivery
import app.di.events.Event
import app.di.events.EventBus
import app.di.events.OrderPlaced
import app.di.events.Shutdown
import app.di.events.UserCreated
import app.di.events.UserDeleted
import app.di.events.deadOf
import app.di.services.Clock
import app.di.services.ConsoleLogger
import app.di.services.FakeClock
import app.di.services.Logger
import app.di.services.OrderService
import app.di.services.RequestId
import app.di.services.Session
import app.di.services.UserRepository
import app.di.services.UserService
import app.di.events.Subscription as Sub

// A small application wired by a DI container: services, an event bus with typed subscribers, child scopes.

class A(val b: B)
class B(val a: Provider<A>, val eager: Boolean) {
    init {
        if (eager) a.get()
    }
}

class Audit(bus: EventBus) {
    val entries = mutableListOf<String>()
    private val subs = mutableListOf<Sub>()

    init {
        subs += bus.on<UserCreated> { entries += "created ${it.user} via ${it.source}" }
        subs += bus.on<UserDeleted> { entries += "deleted ${it.user} (${it.reason})" }
        subs += bus.on<OrderPlaced> { e ->
            check(e.total < 1000.0) { "order ${e.orderId} too large: ${e.total}" }
            entries += "order ${e.orderId} = ${e.total}"
        }
    }

    fun stop() = subs.forEach(Sub::cancel)
}

fun describe(d: Delivery): String = when (d) {
    is Delivery.Delivered -> "delivered to ${d.handlers}"
    is Delivery.Failed -> "failed: ${d.errors.joinToString("; ")}"
    Delivery.Dropped -> "dropped"
}

fun buildContainer(): Container = Container("app").apply {
    single<Clock> { FakeClock() }
    single<Logger> { ConsoleLogger(get()) }
    single<Logger>("audit") { ConsoleLogger(get(), prefix = "audit") }
    single { EventBus() }
    single { UserRepository(get()) }
    factory { RequestId.next() }
    single { UserService(get(), get(), provider()) }
    single { OrderService(get(), get("audit")) }
    single { Audit(get()) }
}

inline fun <reified T : Any> Container.tryGet(): T? = try {
    get<T>()
} catch (e: ResolutionException) {
    println("  resolve ${T::class.simpleName} failed: ${e.message}")
    null
}

fun main() {
    val root = buildContainer()
    println("== bindings")
    root.describe().forEach { println("  $it") }

    val audit = root.get<Audit>()
    val users = root.get<UserService>()
    val orders = root.get<OrderService>()
    println("same logger: ${root.get<Logger>() === root.get<Logger>()}, audit logger differs: ${root.get<Logger>() !== root.get<Logger>("audit")}")

    println("== users")
    for (name in listOf("ada", "grace", "linus")) println("  $name -> ${users.create(name)}")
    try {
        users.create("ada")
    } catch (e: IllegalStateException) {
        println("  error: ${e.message}")
    }
    users.delete("grace", "requested")
    users.delete("linus")
    users.delete("nobody")
    println("  repo: ${root.get<UserRepository>().all()}")

    println("== orders")
    val bus = root.get<EventBus>()
    println("  ${orders.place(9.5, 20.25)}")
    println("  ${orders.place(999.0, 1.5)}")
    try {
        orders.place()
    } catch (e: IllegalArgumentException) {
        println("  error: ${e.message}")
    }
    println("  direct: ${describe(bus.publish(OrderPlaced("manual", 7, 12.0)))}")
    println("  overflow: ${describe(bus.publish(OrderPlaced("manual", 8, 4000.0)))}")
    println("  shutdown: ${describe(bus.publish(Shutdown))}")
    audit.stop()
    println("  after stop: ${describe(bus.publish(UserCreated("x", "y")))}")
    println("  dead users: ${bus.deadOf<UserCreated>()}, dead events: ${bus.deadOf<Event>().size}")
    println("  counts: ${bus.subscriberCounts()}")
    audit.entries.forEach { println("  audit: $it") }

    println("== scopes")
    root.scoped { Session("anon") }
    val req1 = root.child("request-1").apply { scoped { Session("ada") } }
    val req2 = root.child("request-2")
    val s1 = req1.get<Session>()
    println("  $s1 same=${s1 === req1.get<Session>()} ${req2.get<Session>()} ${req2.get<Session>() === req2.get<Session>()}")
    println("  request ids issued: ${RequestId.issued}, fresh: ${req1.get<RequestId>()} ${req2.get<RequestId>()}")
    req1.describe().forEach { println("  $it") }

    println("== failures")
    root.tryGet<String>()
    req2.tryGet<Map<*, *>>()
    val cyclic = Container("cyclic").apply {
        single { A(get()) }
        single { B(provider(), eager = true) }
    }
    try {
        cyclic.get<A>()
    } catch (e: ResolutionException) {
        println("  ${e.message} (${e.chain.size} links)")
    }
    val lazyOk = Container("lazy").apply {
        single { A(get()) }
        single { B(provider(), eager = false) }
    }
    val b = lazyOk.get<B>()
    println("  lazy cycle ok: ${b.a.get().b === b}")
    try {
        root.single { EventBus() }
    } catch (e: IllegalArgumentException) {
        println("  ${e.message}")
    }
    val lazyLogger = root.lazyGet<Logger>()
    println("  lazy initialized: ${lazyLogger.isInitialized()} prefix=${lazyLogger.value.prefix} ${lazyLogger.isInitialized()}")

    println("== logs")
    root.get<Logger>().lines().forEach { println("  $it") }
    root.get<Logger>("audit").lines().forEach { println("  $it") }
    println("  creations: ${root.creations()}")
    (root.history() + req1.history()).forEach { println("  $it") }
}
