local UID = dofile(views_path .. "PianoRoll/UID.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

return {
    Render = function()
        for i = 1, #PianoRollContext.all, 1 do
            if (ugui.button({
                uid = UID.SelectPianoRoll + i - 1,

                rectangle = grid_rect(i - 1, 14, 1, 1),
                is_enabled = true,
                text = tostring(i)
            })) then
                PianoRollContext.current = PianoRollContext.all[i]
            end
        end
        if (#PianoRollContext.all < 8 and ugui.button({
            uid = UID.AddPianoRoll,

            rectangle = grid_rect(#PianoRollContext.all, 14, 1, 1),
            is_enabled = true,
            text = '+'
        })) then
            PianoRollContext.current = PianoRoll.new(GetGlobalTimer())
            PianoRollContext.all[#PianoRollContext.all + 1] = PianoRollContext.current
        end
    end,
}