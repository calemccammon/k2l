package draw.text

// A multiplatform-style file name with a dot in it (its Lua module is text/Style_common.lua).

enum class Style { PLAIN, BOLD }

var defaultStyle = Style.PLAIN

fun styled(text: String, style: Style = defaultStyle): String = if (style == Style.BOLD) "**$text**" else text
