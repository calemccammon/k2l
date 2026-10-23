-- Hand-written Lua that runs between the Kotlin files and calls their globals.
print(format_hp(7))
print(clamp(-3, 0, 9))
print(Square.new(3.0):area())
print(getGreeting())
print(Registry:count())
