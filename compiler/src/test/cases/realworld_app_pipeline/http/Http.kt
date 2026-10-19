package web.http

enum class Method { GET, POST, PUT, DELETE }

data class Request(
    val method: Method,
    val path: String,
    val headers: Map<String, String> = emptyMap(),
    val body: String = "",
) {
    val segments: List<String> by lazy { path.trim('/').split('/').filter { it.isNotEmpty() } }

    fun header(name: String): String? = headers.entries.firstOrNull { it.key.equals(name, ignoreCase = true) }?.value

    fun withHeader(name: String, value: String) = copy(headers = headers + (name to value))
}

data class Response(val status: Int, val body: String, val headers: Map<String, String> = emptyMap()) {
    val ok get() = status in 200..299

    companion object {
        fun ok(body: String) = Response(200, body)
        fun notFound(path: String) = Response(404, "no route for $path")
        fun error(status: Int, message: String) = Response(status, message)
    }
}

/** A handler turns a request into a response. */
fun interface Handler {
    fun handle(request: Request): Response
}

/** A middleware wraps a handler into another handler. */
typealias Middleware = (Handler) -> Handler

class HttpException(val status: Int, message: String) : RuntimeException(message)

/** Route parameters captured by a pattern like `/users/{id}`. */
class Params internal constructor(private val values: Map<String, String>) {
    operator fun get(name: String): String = values[name] ?: throw HttpException(400, "missing parameter $name")
    fun int(name: String): Int = get(name).toIntOrNull() ?: throw HttpException(400, "parameter $name is not a number: ${get(name)}")
    override fun toString() = values.toString()
}

internal fun match(pattern: String, path: List<String>): Params? {
    val parts = pattern.trim('/').split('/').filter { it.isNotEmpty() }
    if (parts.size != path.size) return null
    val values = mutableMapOf<String, String>()
    for ((p, s) in parts.zip(path)) {
        when {
            p.startsWith("{") && p.endsWith("}") -> values[p.substring(1, p.length - 1)] = s
            p != s -> return null
        }
    }
    return Params(values)
}
