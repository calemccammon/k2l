package web

import web.http.Handler
import web.http.HttpException
import web.http.Method
import web.http.Params
import web.http.Request
import web.http.Response
import web.http.match
import web.middleware.Cache
import web.middleware.auth
import web.middleware.compose
import web.middleware.counting
import web.middleware.errors
import web.middleware.header
import web.middleware.logging
import web.middleware.then
import web.middleware.wrap
import web.http.Method.GET as Get

// A tiny web framework: routes with parameters, a middleware chain built from higher-order functions.

class Router {
    private class Route(val method: Method, val pattern: String, val action: (Request, Params) -> Response)

    private val routes = mutableListOf<Route>()

    fun get(pattern: String, action: (Request, Params) -> Response) = add(Get, pattern, action)
    fun post(pattern: String, action: (Request, Params) -> Response) = add(Method.POST, pattern, action)

    private fun add(method: Method, pattern: String, action: (Request, Params) -> Response) {
        routes += Route(method, pattern, action)
    }

    val handler = Handler { req ->
        for (route in routes) {
            if (route.method != req.method) continue
            val params = match(route.pattern, req.segments) ?: continue
            return@Handler route.action(req, params)
        }
        Response.notFound(req.path)
    }
}

class UserStore {
    private val users = mutableMapOf(1 to "ada", 2 to "grace")
    private var nextId = 3

    fun find(id: Int) = users[id] ?: throw HttpException(404, "user $id not found")

    fun add(name: String): Int {
        if (name.isBlank()) throw IllegalArgumentException("empty name")
        users[nextId] = name
        return nextId++
    }

    fun list() = users.values.sorted()
}

fun routes(store: UserStore): Router = Router().apply {
    get("/health") { _, _ -> Response.ok("up") }
    get("/users") { _, _ -> Response.ok(store.list().joinToString()) }
    get("/users/{id}") { _, p -> Response.ok(store.find(p.int("id"))) }
    get("/users/{id}/greeting/{lang}") { _, p ->
        val name = store.find(p.int("id"))
        val greeting = when (p["lang"]) {
            "en" -> "Hello"
            "fr" -> "Bonjour"
            "de" -> "Hallo"
            else -> throw HttpException(400, "unknown language ${p["lang"]}")
        }
        Response.ok("$greeting, $name!")
    }
    post("/users") { req, _ -> Response(201, "created ${store.add(req.body)}") }
    get("/crash/{n}") { _, p -> Response.ok("${100 / p["n"].toInt()}") }
}

/** Builds a function from smaller ones: currying and composition, the way handlers get configured. */
fun <A, B, C> ((A) -> B).andThen(g: (B) -> C): (A) -> C = { a -> g(this(a)) }

fun <A, B, C> curry(f: (A, B) -> C): (A) -> (B) -> C = { a -> { b -> f(a, b) } }

fun main() {
    val log = mutableListOf<String>()
    val (counter, counts) = counting()
    val cache = Cache(capacity = 2)
    val store = UserStore()
    val chain = compose(logging(log), errors, counter, auth("s3cret")) then cache.middleware then
        header("X-Path") { "$method:${segments.size}" }
    val app = chain wrap routes(store).handler

    val token = mapOf("Authorization" to "Bearer s3cret")
    val requests = listOf(
        Request(Get, "/health"),
        Request(Get, "/users"),
        Request(Get, "/users", token),
        Request(Get, "/users/1", token),
        Request(Get, "/users/1", token),
        Request(Get, "/users/9", token),
        Request(Get, "/users/x", token),
        Request(Get, "/users/2/greeting/fr", token),
        Request(Get, "/users/2/greeting/es", token),
        Request(Method.POST, "/users", token, "linus"),
        Request(Method.POST, "/users", token, " "),
        Request(Get, "/users", token),
        Request(Get, "/crash/0", token),
        Request(Get, "/crash/zero", token),
        Request(Method.DELETE, "/users/1", token),
    )
    for (r in requests) {
        val res = app.handle(r)
        val extra = res.headers.entries.joinToString(" ") { "${it.key}=${it.value}" }
        println("${r.method} ${r.path} -> ${res.status} ${res.body}" + if (extra.isEmpty()) "" else " [$extra]")
    }
    println("log: ${log.take(6)} ... ${log.size} lines")
    println("counts: ${counts()}")
    println(cache.stats { size -> "cache hits=$hits misses=$misses size=$size" })

    val parse: (String) -> Int = String::toInt
    val double = parse.andThen { it * 2 }.andThen(Int::toString).andThen { "<$it>" }
    println(double("21"))
    val add = curry { a: Int, b: Int -> a + b }
    val add10 = add(10)
    println("${add10(5)} ${add(1)(2)} ${listOf(1, 2, 3).map(add10)}")
    val twice = { f: (Int) -> Int -> { x: Int -> f(f(x)) } }
    println(twice(add10)(0))
    val requestsByMethod = requests.groupingBy { it.method }.eachCount()
    println(requestsByMethod)
}
