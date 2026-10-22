// A `return`, `break` or `continue` out of a lambda passed to each inline library function whose lambda stays a Lua function
// (the lualib implements the function): every call returns "R" or jumps when `f` is true.

fun show(v: Any?): String = when (v) {
    is Array<*> -> v.contentToString() // an IntArray too: all arrays are one Lua class
    else -> "$v"
}

object Returns1 {
    fun t_list_zipWithNext(f: Boolean): Any? {
        val v = listOf(1, 2, 3).zipWithNext { a, b -> if (f) return "R"; a + b }
        return "ok " + show(v)
    }

    fun t_seq_all(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).all { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_any(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).any { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_count(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).count { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_find(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).find { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_first(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).first { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_firstOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).firstOrNull { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_forEachIndexed(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).forEachIndexed { _, _ -> if (f) return "R" }
        return "ok " + show(v)
    }

    fun t_seq_last(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).last { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_lastOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).lastOrNull { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_none(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).none { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_associateBy(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).associateBy { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_associate(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).associate { if (f) return "R"; it to it }
        return "ok " + show(v)
    }

    fun t_seq_associateWith(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).associateWith { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_findLast(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).findLast { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_fold(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).fold(0) { a, x -> if (f) return "R"; a + x }
        return "ok " + show(v)
    }

    fun t_seq_foldIndexed(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).foldIndexed(0) { _, a, x -> if (f) return "R"; a + x }
        return "ok " + show(v)
    }

    fun t_seq_groupBy(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).groupBy { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_indexOfFirst(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).indexOfFirst { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_maxBy(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).maxBy { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_maxByOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).maxByOrNull { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_maxOf(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).maxOf { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_maxOfOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).maxOfOrNull { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_minBy(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).minBy { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_minByOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).minByOrNull { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_minOf(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).minOf { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_minOfOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).minOfOrNull { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_seq_partition(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).partition { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_reduce(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).reduce { a, x -> if (f) return "R"; a + x }
        return "ok " + show(v)
    }

    fun t_seq_single(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).single { if (f) return "R"; it == 2 }
        return "ok " + show(v)
    }
}

object Returns2 {
    fun t_seq_singleOrNull(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).singleOrNull { if (f) return "R"; it > 1 }
        return "ok " + show(v)
    }

    fun t_seq_sumOf(f: Boolean): Any? {
        val v = sequenceOf(1, 2, 3).sumOf { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_range_zipWithNext(f: Boolean): Any? {
        val v = (1..3).zipWithNext { a, b -> if (f) return "R"; a + b }
        return "ok " + show(v)
    }

    fun t_text_trim(f: Boolean): Any? {
        val v = "abc".trim { if (f) return "R"; true }
        return "ok " + show(v)
    }

    fun t_text_maxOf(f: Boolean): Any? {
        val v = "abc".maxOf { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_text_partition(f: Boolean): Any? {
        val v = "abc".partition { if (f) return "R"; true }
        return "ok " + show(v)
    }

    fun t_text_trimEnd(f: Boolean): Any? {
        val v = "abc".trimEnd { if (f) return "R"; true }
        return "ok " + show(v)
    }

    fun t_text_trimStart(f: Boolean): Any? {
        val v = "abc".trimStart { if (f) return "R"; true }
        return "ok " + show(v)
    }

    fun t_text_zipWithNext(f: Boolean): Any? {
        val v = "abc".zipWithNext { a, b -> if (f) return "R"; a }
        return "ok " + show(v)
    }

    fun t_Array_ctor(f: Boolean): Any? {
        val v = Array(3) { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_IntArray_ctor(f: Boolean): Any? {
        val v = IntArray(3) { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_List_ctor(f: Boolean): Any? {
        val v = List(3) { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_MutableList_ctor(f: Boolean): Any? {
        val v = MutableList(3) { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_result_mapCatching(f: Boolean): Any? {
        val v = Result.success(1).mapCatching { if (f) return "R"; it }
        return "ok " + show(v)
    }

    fun t_result_recoverCatching(f: Boolean): Any? {
        val v = Result.failure<Int>(Exception()).recoverCatching { if (f) return "R"; 0 }
        return "ok " + show(v)
    }
}

object Breaks1 {
    fun t_seq_any(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).any { if (f && k == 1) break; it > 1 }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_fold(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).fold(0) { a, x -> if (f && k == 1) break; a + x }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_forEachIndexed(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).forEachIndexed { _, _ -> if (f && k == 1) break }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_maxOf(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).maxOf { if (f && k == 1) break; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_partition(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).partition { if (f && k == 1) break; it > 1 }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_text_trim(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = "abc".trim { if (f && k == 1) break; true }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_text_zipWithNext(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = "abc".zipWithNext { a, b -> if (f && k == 1) break; a }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_List_ctor(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = List(3) { if (f && k == 1) break; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_IntArray_ctor(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = IntArray(3) { if (f && k == 1) break; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_result_mapCatching(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = Result.success(1).mapCatching { if (f && k == 1) break; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_result_recoverCatching(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = Result.failure<Int>(Exception()).recoverCatching { if (f && k == 1) break; 0 }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_sumOf(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).sumOf { if (f && k == 1) break; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }
}

object Continues1 {
    fun t_seq_any(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).any { if (f && k == 1) continue; it > 1 }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_fold(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).fold(0) { a, x -> if (f && k == 1) continue; a + x }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_forEachIndexed(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).forEachIndexed { _, _ -> if (f && k == 1) continue }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_maxOf(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).maxOf { if (f && k == 1) continue; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_partition(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).partition { if (f && k == 1) continue; it > 1 }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_text_trim(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = "abc".trim { if (f && k == 1) continue; true }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_text_zipWithNext(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = "abc".zipWithNext { a, b -> if (f && k == 1) continue; a }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_List_ctor(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = List(3) { if (f && k == 1) continue; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_IntArray_ctor(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = IntArray(3) { if (f && k == 1) continue; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_result_mapCatching(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = Result.success(1).mapCatching { if (f && k == 1) continue; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_result_recoverCatching(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = Result.failure<Int>(Exception()).recoverCatching { if (f && k == 1) continue; 0 }
            log += "$k:" + show(v) + ";"
        }
        return log
    }

    fun t_seq_sumOf(f: Boolean): Any? {
        var log = ""
        for (k in 0..2) {
            val v = sequenceOf(1, 2, 3).sumOf { if (f && k == 1) continue; it }
            log += "$k:" + show(v) + ";"
        }
        return log
    }
}

fun main() {
    println("Returns1 list_zipWithNext: " + Returns1.t_list_zipWithNext(false) + " / " + Returns1.t_list_zipWithNext(true))
    println("Returns1 seq_all: " + Returns1.t_seq_all(false) + " / " + Returns1.t_seq_all(true))
    println("Returns1 seq_any: " + Returns1.t_seq_any(false) + " / " + Returns1.t_seq_any(true))
    println("Returns1 seq_count: " + Returns1.t_seq_count(false) + " / " + Returns1.t_seq_count(true))
    println("Returns1 seq_find: " + Returns1.t_seq_find(false) + " / " + Returns1.t_seq_find(true))
    println("Returns1 seq_first: " + Returns1.t_seq_first(false) + " / " + Returns1.t_seq_first(true))
    println("Returns1 seq_firstOrNull: " + Returns1.t_seq_firstOrNull(false) + " / " + Returns1.t_seq_firstOrNull(true))
    println("Returns1 seq_forEachIndexed: " + Returns1.t_seq_forEachIndexed(false) + " / " + Returns1.t_seq_forEachIndexed(true))
    println("Returns1 seq_last: " + Returns1.t_seq_last(false) + " / " + Returns1.t_seq_last(true))
    println("Returns1 seq_lastOrNull: " + Returns1.t_seq_lastOrNull(false) + " / " + Returns1.t_seq_lastOrNull(true))
    println("Returns1 seq_none: " + Returns1.t_seq_none(false) + " / " + Returns1.t_seq_none(true))
    println("Returns1 seq_associateBy: " + Returns1.t_seq_associateBy(false) + " / " + Returns1.t_seq_associateBy(true))
    println("Returns1 seq_associate: " + Returns1.t_seq_associate(false) + " / " + Returns1.t_seq_associate(true))
    println("Returns1 seq_associateWith: " + Returns1.t_seq_associateWith(false) + " / " + Returns1.t_seq_associateWith(true))
    println("Returns1 seq_findLast: " + Returns1.t_seq_findLast(false) + " / " + Returns1.t_seq_findLast(true))
    println("Returns1 seq_fold: " + Returns1.t_seq_fold(false) + " / " + Returns1.t_seq_fold(true))
    println("Returns1 seq_foldIndexed: " + Returns1.t_seq_foldIndexed(false) + " / " + Returns1.t_seq_foldIndexed(true))
    println("Returns1 seq_groupBy: " + Returns1.t_seq_groupBy(false) + " / " + Returns1.t_seq_groupBy(true))
    println("Returns1 seq_indexOfFirst: " + Returns1.t_seq_indexOfFirst(false) + " / " + Returns1.t_seq_indexOfFirst(true))
    println("Returns1 seq_maxBy: " + Returns1.t_seq_maxBy(false) + " / " + Returns1.t_seq_maxBy(true))
    println("Returns1 seq_maxByOrNull: " + Returns1.t_seq_maxByOrNull(false) + " / " + Returns1.t_seq_maxByOrNull(true))
    println("Returns1 seq_maxOf: " + Returns1.t_seq_maxOf(false) + " / " + Returns1.t_seq_maxOf(true))
    println("Returns1 seq_maxOfOrNull: " + Returns1.t_seq_maxOfOrNull(false) + " / " + Returns1.t_seq_maxOfOrNull(true))
    println("Returns1 seq_minBy: " + Returns1.t_seq_minBy(false) + " / " + Returns1.t_seq_minBy(true))
    println("Returns1 seq_minByOrNull: " + Returns1.t_seq_minByOrNull(false) + " / " + Returns1.t_seq_minByOrNull(true))
    println("Returns1 seq_minOf: " + Returns1.t_seq_minOf(false) + " / " + Returns1.t_seq_minOf(true))
    println("Returns1 seq_minOfOrNull: " + Returns1.t_seq_minOfOrNull(false) + " / " + Returns1.t_seq_minOfOrNull(true))
    println("Returns1 seq_partition: " + Returns1.t_seq_partition(false) + " / " + Returns1.t_seq_partition(true))
    println("Returns1 seq_reduce: " + Returns1.t_seq_reduce(false) + " / " + Returns1.t_seq_reduce(true))
    println("Returns1 seq_single: " + Returns1.t_seq_single(false) + " / " + Returns1.t_seq_single(true))
    println("Returns2 seq_singleOrNull: " + Returns2.t_seq_singleOrNull(false) + " / " + Returns2.t_seq_singleOrNull(true))
    println("Returns2 seq_sumOf: " + Returns2.t_seq_sumOf(false) + " / " + Returns2.t_seq_sumOf(true))
    println("Returns2 range_zipWithNext: " + Returns2.t_range_zipWithNext(false) + " / " + Returns2.t_range_zipWithNext(true))
    println("Returns2 text_trim: " + Returns2.t_text_trim(false) + " / " + Returns2.t_text_trim(true))
    println("Returns2 text_maxOf: " + Returns2.t_text_maxOf(false) + " / " + Returns2.t_text_maxOf(true))
    println("Returns2 text_partition: " + Returns2.t_text_partition(false) + " / " + Returns2.t_text_partition(true))
    println("Returns2 text_trimEnd: " + Returns2.t_text_trimEnd(false) + " / " + Returns2.t_text_trimEnd(true))
    println("Returns2 text_trimStart: " + Returns2.t_text_trimStart(false) + " / " + Returns2.t_text_trimStart(true))
    println("Returns2 text_zipWithNext: " + Returns2.t_text_zipWithNext(false) + " / " + Returns2.t_text_zipWithNext(true))
    println("Returns2 Array_ctor: " + Returns2.t_Array_ctor(false) + " / " + Returns2.t_Array_ctor(true))
    println("Returns2 IntArray_ctor: " + Returns2.t_IntArray_ctor(false) + " / " + Returns2.t_IntArray_ctor(true))
    println("Returns2 List_ctor: " + Returns2.t_List_ctor(false) + " / " + Returns2.t_List_ctor(true))
    println("Returns2 MutableList_ctor: " + Returns2.t_MutableList_ctor(false) + " / " + Returns2.t_MutableList_ctor(true))
    println("Returns2 result_mapCatching: " + Returns2.t_result_mapCatching(false) + " / " + Returns2.t_result_mapCatching(true))
    println("Returns2 result_recoverCatching: " + Returns2.t_result_recoverCatching(false) + " / " + Returns2.t_result_recoverCatching(true))
    println("Breaks1 seq_any: " + Breaks1.t_seq_any(false) + " / " + Breaks1.t_seq_any(true))
    println("Breaks1 seq_fold: " + Breaks1.t_seq_fold(false) + " / " + Breaks1.t_seq_fold(true))
    println("Breaks1 seq_forEachIndexed: " + Breaks1.t_seq_forEachIndexed(false) + " / " + Breaks1.t_seq_forEachIndexed(true))
    println("Breaks1 seq_maxOf: " + Breaks1.t_seq_maxOf(false) + " / " + Breaks1.t_seq_maxOf(true))
    println("Breaks1 seq_partition: " + Breaks1.t_seq_partition(false) + " / " + Breaks1.t_seq_partition(true))
    println("Breaks1 text_trim: " + Breaks1.t_text_trim(false) + " / " + Breaks1.t_text_trim(true))
    println("Breaks1 text_zipWithNext: " + Breaks1.t_text_zipWithNext(false) + " / " + Breaks1.t_text_zipWithNext(true))
    println("Breaks1 List_ctor: " + Breaks1.t_List_ctor(false) + " / " + Breaks1.t_List_ctor(true))
    println("Breaks1 IntArray_ctor: " + Breaks1.t_IntArray_ctor(false) + " / " + Breaks1.t_IntArray_ctor(true))
    println("Breaks1 result_mapCatching: " + Breaks1.t_result_mapCatching(false) + " / " + Breaks1.t_result_mapCatching(true))
    println("Breaks1 result_recoverCatching: " + Breaks1.t_result_recoverCatching(false) + " / " + Breaks1.t_result_recoverCatching(true))
    println("Breaks1 seq_sumOf: " + Breaks1.t_seq_sumOf(false) + " / " + Breaks1.t_seq_sumOf(true))
    println("Continues1 seq_any: " + Continues1.t_seq_any(false) + " / " + Continues1.t_seq_any(true))
    println("Continues1 seq_fold: " + Continues1.t_seq_fold(false) + " / " + Continues1.t_seq_fold(true))
    println("Continues1 seq_forEachIndexed: " + Continues1.t_seq_forEachIndexed(false) + " / " + Continues1.t_seq_forEachIndexed(true))
    println("Continues1 seq_maxOf: " + Continues1.t_seq_maxOf(false) + " / " + Continues1.t_seq_maxOf(true))
    println("Continues1 seq_partition: " + Continues1.t_seq_partition(false) + " / " + Continues1.t_seq_partition(true))
    println("Continues1 text_trim: " + Continues1.t_text_trim(false) + " / " + Continues1.t_text_trim(true))
    println("Continues1 text_zipWithNext: " + Continues1.t_text_zipWithNext(false) + " / " + Continues1.t_text_zipWithNext(true))
    println("Continues1 List_ctor: " + Continues1.t_List_ctor(false) + " / " + Continues1.t_List_ctor(true))
    println("Continues1 IntArray_ctor: " + Continues1.t_IntArray_ctor(false) + " / " + Continues1.t_IntArray_ctor(true))
    println("Continues1 result_mapCatching: " + Continues1.t_result_mapCatching(false) + " / " + Continues1.t_result_mapCatching(true))
    println("Continues1 result_recoverCatching: " + Continues1.t_result_recoverCatching(false) + " / " + Continues1.t_result_recoverCatching(true))
    println("Continues1 seq_sumOf: " + Continues1.t_seq_sumOf(false) + " / " + Continues1.t_seq_sumOf(true))
}
