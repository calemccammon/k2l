package phys.trip

import phys.units.Kilograms
import phys.units.Meters
import phys.units.Seconds
import phys.units.Speed
import phys.units.average
import phys.units.div
import phys.units.km
import phys.units.total

enum class Mode(val maxSpeed: Speed, val emissionsPerKm: Double) {
    WALK(Speed(1.5), 0.0),
    BIKE(Speed(6.0), 0.0),
    BUS(Speed(14.0), 0.08),
    CAR(Speed(30.0), 0.17) {
        override fun describe() = "car (${maxSpeed})"
    },
    ;

    open fun describe() = name.lowercase()
}

data class Leg(val mode: Mode, val distance: Meters, val duration: Seconds) {
    val speed: Speed get() = distance / duration
    val co2: Kilograms get() = Kilograms(mode.emissionsPerKm * distance.km)

    init {
        require(distance.si > 0) { "a leg must have a positive distance" }
    }
}

class SpeedingException(val leg: Leg) : IllegalStateException("${leg.mode} too fast: ${leg.speed} > ${leg.mode.maxSpeed}")

class Trip(val name: String) {
    private val legs = mutableListOf<Leg>()

    fun leg(mode: Mode, distance: Meters, duration: Seconds) = apply {
        val l = Leg(mode, distance, duration)
        if (l.speed > mode.maxSpeed) throw SpeedingException(l)
        legs += l
    }

    val distance get() = legs.map { it.distance }.total(Meters(0.0))
    val duration get() = legs.map { it.duration }.total(Seconds(0.0))
    val co2 get() = legs.map { it.co2 }.total(Kilograms(0.0))
    val averageSpeed get() = distance / duration

    fun byMode(): Map<Mode, Meters> = legs.groupBy { it.mode }.mapValues { (_, ls) -> ls.map { it.distance }.total(Meters(0.0)) }

    fun fastest(): Leg? = legs.maxByOrNull { it.speed }

    fun averageLeg(): Meters = legs.map { it.distance }.average(Meters(0.0))

    fun summary() = buildList {
        add("$name: ${legs.size} legs, ${distance.km} km in $duration (avg $averageSpeed), co2 $co2")
        for ((i, l) in legs.withIndex()) add("  ${i + 1}. ${l.mode.describe()} ${l.distance} in ${l.duration} at ${l.speed}")
    }
}

fun commute(): Trip = Trip("commute")
    .leg(Mode.WALK, Meters(800.0), Seconds(600.0))
    .leg(Mode.BUS, 7.5.km, Seconds(1500.0))
    .leg(Mode.WALK, Meters(350.0), Seconds(300.0))
