local function main()
    for i = 1, 3 do
        io.write(i .. " ")
    end
    print()
    for i = 0, 2 do
        io.write(i .. " ")
    end
    print()
    for i = 0, 2 do
        io.write(i .. " ")
    end
    print()
    for i = 5, 1, -1 do
        io.write(i .. " ")
    end
    print()
    for i = 0, 10, 4 do
        io.write(i .. " ")
    end
    print()
    for i = 10, 0, -5 do
        io.write(i .. " ")
    end
    print()
    local n = 4
    for i = 1, n * 2 do
        io.write(i .. " ")
    end
    print()
    local i = 0
    while i < 5 do
        do
            i = i + 1
            if i == 2 then
                goto ____continue
            end
            if i == 4 then
                break
            end
            io.write("w" .. i .. " ")
        end
        ::____continue::
    end
    print()
    local j = 10
    repeat
        j = j - 3
        io.write("d" .. j .. " ")
    until not (j > 0)
    print()
    for a = 1, 3 do
        do
            for b = 1, 3 do
                if b == 2 then
                    goto ____continue_1
                end
                if a == 3 then
                    goto ____break
                end
                io.write("(" .. a .. "," .. b .. ") ")
            end
        end
        ::____continue_1::
    end
    ::____break::
    print()
    local sum = 0
    for k = 1, 100 do
        do
            if math.fmod(k, 2) == 0 then
                goto ____continue_2
            end
            sum = sum + k
        end
        ::____continue_2::
    end
    print(sum)
end

main()
