package app.model

interface Factory<T> {
    fun create(): T

    fun twice(): List<T> = listOf(create(), create())

    val kind: String get() = "factory"
}
