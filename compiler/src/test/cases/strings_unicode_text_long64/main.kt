// Unicode digits in Long and ULong parsing with exact 64-bit arithmetic
fun main() {
    println("١٢٣".toLong())
    println("-٩٩٩٩٩٩٩٩٩٩٩٩٩٩٩".toLong())
    println("９２２３３７２０３６８５４７７５８０７".toLong())
    println("９２２３３７２０３６８５４７７５８０８".toLongOrNull())
    println("-９２２３３７２０３６８５４７７５８０８".toLong())
    println("１８４４６７４４０７３７０９５５１６１５".toULong())
    println("１８４４６７４４０７３７０９５５１６１６".toULongOrNull())
    println("ｆｆｆｆｆｆｆｆｆｆｆｆｆｆｆｆ".toULong(16))
    println("ＦＦ".toLong(16))
    println(java.lang.Long.parseLong("٧٧٧"))
    println("١x".toLongOrNull())
    println(java.lang.Long.valueOf("-٤"))
}
