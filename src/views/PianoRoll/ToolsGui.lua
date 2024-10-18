local UID = dofile(views_path .. "PianoRoll/UID.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

return {
    Render = function()
        local top = 9.5

        if ugui.button({
            uid = UID.TrimEnd,
            rectangle = grid_rect(0, top, 1, 0.5),
            text = "Trim",
        }) then
            PianoRollContext.current:trimEnd()
        end

        if ugui.button({
            uid = UID.Reset,
            rectangle = grid_rect(1, top, 1, 0.5),
            text = "Reset",
        }) then
            PianoRollContext.current = PianoRoll.new()
        end
    end,
}