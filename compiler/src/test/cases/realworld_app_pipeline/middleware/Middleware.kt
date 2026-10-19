package web.middleware

import web.http.Handler
import web.http.HttpException
import web.http.Middleware
import web.http.Request
import web.http.Response

/** Composes middlewares so that the first one listed is the outermost. */
fun compose(vararg layers: Middleware): Middleware = { inner -> layers.foldRight(inner) { layer, acc -> layer(acc) } }

infix fun Middleware.then(next: Middleware): Middleware = { h -> this(next(h)) }

/** Applies the middleware to a handler: `logging(log) wrap handler`. */
infix fun Middleware.wrap(handler: Handler): Handler = this(handler)

fun logging(log: MutableList<String>, tag: String = "log"): Middleware = { next ->
    Handler { req ->
        log += "$tag> ${req.method} ${req.path}"
        val res = next.handle(req)
        log += "$tag< ${res.status}"
        res
    }
}

/** Rejects requests without the right token. */
fun auth(token: String, publicPrefixes: Set<String> = setOf("/health")): Middleware = { next ->
    Handler { req ->
        when {
            publicPrefixes.any { req.path.startsWith(it) } -> next.handle(req)
            req.header("Authorization") == "Bearer $token" -> next.handle(req.withHeader("X-User", "admin"))
            else -> Response.error(401, "unauthorized")
        }
    }
}

/** Turns exceptions into error responses. */
val errors: Middleware = { next ->
    Handler { req ->
        try {
            next.handle(req)
        } catch (e: HttpException) {
            Response.error(e.status, e.message ?: "error")
        } catch (e: NumberFormatException) {
            Response.error(400, "bad number: ${e.message}")
        } catch (e: RuntimeException) {
            Response.error(500, "${e::class.simpleName}: ${e.message}")
        }
    }
}

/** Counts requests per path; the counter is shared state captured by the returned function. */
fun counting(): Pair<Middleware, () -> Map<String, Int>> {
    val counts = sortedMapOf<String, Int>()
    val middleware: Middleware = { next ->
        Handler { req ->
            counts[req.path] = (counts[req.path] ?: 0) + 1
            next.handle(req)
        }
    }
    return middleware to { counts.toMap() }
}

/** Caches GET responses by path; returns hit/miss counts through a lambda with a receiver. */
class Cache(private val capacity: Int) {
    private val entries = LinkedHashMap<String, Response>()
    var hits = 0
        private set
    var misses = 0
        private set

    val middleware: Middleware = { next ->
        Handler { req ->
            if (req.method.name != "GET") return@Handler next.handle(req)
            entries[req.path]?.let {
                hits++
                return@Handler it.copy(headers = it.headers + ("X-Cache" to "hit"))
            }
            misses++
            next.handle(req).also { res ->
                if (res.ok) {
                    entries[req.path] = res
                    if (entries.size > capacity) entries.remove(entries.keys.first())
                }
            }
        }
    }

    fun <R> stats(block: Cache.(Int) -> R): R = block(entries.size)
}

/** Adds a response header computed from the request; shows a function type with a receiver as a parameter. */
fun header(name: String, value: Request.() -> String): Middleware = { next ->
    Handler { req ->
        val res = next.handle(req)
        res.copy(headers = res.headers + (name to req.value()))
    }
}
