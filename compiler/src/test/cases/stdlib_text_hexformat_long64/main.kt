// HexFormat: the predefined formats, the builder, and formatting/parsing numbers and byte arrays with a format
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    val data = byteArrayOf(0, 1, 15, 16, 127, -128, -1, 42, 7, 100)
    t("default") { listOf(255.toHexString(HexFormat.Default), data.toHexString(HexFormat.Default)) }
    t("upper") { listOf(255.toHexString(HexFormat.UpperCase), data.toHexString(HexFormat.UpperCase), HexFormat.UpperCase.upperCase) }

    val spaced = HexFormat {
        upperCase = true
        bytes {
            byteSeparator = " "
            bytesPerLine = 4
        }
    }
    t("spaced") { data.toHexString(spaced) }
    t("spaced props") { listOf(spaced.upperCase, spaced.bytes.byteSeparator, spaced.bytes.bytesPerLine, spaced.bytes.bytesPerGroup) }

    val grouped = HexFormat {
        bytes.bytesPerGroup = 2
        bytes.groupSeparator = " | "
        bytes.bytePrefix = "0x"
        bytes.byteSuffix = ","
    }
    t("grouped") { data.toHexString(grouped) }
    t("grouped parse") { "0x00,0x01, | 0x0f,0x10,".hexToByteArray(grouped).toList() }
    t("spaced parse") { "00 01 0F 10\n7F 80".hexToByteArray(spaced).toList() }
    t("range") { data.toHexString(2, 5, spaced) }

    val numeric = HexFormat {
        number {
            prefix = "0x"
            suffix = "h"
            removeLeadingZeros = true
        }
    }
    t("number") { listOf(255.toHexString(numeric), 0.toHexString(numeric), (-1L).toHexString(numeric), 10.toByte().toHexString(numeric)) }
    t("number props") { listOf(numeric.number.prefix, numeric.number.suffix, numeric.number.removeLeadingZeros, numeric.number.minLength) }
    t("number parse") { listOf("0xffh".hexToInt(numeric), "0x1h".hexToLong(numeric), "0x7fh".hexToByte(numeric)) }
    t("number parse bad") { "ff".hexToInt(numeric) }
    val padded = HexFormat { number.minLength = 6 }
    t("minLength") { listOf(255.toHexString(padded), 0x1234567.toHexString(padded), 5.toShort().toHexString(padded)) }
    t("upper number") { listOf(0xabcdef.toHexString(HexFormat { upperCase = true; number.removeLeadingZeros = true })) }
}
