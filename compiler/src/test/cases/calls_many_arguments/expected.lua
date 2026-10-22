local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Unpack = ____lualib.__K2L_Unpack

local function count(...)
    local xs = __K2L_ArrayOf(...)
    return xs.size
end

local function total(...)
    local xs = __K2L_ArrayOf(...)
    return xs:sum()
end

local Sink = __K2L_Class("Sink")

local ____lambda_1 = function(it) return __K2L_Text.takeLast(it, 1) end
function Sink:join(...)
    local words = __K2L_ArrayOf(...)
    return words:joinToString("", nil, nil, nil, nil, ____lambda_1)
end

local function manyLocals()
    local v0 = 0
    local v1 = 1
    local v2 = 2
    local v3 = 3
    local v4 = 4
    local v5 = 5
    local v6 = 6
    local v7 = 7
    local v8 = 8
    local v9 = 9
    local v10 = 10
    local v11 = 11
    local v12 = 12
    local v13 = 13
    local v14 = 14
    local v15 = 15
    local v16 = 16
    local v17 = 17
    local v18 = 18
    local v19 = 19
    local v20 = 20
    local v21 = 21
    local v22 = 22
    local v23 = 23
    local v24 = 24
    local v25 = 25
    local v26 = 26
    local v27 = 27
    local v28 = 28
    local v29 = 29
    local v30 = 30
    local v31 = 31
    local v32 = 32
    local v33 = 33
    local v34 = 34
    local v35 = 35
    local v36 = 36
    local v37 = 37
    local v38 = 38
    local v39 = 39
    local v40 = 40
    local v41 = 41
    local v42 = 42
    local v43 = 43
    local v44 = 44
    local v45 = 45
    local v46 = 46
    local v47 = 47
    local v48 = 48
    local v49 = 49
    local v50 = 50
    local v51 = 51
    local v52 = 52
    local v53 = 53
    local v54 = 54
    local v55 = 55
    local v56 = 56
    local v57 = 57
    local v58 = 58
    local v59 = 59
    local v60 = 60
    local v61 = 61
    local v62 = 62
    local v63 = 63
    local v64 = 64
    local v65 = 65
    local v66 = 66
    local v67 = 67
    local v68 = 68
    local v69 = 69
    local v70 = 70
    local v71 = 71
    local v72 = 72
    local v73 = 73
    local v74 = 74
    local v75 = 75
    local v76 = 76
    local v77 = 77
    local v78 = 78
    local v79 = 79
    local v80 = 80
    local v81 = 81
    local v82 = 82
    local v83 = 83
    local v84 = 84
    local v85 = 85
    local v86 = 86
    local v87 = 87
    local v88 = 88
    local v89 = 89
    local v90 = 90
    local v91 = 91
    local v92 = 92
    local v93 = 93
    local v94 = 94
    local v95 = 95
    local v96 = 96
    local v97 = 97
    local v98 = 98
    local v99 = 99
    local v100 = 100
    local v101 = 101
    local v102 = 102
    local v103 = 103
    local v104 = 104
    local v105 = 105
    local v106 = 106
    local v107 = 107
    local v108 = 108
    local v109 = 109
    local v110 = 110
    local v111 = 111
    local v112 = 112
    local v113 = 113
    local v114 = 114
    local v115 = 115
    local v116 = 116
    local v117 = 117
    local v118 = 118
    local v119 = 119
    local v120 = 120
    local v121 = 121
    local v122 = 122
    local v123 = 123
    local v124 = 124
    local v125 = 125
    local v126 = 126
    local v127 = 127
    local v128 = 128
    local v129 = 129
    local v130 = 130
    local v131 = 131
    local v132 = 132
    local v133 = 133
    local v134 = 134
    local v135 = 135
    local v136 = 136
    local v137 = 137
    local v138 = 138
    local v139 = 139
    local v140 = 140
    local v141 = 141
    local v142 = 142
    local v143 = 143
    local v144 = 144
    local v145 = 145
    local v146 = 146
    local v147 = 147
    local v148 = 148
    local v149 = 149
    local sum = v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20 + v21 + v22 + v23 + v24 + v25 + v26 + v27 + v28 + v29 + v30 + v31 + v32 + v33 + v34 + v35 + v36 + v37 + v38 + v39 + v40 + v41 + v42 + v43 + v44 + v45 + v46 + v47 + v48 + v49 + v50 + v51 + v52 + v53 + v54 + v55 + v56 + v57 + v58 + v59 + v60 + v61 + v62 + v63 + v64 + v65 + v66 + v67 + v68 + v69 + v70 + v71 + v72 + v73 + v74 + v75 + v76 + v77 + v78 + v79 + v80 + v81 + v82 + v83 + v84 + v85 + v86 + v87 + v88 + v89 + v90 + v91 + v92 + v93 + v94 + v95 + v96 + v97 + v98 + v99 + v100 + v101 + v102 + v103 + v104 + v105 + v106 + v107 + v108 + v109 + v110 + v111 + v112 + v113 + v114 + v115 + v116 + v117 + v118 + v119 + v120 + v121 + v122 + v123 + v124 + v125 + v126 + v127 + v128 + v129 + v130 + v131 + v132 + v133 + v134 + v135 + v136 + v137 + v138 + v139 + v140 + v141 + v142 + v143 + v144 + v145 + v146 + v147 + v148 + v149
    return sum + count((table.unpack or unpack)({v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, v101, v102, v103, v104, v105, v106, v107, v108, v109, v110, v111, v112, v113, v114, v115, v116, v117, v118, v119, v120, v121, v122, v123, v124, v125, v126, v127, v128, v129, v130, v131, v132, v133, v134, v135, v136, v137, v138, v139, v140, v141, v142, v143, v144, v145, v146, v147, v148, v149}, 1, 150))
end

local ____lambda_2 = function(it) return it end
local function main()
    local data = __K2L_ListOf((table.unpack or unpack)({__K2L_Pair.new("k0", 0), __K2L_Pair.new("k1", 1), __K2L_Pair.new("k2", 2), __K2L_Pair.new("k3", 3), __K2L_Pair.new("k4", 4), __K2L_Pair.new("k5", 5), __K2L_Pair.new("k6", 6), __K2L_Pair.new("k7", 7), __K2L_Pair.new("k8", 8), __K2L_Pair.new("k9", 9), __K2L_Pair.new("k10", 10), __K2L_Pair.new("k11", 11), __K2L_Pair.new("k12", 12), __K2L_Pair.new("k13", 13), __K2L_Pair.new("k14", 14), __K2L_Pair.new("k15", 15), __K2L_Pair.new("k16", 16), __K2L_Pair.new("k17", 17), __K2L_Pair.new("k18", 18), __K2L_Pair.new("k19", 19), __K2L_Pair.new("k20", 20), __K2L_Pair.new("k21", 21), __K2L_Pair.new("k22", 22), __K2L_Pair.new("k23", 23), __K2L_Pair.new("k24", 24), __K2L_Pair.new("k25", 25), __K2L_Pair.new("k26", 26), __K2L_Pair.new("k27", 27), __K2L_Pair.new("k28", 28), __K2L_Pair.new("k29", 29), __K2L_Pair.new("k30", 30), __K2L_Pair.new("k31", 31), __K2L_Pair.new("k32", 32), __K2L_Pair.new("k33", 33), __K2L_Pair.new("k34", 34), __K2L_Pair.new("k35", 35), __K2L_Pair.new("k36", 36), __K2L_Pair.new("k37", 37), __K2L_Pair.new("k38", 38), __K2L_Pair.new("k39", 39), __K2L_Pair.new("k40", 40), __K2L_Pair.new("k41", 41), __K2L_Pair.new("k42", 42), __K2L_Pair.new("k43", 43), __K2L_Pair.new("k44", 44), __K2L_Pair.new("k45", 45), __K2L_Pair.new("k46", 46), __K2L_Pair.new("k47", 47), __K2L_Pair.new("k48", 48), __K2L_Pair.new("k49", 49), __K2L_Pair.new("k50", 50), __K2L_Pair.new("k51", 51), __K2L_Pair.new("k52", 52), __K2L_Pair.new("k53", 53), __K2L_Pair.new("k54", 54), __K2L_Pair.new("k55", 55), __K2L_Pair.new("k56", 56), __K2L_Pair.new("k57", 57), __K2L_Pair.new("k58", 58), __K2L_Pair.new("k59", 59), __K2L_Pair.new("k60", 60), __K2L_Pair.new("k61", 61), __K2L_Pair.new("k62", 62), __K2L_Pair.new("k63", 63), __K2L_Pair.new("k64", 64), __K2L_Pair.new("k65", 65), __K2L_Pair.new("k66", 66), __K2L_Pair.new("k67", 67), __K2L_Pair.new("k68", 68), __K2L_Pair.new("k69", 69), __K2L_Pair.new("k70", 70), __K2L_Pair.new("k71", 71), __K2L_Pair.new("k72", 72), __K2L_Pair.new("k73", 73), __K2L_Pair.new("k74", 74), __K2L_Pair.new("k75", 75), __K2L_Pair.new("k76", 76), __K2L_Pair.new("k77", 77), __K2L_Pair.new("k78", 78), __K2L_Pair.new("k79", 79), __K2L_Pair.new("k80", 80), __K2L_Pair.new("k81", 81), __K2L_Pair.new("k82", 82), __K2L_Pair.new("k83", 83), __K2L_Pair.new("k84", 84), __K2L_Pair.new("k85", 85), __K2L_Pair.new("k86", 86), __K2L_Pair.new("k87", 87), __K2L_Pair.new("k88", 88), __K2L_Pair.new("k89", 89), __K2L_Pair.new("k90", 90), __K2L_Pair.new("k91", 91), __K2L_Pair.new("k92", 92), __K2L_Pair.new("k93", 93), __K2L_Pair.new("k94", 94), __K2L_Pair.new("k95", 95), __K2L_Pair.new("k96", 96), __K2L_Pair.new("k97", 97), __K2L_Pair.new("k98", 98), __K2L_Pair.new("k99", 99), __K2L_Pair.new("k100", 100), __K2L_Pair.new("k101", 101), __K2L_Pair.new("k102", 102), __K2L_Pair.new("k103", 103), __K2L_Pair.new("k104", 104), __K2L_Pair.new("k105", 105), __K2L_Pair.new("k106", 106), __K2L_Pair.new("k107", 107), __K2L_Pair.new("k108", 108), __K2L_Pair.new("k109", 109), __K2L_Pair.new("k110", 110), __K2L_Pair.new("k111", 111), __K2L_Pair.new("k112", 112), __K2L_Pair.new("k113", 113), __K2L_Pair.new("k114", 114), __K2L_Pair.new("k115", 115), __K2L_Pair.new("k116", 116), __K2L_Pair.new("k117", 117), __K2L_Pair.new("k118", 118), __K2L_Pair.new("k119", 119), __K2L_Pair.new("k120", 120), __K2L_Pair.new("k121", 121), __K2L_Pair.new("k122", 122), __K2L_Pair.new("k123", 123), __K2L_Pair.new("k124", 124), __K2L_Pair.new("k125", 125), __K2L_Pair.new("k126", 126), __K2L_Pair.new("k127", 127), __K2L_Pair.new("k128", 128), __K2L_Pair.new("k129", 129), __K2L_Pair.new("k130", 130), __K2L_Pair.new("k131", 131), __K2L_Pair.new("k132", 132), __K2L_Pair.new("k133", 133), __K2L_Pair.new("k134", 134), __K2L_Pair.new("k135", 135), __K2L_Pair.new("k136", 136), __K2L_Pair.new("k137", 137), __K2L_Pair.new("k138", 138), __K2L_Pair.new("k139", 139), __K2L_Pair.new("k140", 140), __K2L_Pair.new("k141", 141), __K2L_Pair.new("k142", 142), __K2L_Pair.new("k143", 143), __K2L_Pair.new("k144", 144), __K2L_Pair.new("k145", 145), __K2L_Pair.new("k146", 146), __K2L_Pair.new("k147", 147), __K2L_Pair.new("k148", 148), __K2L_Pair.new("k149", 149), __K2L_Pair.new("k150", 150), __K2L_Pair.new("k151", 151), __K2L_Pair.new("k152", 152), __K2L_Pair.new("k153", 153), __K2L_Pair.new("k154", 154), __K2L_Pair.new("k155", 155), __K2L_Pair.new("k156", 156), __K2L_Pair.new("k157", 157), __K2L_Pair.new("k158", 158), __K2L_Pair.new("k159", 159), __K2L_Pair.new("k160", 160), __K2L_Pair.new("k161", 161), __K2L_Pair.new("k162", 162), __K2L_Pair.new("k163", 163), __K2L_Pair.new("k164", 164), __K2L_Pair.new("k165", 165), __K2L_Pair.new("k166", 166), __K2L_Pair.new("k167", 167), __K2L_Pair.new("k168", 168), __K2L_Pair.new("k169", 169), __K2L_Pair.new("k170", 170), __K2L_Pair.new("k171", 171), __K2L_Pair.new("k172", 172), __K2L_Pair.new("k173", 173), __K2L_Pair.new("k174", 174), __K2L_Pair.new("k175", 175), __K2L_Pair.new("k176", 176), __K2L_Pair.new("k177", 177), __K2L_Pair.new("k178", 178), __K2L_Pair.new("k179", 179), __K2L_Pair.new("k180", 180), __K2L_Pair.new("k181", 181), __K2L_Pair.new("k182", 182), __K2L_Pair.new("k183", 183), __K2L_Pair.new("k184", 184), __K2L_Pair.new("k185", 185), __K2L_Pair.new("k186", 186), __K2L_Pair.new("k187", 187), __K2L_Pair.new("k188", 188), __K2L_Pair.new("k189", 189), __K2L_Pair.new("k190", 190), __K2L_Pair.new("k191", 191), __K2L_Pair.new("k192", 192), __K2L_Pair.new("k193", 193), __K2L_Pair.new("k194", 194), __K2L_Pair.new("k195", 195), __K2L_Pair.new("k196", 196), __K2L_Pair.new("k197", 197), __K2L_Pair.new("k198", 198), __K2L_Pair.new("k199", 199), __K2L_Pair.new("k200", 200), __K2L_Pair.new("k201", 201), __K2L_Pair.new("k202", 202), __K2L_Pair.new("k203", 203), __K2L_Pair.new("k204", 204), __K2L_Pair.new("k205", 205), __K2L_Pair.new("k206", 206), __K2L_Pair.new("k207", 207), __K2L_Pair.new("k208", 208), __K2L_Pair.new("k209", 209), __K2L_Pair.new("k210", 210), __K2L_Pair.new("k211", 211), __K2L_Pair.new("k212", 212), __K2L_Pair.new("k213", 213), __K2L_Pair.new("k214", 214), __K2L_Pair.new("k215", 215), __K2L_Pair.new("k216", 216), __K2L_Pair.new("k217", 217), __K2L_Pair.new("k218", 218), __K2L_Pair.new("k219", 219), __K2L_Pair.new("k220", 220), __K2L_Pair.new("k221", 221), __K2L_Pair.new("k222", 222), __K2L_Pair.new("k223", 223), __K2L_Pair.new("k224", 224), __K2L_Pair.new("k225", 225), __K2L_Pair.new("k226", 226), __K2L_Pair.new("k227", 227), __K2L_Pair.new("k228", 228), __K2L_Pair.new("k229", 229), __K2L_Pair.new("k230", 230), __K2L_Pair.new("k231", 231), __K2L_Pair.new("k232", 232), __K2L_Pair.new("k233", 233), __K2L_Pair.new("k234", 234), __K2L_Pair.new("k235", 235), __K2L_Pair.new("k236", 236), __K2L_Pair.new("k237", 237), __K2L_Pair.new("k238", 238), __K2L_Pair.new("k239", 239), __K2L_Pair.new("k240", 240), __K2L_Pair.new("k241", 241), __K2L_Pair.new("k242", 242), __K2L_Pair.new("k243", 243), __K2L_Pair.new("k244", 244), __K2L_Pair.new("k245", 245), __K2L_Pair.new("k246", 246), __K2L_Pair.new("k247", 247), __K2L_Pair.new("k248", 248), __K2L_Pair.new("k249", 249), __K2L_Pair.new("k250", 250), __K2L_Pair.new("k251", 251), __K2L_Pair.new("k252", 252), __K2L_Pair.new("k253", 253), __K2L_Pair.new("k254", 254), __K2L_Pair.new("k255", 255), __K2L_Pair.new("k256", 256), __K2L_Pair.new("k257", 257), __K2L_Pair.new("k258", 258), __K2L_Pair.new("k259", 259), __K2L_Pair.new("k260", 260), __K2L_Pair.new("k261", 261), __K2L_Pair.new("k262", 262), __K2L_Pair.new("k263", 263), __K2L_Pair.new("k264", 264), __K2L_Pair.new("k265", 265), __K2L_Pair.new("k266", 266), __K2L_Pair.new("k267", 267), __K2L_Pair.new("k268", 268), __K2L_Pair.new("k269", 269), __K2L_Pair.new("k270", 270), __K2L_Pair.new("k271", 271), __K2L_Pair.new("k272", 272), __K2L_Pair.new("k273", 273), __K2L_Pair.new("k274", 274), __K2L_Pair.new("k275", 275), __K2L_Pair.new("k276", 276), __K2L_Pair.new("k277", 277), __K2L_Pair.new("k278", 278), __K2L_Pair.new("k279", 279), __K2L_Pair.new("k280", 280), __K2L_Pair.new("k281", 281), __K2L_Pair.new("k282", 282), __K2L_Pair.new("k283", 283), __K2L_Pair.new("k284", 284), __K2L_Pair.new("k285", 285), __K2L_Pair.new("k286", 286), __K2L_Pair.new("k287", 287), __K2L_Pair.new("k288", 288), __K2L_Pair.new("k289", 289), __K2L_Pair.new("k290", 290), __K2L_Pair.new("k291", 291), __K2L_Pair.new("k292", 292), __K2L_Pair.new("k293", 293), __K2L_Pair.new("k294", 294), __K2L_Pair.new("k295", 295), __K2L_Pair.new("k296", 296), __K2L_Pair.new("k297", 297), __K2L_Pair.new("k298", 298), __K2L_Pair.new("k299", 299)}, 1, 300))
    print(data.size)
    print(__K2L_Str(data:first()))
    print(__K2L_Str(data:last()))
    local ____sum = 0
    local ____items, ____n = data:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____sum = ____sum + it.second
    end
    print(____sum)
    local map = __K2L_MapOf((table.unpack or unpack)({__K2L_Pair.new("k0", 0), __K2L_Pair.new("k1", 1), __K2L_Pair.new("k2", 2), __K2L_Pair.new("k3", 3), __K2L_Pair.new("k4", 4), __K2L_Pair.new("k5", 5), __K2L_Pair.new("k6", 6), __K2L_Pair.new("k7", 7), __K2L_Pair.new("k8", 8), __K2L_Pair.new("k9", 9), __K2L_Pair.new("k10", 10), __K2L_Pair.new("k11", 11), __K2L_Pair.new("k12", 12), __K2L_Pair.new("k13", 13), __K2L_Pair.new("k14", 14), __K2L_Pair.new("k15", 15), __K2L_Pair.new("k16", 16), __K2L_Pair.new("k17", 17), __K2L_Pair.new("k18", 18), __K2L_Pair.new("k19", 19), __K2L_Pair.new("k20", 20), __K2L_Pair.new("k21", 21), __K2L_Pair.new("k22", 22), __K2L_Pair.new("k23", 23), __K2L_Pair.new("k24", 24), __K2L_Pair.new("k25", 25), __K2L_Pair.new("k26", 26), __K2L_Pair.new("k27", 27), __K2L_Pair.new("k28", 28), __K2L_Pair.new("k29", 29), __K2L_Pair.new("k30", 30), __K2L_Pair.new("k31", 31), __K2L_Pair.new("k32", 32), __K2L_Pair.new("k33", 33), __K2L_Pair.new("k34", 34), __K2L_Pair.new("k35", 35), __K2L_Pair.new("k36", 36), __K2L_Pair.new("k37", 37), __K2L_Pair.new("k38", 38), __K2L_Pair.new("k39", 39), __K2L_Pair.new("k40", 40), __K2L_Pair.new("k41", 41), __K2L_Pair.new("k42", 42), __K2L_Pair.new("k43", 43), __K2L_Pair.new("k44", 44), __K2L_Pair.new("k45", 45), __K2L_Pair.new("k46", 46), __K2L_Pair.new("k47", 47), __K2L_Pair.new("k48", 48), __K2L_Pair.new("k49", 49), __K2L_Pair.new("k50", 50), __K2L_Pair.new("k51", 51), __K2L_Pair.new("k52", 52), __K2L_Pair.new("k53", 53), __K2L_Pair.new("k54", 54), __K2L_Pair.new("k55", 55), __K2L_Pair.new("k56", 56), __K2L_Pair.new("k57", 57), __K2L_Pair.new("k58", 58), __K2L_Pair.new("k59", 59), __K2L_Pair.new("k60", 60), __K2L_Pair.new("k61", 61), __K2L_Pair.new("k62", 62), __K2L_Pair.new("k63", 63), __K2L_Pair.new("k64", 64), __K2L_Pair.new("k65", 65), __K2L_Pair.new("k66", 66), __K2L_Pair.new("k67", 67), __K2L_Pair.new("k68", 68), __K2L_Pair.new("k69", 69), __K2L_Pair.new("k70", 70), __K2L_Pair.new("k71", 71), __K2L_Pair.new("k72", 72), __K2L_Pair.new("k73", 73), __K2L_Pair.new("k74", 74), __K2L_Pair.new("k75", 75), __K2L_Pair.new("k76", 76), __K2L_Pair.new("k77", 77), __K2L_Pair.new("k78", 78), __K2L_Pair.new("k79", 79), __K2L_Pair.new("k80", 80), __K2L_Pair.new("k81", 81), __K2L_Pair.new("k82", 82), __K2L_Pair.new("k83", 83), __K2L_Pair.new("k84", 84), __K2L_Pair.new("k85", 85), __K2L_Pair.new("k86", 86), __K2L_Pair.new("k87", 87), __K2L_Pair.new("k88", 88), __K2L_Pair.new("k89", 89), __K2L_Pair.new("k90", 90), __K2L_Pair.new("k91", 91), __K2L_Pair.new("k92", 92), __K2L_Pair.new("k93", 93), __K2L_Pair.new("k94", 94), __K2L_Pair.new("k95", 95), __K2L_Pair.new("k96", 96), __K2L_Pair.new("k97", 97), __K2L_Pair.new("k98", 98), __K2L_Pair.new("k99", 99), __K2L_Pair.new("k100", 100), __K2L_Pair.new("k101", 101), __K2L_Pair.new("k102", 102), __K2L_Pair.new("k103", 103), __K2L_Pair.new("k104", 104), __K2L_Pair.new("k105", 105), __K2L_Pair.new("k106", 106), __K2L_Pair.new("k107", 107), __K2L_Pair.new("k108", 108), __K2L_Pair.new("k109", 109), __K2L_Pair.new("k110", 110), __K2L_Pair.new("k111", 111), __K2L_Pair.new("k112", 112), __K2L_Pair.new("k113", 113), __K2L_Pair.new("k114", 114), __K2L_Pair.new("k115", 115), __K2L_Pair.new("k116", 116), __K2L_Pair.new("k117", 117), __K2L_Pair.new("k118", 118), __K2L_Pair.new("k119", 119), __K2L_Pair.new("k120", 120), __K2L_Pair.new("k121", 121), __K2L_Pair.new("k122", 122), __K2L_Pair.new("k123", 123), __K2L_Pair.new("k124", 124), __K2L_Pair.new("k125", 125), __K2L_Pair.new("k126", 126), __K2L_Pair.new("k127", 127), __K2L_Pair.new("k128", 128), __K2L_Pair.new("k129", 129), __K2L_Pair.new("k130", 130), __K2L_Pair.new("k131", 131), __K2L_Pair.new("k132", 132), __K2L_Pair.new("k133", 133), __K2L_Pair.new("k134", 134), __K2L_Pair.new("k135", 135), __K2L_Pair.new("k136", 136), __K2L_Pair.new("k137", 137), __K2L_Pair.new("k138", 138), __K2L_Pair.new("k139", 139), __K2L_Pair.new("k140", 140), __K2L_Pair.new("k141", 141), __K2L_Pair.new("k142", 142), __K2L_Pair.new("k143", 143), __K2L_Pair.new("k144", 144), __K2L_Pair.new("k145", 145), __K2L_Pair.new("k146", 146), __K2L_Pair.new("k147", 147), __K2L_Pair.new("k148", 148), __K2L_Pair.new("k149", 149), __K2L_Pair.new("k150", 150), __K2L_Pair.new("k151", 151), __K2L_Pair.new("k152", 152), __K2L_Pair.new("k153", 153), __K2L_Pair.new("k154", 154), __K2L_Pair.new("k155", 155), __K2L_Pair.new("k156", 156), __K2L_Pair.new("k157", 157), __K2L_Pair.new("k158", 158), __K2L_Pair.new("k159", 159), __K2L_Pair.new("k160", 160), __K2L_Pair.new("k161", 161), __K2L_Pair.new("k162", 162), __K2L_Pair.new("k163", 163), __K2L_Pair.new("k164", 164), __K2L_Pair.new("k165", 165), __K2L_Pair.new("k166", 166), __K2L_Pair.new("k167", 167), __K2L_Pair.new("k168", 168), __K2L_Pair.new("k169", 169), __K2L_Pair.new("k170", 170), __K2L_Pair.new("k171", 171), __K2L_Pair.new("k172", 172), __K2L_Pair.new("k173", 173), __K2L_Pair.new("k174", 174), __K2L_Pair.new("k175", 175), __K2L_Pair.new("k176", 176), __K2L_Pair.new("k177", 177), __K2L_Pair.new("k178", 178), __K2L_Pair.new("k179", 179), __K2L_Pair.new("k180", 180), __K2L_Pair.new("k181", 181), __K2L_Pair.new("k182", 182), __K2L_Pair.new("k183", 183), __K2L_Pair.new("k184", 184), __K2L_Pair.new("k185", 185), __K2L_Pair.new("k186", 186), __K2L_Pair.new("k187", 187), __K2L_Pair.new("k188", 188), __K2L_Pair.new("k189", 189), __K2L_Pair.new("k190", 190), __K2L_Pair.new("k191", 191), __K2L_Pair.new("k192", 192), __K2L_Pair.new("k193", 193), __K2L_Pair.new("k194", 194), __K2L_Pair.new("k195", 195), __K2L_Pair.new("k196", 196), __K2L_Pair.new("k197", 197), __K2L_Pair.new("k198", 198), __K2L_Pair.new("k199", 199), __K2L_Pair.new("k200", 200), __K2L_Pair.new("k201", 201), __K2L_Pair.new("k202", 202), __K2L_Pair.new("k203", 203), __K2L_Pair.new("k204", 204), __K2L_Pair.new("k205", 205), __K2L_Pair.new("k206", 206), __K2L_Pair.new("k207", 207), __K2L_Pair.new("k208", 208), __K2L_Pair.new("k209", 209), __K2L_Pair.new("k210", 210), __K2L_Pair.new("k211", 211), __K2L_Pair.new("k212", 212), __K2L_Pair.new("k213", 213), __K2L_Pair.new("k214", 214), __K2L_Pair.new("k215", 215), __K2L_Pair.new("k216", 216), __K2L_Pair.new("k217", 217), __K2L_Pair.new("k218", 218), __K2L_Pair.new("k219", 219), __K2L_Pair.new("k220", 220), __K2L_Pair.new("k221", 221), __K2L_Pair.new("k222", 222), __K2L_Pair.new("k223", 223), __K2L_Pair.new("k224", 224), __K2L_Pair.new("k225", 225), __K2L_Pair.new("k226", 226), __K2L_Pair.new("k227", 227), __K2L_Pair.new("k228", 228), __K2L_Pair.new("k229", 229), __K2L_Pair.new("k230", 230), __K2L_Pair.new("k231", 231), __K2L_Pair.new("k232", 232), __K2L_Pair.new("k233", 233), __K2L_Pair.new("k234", 234), __K2L_Pair.new("k235", 235), __K2L_Pair.new("k236", 236), __K2L_Pair.new("k237", 237), __K2L_Pair.new("k238", 238), __K2L_Pair.new("k239", 239), __K2L_Pair.new("k240", 240), __K2L_Pair.new("k241", 241), __K2L_Pair.new("k242", 242), __K2L_Pair.new("k243", 243), __K2L_Pair.new("k244", 244), __K2L_Pair.new("k245", 245), __K2L_Pair.new("k246", 246), __K2L_Pair.new("k247", 247), __K2L_Pair.new("k248", 248), __K2L_Pair.new("k249", 249), __K2L_Pair.new("k250", 250), __K2L_Pair.new("k251", 251), __K2L_Pair.new("k252", 252), __K2L_Pair.new("k253", 253), __K2L_Pair.new("k254", 254), __K2L_Pair.new("k255", 255), __K2L_Pair.new("k256", 256), __K2L_Pair.new("k257", 257), __K2L_Pair.new("k258", 258), __K2L_Pair.new("k259", 259), __K2L_Pair.new("k260", 260), __K2L_Pair.new("k261", 261), __K2L_Pair.new("k262", 262), __K2L_Pair.new("k263", 263), __K2L_Pair.new("k264", 264), __K2L_Pair.new("k265", 265), __K2L_Pair.new("k266", 266), __K2L_Pair.new("k267", 267), __K2L_Pair.new("k268", 268), __K2L_Pair.new("k269", 269), __K2L_Pair.new("k270", 270), __K2L_Pair.new("k271", 271), __K2L_Pair.new("k272", 272), __K2L_Pair.new("k273", 273), __K2L_Pair.new("k274", 274), __K2L_Pair.new("k275", 275), __K2L_Pair.new("k276", 276), __K2L_Pair.new("k277", 277), __K2L_Pair.new("k278", 278), __K2L_Pair.new("k279", 279), __K2L_Pair.new("k280", 280), __K2L_Pair.new("k281", 281), __K2L_Pair.new("k282", 282), __K2L_Pair.new("k283", 283), __K2L_Pair.new("k284", 284), __K2L_Pair.new("k285", 285), __K2L_Pair.new("k286", 286), __K2L_Pair.new("k287", 287), __K2L_Pair.new("k288", 288), __K2L_Pair.new("k289", 289), __K2L_Pair.new("k290", 290), __K2L_Pair.new("k291", 291), __K2L_Pair.new("k292", 292), __K2L_Pair.new("k293", 293), __K2L_Pair.new("k294", 294), __K2L_Pair.new("k295", 295), __K2L_Pair.new("k296", 296), __K2L_Pair.new("k297", 297), __K2L_Pair.new("k298", 298), __K2L_Pair.new("k299", 299)}, 1, 300))
    print(__K2L_Str(map:get("k299")))
    print(count((table.unpack or unpack)({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259}, 1, 260)))
    print(total((table.unpack or unpack)({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259}, 1, 260)))
    local withNulls = __K2L_ListOf((table.unpack or unpack)({nil, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, nil, nil}, 1, 105))
    print(withNulls.size)
    local ____result = 0
    local ____items_1, ____n_1 = withNulls:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it == nil then
            ____result = ____result + 1
        end
    end
    print(____result)
    print(__K2L_Str(withNulls:takeLast(3)))
    print(Sink.new():join((table.unpack or unpack)({"w0", "w1", "w2", "w3", "w4", "w5", "w6", "w7", "w8", "w9", "w10", "w11", "w12", "w13", "w14", "w15", "w16", "w17", "w18", "w19", "w20", "w21", "w22", "w23", "w24", "w25", "w26", "w27", "w28", "w29", "w30", "w31", "w32", "w33", "w34", "w35", "w36", "w37", "w38", "w39", "w40", "w41", "w42", "w43", "w44", "w45", "w46", "w47", "w48", "w49", "w50", "w51", "w52", "w53", "w54", "w55", "w56", "w57", "w58", "w59", "w60", "w61", "w62", "w63", "w64", "w65", "w66", "w67", "w68", "w69", "w70", "w71", "w72", "w73", "w74", "w75", "w76", "w77", "w78", "w79", "w80", "w81", "w82", "w83", "w84", "w85", "w86", "w87", "w88", "w89", "w90", "w91", "w92", "w93", "w94", "w95", "w96", "w97", "w98", "w99", "w100", "w101", "w102", "w103", "w104", "w105", "w106", "w107", "w108", "w109", "w110", "w111", "w112", "w113", "w114", "w115", "w116", "w117", "w118", "w119"}, 1, 120)))
    print(__K2L_ArrayOf((table.unpack or unpack)({"w0", "w1", "w2", "w3", "w4", "w5", "w6", "w7", "w8", "w9", "w10", "w11", "w12", "w13", "w14", "w15", "w16", "w17", "w18", "w19", "w20", "w21", "w22", "w23", "w24", "w25", "w26", "w27", "w28", "w29", "w30", "w31", "w32", "w33", "w34", "w35", "w36", "w37", "w38", "w39", "w40", "w41", "w42", "w43", "w44", "w45", "w46", "w47", "w48", "w49", "w50", "w51", "w52", "w53", "w54", "w55", "w56", "w57", "w58", "w59", "w60", "w61", "w62", "w63", "w64", "w65", "w66", "w67", "w68", "w69", "w70", "w71", "w72", "w73", "w74", "w75", "w76", "w77", "w78", "w79", "w80", "w81", "w82", "w83", "w84", "w85", "w86", "w87", "w88", "w89", "w90", "w91", "w92", "w93", "w94", "w95", "w96", "w97", "w98", "w99", "w100", "w101", "w102", "w103", "w104", "w105", "w106", "w107", "w108", "w109", "w110", "w111", "w112", "w113", "w114", "w115", "w116", "w117", "w118", "w119"}, 1, 120)).size)
    local spread = __K2L_ListOfSize(200, ____lambda_2, true)
    print(count(__K2L_Unpack(spread)))
    print(count(1, 2, __K2L_Unpack(spread)))
    print(manyLocals())
end

__K2L_RunMain(main)
return {count = count, total = total, Sink = Sink, manyLocals = manyLocals}
