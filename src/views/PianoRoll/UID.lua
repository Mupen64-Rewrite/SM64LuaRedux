local enumerator = 1000
local function EnumNext(count)
    local current = enumerator
    enumerator = enumerator + (count or 1)
    return current
end

return {
    PianoRollName = EnumNext(),
    AddPianoRoll = EnumNext(),
    SelectPianoRoll = EnumNext(8), -- up to 7 simultaneuos piano rolls, plus one for "none"
    UIDCOUNT = EnumNext(),
}