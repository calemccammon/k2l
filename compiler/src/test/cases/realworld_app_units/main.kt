package phys

import phys.trip.Mode
import phys.trip.SpeedingException
import phys.trip.Trip
import phys.trip.commute
import phys.units.Kilograms
import phys.units.Meters
import phys.units.Quantity
import phys.units.Seconds
import phys.units.Speed
import phys.units.average
import phys.units.div
import phys.units.h
import phys.units.kg
import phys.units.km
import phys.units.m
import phys.units.max
import phys.units.min
import phys.units.s
import phys.units.times
import phys.units.total

// A trip planner on a small type-safe units library: value classes, operator overloads and generic quantities.

fun <Q : Quantity<Q>> describe(label: String, values: List<Q>, zero: Q) {
    val sorted = values.sorted()
    println("$label: $sorted, min ${sorted.first()}, max ${values.reduce { a, b -> max(a, b) }}, total ${values.total(zero)}")
}

fun main() {
    val d = 3.km + 250.m
    val t = 12.min + 30.s
    println("$d $t ${d / t} ${(d / t) * 2.h} ${2 * d} ${0.5 * d} ${-d} ${d / 250.m}")
    println("${d > 3.km} ${d == Meters(3250.0)} ${d.compareTo(4.km)} ${setOf(1.km, 1000.m, 2.km).size} ${t.hours}")
    println("${Speed(10.0)} ${Speed(10.0).kmh} ${Kilograms(2.25)} ${80.kg - 2.5.km.si.let { Kilograms(it / 1000) }}")

    describe("distances", listOf(5.km, 120.m, 2.5.km, 900.m), Meters(0.0))
    describe("times", listOf(1.h, 45.min, 90.s, 3.h + 5.min), Seconds(0.0))

    val trip = commute()
    trip.summary().forEach(::println)
    println("by mode: ${trip.byMode()}")
    println("fastest: ${trip.fastest()?.mode} at ${trip.fastest()?.speed}, average leg ${trip.averageLeg()}")

    val weekend = Trip("weekend")
        .leg(Mode.CAR, 42.km, 40.min)
        .leg(Mode.BIKE, 12.km, 50.min)
    weekend.summary().forEach(::println)
    try {
        Trip("reckless").leg(Mode.BIKE, 30.km, 20.min)
    } catch (e: SpeedingException) {
        println("rejected: ${e.message} (${e.leg.mode})")
    }
    try {
        Trip("empty").leg(Mode.WALK, 0.m, 1.min)
    } catch (e: IllegalArgumentException) {
        println("rejected: ${e.message}")
    }
    try {
        emptyList<Seconds>().average(Seconds(0.0))
    } catch (e: IllegalArgumentException) {
        println("rejected: ${e.message}")
    }
    val all = listOf(trip, weekend)
    println("total co2 ${all.map { it.co2 }.total(Kilograms(0.0))}, distance ${all.map { it.distance }.total(0.m)}")
    println(Mode.values().map { "${it.describe()}<=${it.maxSpeed}" })
    val q: Quantity<Meters> = 7.m
    val anyQ: Any = q
    println("${q.format(0)} ${q.symbol} ${anyQ is Quantity<*>} ${anyQ is Comparable<*>} ${anyQ is Meters} ${anyQ is Seconds}")
}
