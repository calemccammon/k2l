-- requires: Locale, Strings
-- String.format(locale, ...): what java.util.Formatter takes from a Locale is its DecimalFormatSymbols and number pattern: the
-- decimal separator, the grouping separator and size (for the `,` flag) and the zero digit (the digits, and the padding of the
-- `0` flag). The minus sign, NaN and Infinity are never localized, and `%S` upper-cases by the locale's rules. The table
-- (compiler/tools/GenLocale.java) lists the locales whose symbols differ from their parent's: language_COUNTRY_variant_#Script,
-- then the script or variant dropped, the language alone, and Locale.ROOT, as the JDK looks them up.
local __K2L_LocaleFormat = {}

do
    local F = __K2L_LocaleFormat
    local L = __K2L_Locale
    local UTF8_CHAR = "[%z\1-\127\194-\244][\128-\191]*"

    -- one "tag=" and then the decimal separator, the grouping separator, the zero digit and the group size (0: none) per line
    local data = {
        -- BEGIN GENERATED
        symbols = [==[
=.,03
af=, 03
agq=, 03
ar=٫٬٠3
ar_AE=.,03
ar_DZ=,.03
ar_EH=.,03
ar_LY=,.03
ar_MA=,.03
ar_TN=,.03
as=.,০3
ast=,.03
az=,.03
bas=, 03
be=, 03
bg=, 03
bgc=.,०3
bho=.,०3
bn=.,০3
br=, 03
bs=,.03
ca=,.03
ckb=٫٬٠3
cs=, 03
cv=, 03
da=,.03
de=,.03
de_AT=, 03
de_CH=.’03
de_LI=.’03
dje=. 03
dsb=,.03
dua=, 03
dyo=, 03
dz=.,༠3
el=,.03
en_AT=,.03
en_BE=,.03
en_CH=.’03
en_DE=,.03
en_DK=,.03
en_FI=, 03
en_NL=,.03
en_SE=, 03
en_SI=,.03
en_US_POSIX=.,00
en_ZA=, 03
eo=, 03
es=,.03
es_419=.,03
es_BR=.,03
es_BZ=.,03
es_CR=, 03
es_CU=.,03
es_DO=.,03
es_GT=.,03
es_HN=.,03
es_MX=.,03
es_NI=.,03
es_PA=.,03
es_PE=.,03
es_PR=.,03
es_SV=.,03
es_US=.,03
et=, 03
eu=,.03
ewo=, 03
fa=٫٬۰3
ff=, 03
ff__#Adlm=.⹁03
fi=, 03
fo=,.03
fr=, 03
fr_CA=, 03
fr_LU=,.03
fr_MA=,.03
fur=,.03
fy=,.03
gl=,.03
gsw=.’03
hr=,.03
hsb=,.03
hu=, 03
hy=, 03
ia=,.03
id=,.03
is=,.03
it=,.03
it_CH=.’03
jgo=,.03
jv=,.03
ka=, 03
kab=, 03
kea=, 03
kgp=,.03
khq=. 03
kk=, 03
kkj=,.03
kl=,.03
km=,.03
ks=٫٬۰3
ks__#Deva=.,03
ksf=, 03
ksh=, 03
ku=,.03
ky=, 03
lb=,.03
ln=,.03
lo=,.03
lrc=٫٬۰3
lt=, 03
lu=,.03
lv=, 03
mfe=. 03
mgh=,.03
mk=,.03
mni=.,০3
mr=.,०3
ms_BN=,.03
ms_ID=,.03
mua=,.03
my=.,၀3
mzn=٫٬۰3
nb=, 03
ne=.,०3
nl=,.03
nmg=, 03
nn=, 03
nnh=,.03
no=, 03
os=, 03
pa__#Arab=٫٬۰3
pl=, 03
ps=٫٬۰3
pt=,.03
pt_AO=, 03
pt_CH=, 03
pt_CV=, 03
pt_FR=, 03
pt_GQ=, 03
pt_GW=, 03
pt_LU=, 03
pt_MO=, 03
pt_MZ=, 03
pt_PT=, 03
pt_ST=, 03
pt_TL=, 03
qu_BO=,.03
raj=.,०3
rm=.’03
rn=,.03
ro=,.03
ru=, 03
rw=,.03
sa=.,०3
sah=, 03
sat=.,᱐3
sc=,.03
sd=٫٬٠3
sd__#Deva=.,03
se=, 03
seh=,.03
ses=. 03
sg=,.03
shi=, 03
sk=, 03
sl=,.03
smn=, 03
sq=, 03
sr=,.03
su=,.03
sv=, 03
sw_CD=,.03
tg=, 03
th_TH_TH=.,๐3
tk=, 03
tr=,.03
tt=, 03
twq=. 03
tzm=, 03
uk=, 03
ur_IN=٫٬۰3
uz=, 03
uz__#Arab=٫٬۰3
vi=,.03
wae=,’03
wo=,.03
xh=. 03
yav=, 03
yrl=,.03
zgh=, 03
]==],
        -- END GENERATED
    }

    local function codePoint(char)
        local b1, b2, b3 = char:byte(1, 3)
        if b1 < 0x80 then
            return b1
        elseif b1 < 0xE0 then
            return (b1 - 0xC0) * 64 + (b2 - 0x80)
        end
        return (b1 - 0xE0) * 4096 + (b2 - 0x80) * 64 + (b3 - 0x80)
    end

    -- the UTF-8 form of a BMP code point
    local function utf8Char(cp)
        if cp < 0x80 then
            return string.char(cp)
        elseif cp < 0x800 then
            return string.char(0xC0 + math.floor(cp / 64), 0x80 + cp % 64)
        end
        return string.char(0xE0 + math.floor(cp / 4096), 0x80 + math.floor(cp / 64) % 64, 0x80 + cp % 64)
    end

    local entries
    local cache = {}

    local function entry(tag)
        if entries == nil then
            entries = {}
            local pattern = "([^=\n]*)=(" .. UTF8_CHAR .. ")(" .. UTF8_CHAR .. ")(" .. UTF8_CHAR .. ")(%d+)\n"
            for key, decimal, group, zero, size in data.symbols:gmatch(pattern) do
                entries[key] = {decimal = decimal, group = group, zero = codePoint(zero), size = tonumber(size)}
            end
        end
        return entries[tag]
    end

    -- the tags a locale falls back to, nearest first: without the variant, without the script, the language alone, the root
    local function parents(tag)
        local language, country, script = L.language(tag), L.country(tag), tag:match("_#(%a+)$") or ""
        local variant = L.variant(tag)
        local out = {}
        if variant ~= "" then
            out[#out + 1] = L.of(language, country, "", script)
        end
        if script ~= "" then
            out[#out + 1] = L.of(language, country, "", "")
            if country ~= "" then
                out[#out + 1] = L.of(language, "", "", script)
            end
        end
        if language ~= "" and (country ~= "" or variant ~= "" or script ~= "") then
            out[#out + 1] = language
        end
        out[#out + 1] = ""
        return out
    end

    local function resolve(tag)
        local found = entry(tag)
        if found ~= nil then
            return found
        end
        for _, parent in ipairs(parents(tag)) do
            found = entry(parent)
            if found ~= nil then
                return found
            end
        end
        return entry("")
    end

    -- the symbols of a locale, or nil when they are ASCII and the usual ones (the formatter's own fast path)
    function F.symbols(tag)
        local cached = cache[tag]
        if cached == nil then
            local found = resolve(tag)
            cached = false
            if found.decimal ~= "." or found.group ~= "," or found.zero ~= 48 or found.size ~= 3 then
                cached = {decimal = found.decimal, group = found.group, size = found.size, digits = {}}
                for i = 1, 10 do
                    cached.digits[i] = utf8Char(found.zero + i - 1)
                end
            end
            cache[tag] = cached
        end
        return cached or nil
    end

    -- String.format(locale, format, args...); `upper` is the locale-aware upper-casing of --strings utf16, or nil
    function F.format(tag, upper, format, ...)
        tag = tag or "en_US"
        local mapUpper
        if upper ~= nil then
            mapUpper = function(s) return upper(s, tag) end
        end
        return __K2L_Text.formatWith(F.symbols(tag), mapUpper, format, ...)
    end
end
