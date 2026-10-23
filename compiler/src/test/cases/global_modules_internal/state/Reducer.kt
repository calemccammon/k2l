package state

// Loaded before Store.lua: its functions read the module table only when they are called.
internal fun reduce(state: State, effect: Effect): State = when (effect) {
    is Effect.Say -> State(state.count, state.log + effect.text)
    Effect.Beep -> state + 1
}

internal fun effects(): List<Effect> = listOf(Effect.Say("hi"), Effect.Beep)
