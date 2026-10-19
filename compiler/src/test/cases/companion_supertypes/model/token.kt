package app.model

// a companion with supertypes in another file
class Token(val text: String) {
    companion object : Factory<Token> {
        fun parse(s: String) = "<$s>"

        override fun create() = Token("made")
    }
}
