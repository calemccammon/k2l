-- A tiny audio module used from Kotlin as an external object.
local Audio = { played = 0, last_sound = nil }

local muted = false

function Audio.play(sound, volume)
    if muted then return false end
    Audio.played = Audio.played + 1
    Audio.last_sound = sound .. "@" .. string.format("%.1f", volume)
    return true
end

function Audio.set_muted(m)
    muted = m
end

return Audio
