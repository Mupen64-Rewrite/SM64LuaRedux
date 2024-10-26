local UID = dofile(views_path .. "PianoRoll/UID.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

local selectionIndex = 1

return {
    Render = function()
        -- TODO: the "Reset" button should probably become a "Delete" button now,
        --       so that the "Off" option doesn't get drowned in abandoned "sheets"

        local the_correct_y_position = 14.5

        local availablePianoRolls = {}
        for i = 1, #PianoRollContext.all, 1 do
            availablePianoRolls[i] = PianoRollContext.all[i].name
        end
        availablePianoRolls[#availablePianoRolls + 1] = "Off"

        local nextPianoRoll = ugui.carrousel_button(
            {
                uid = UID.SelectionSpinner,

                rectangle = grid_rect(5, the_correct_y_position, 2, 0.5),
                items = availablePianoRolls,
                selected_index = selectionIndex,
                is_enabled = #availablePianoRolls > 1
            }
        )
        if ugui.button({
            uid = UID.AddPianoRoll,

            rectangle = grid_rect(7, the_correct_y_position, 1, 0.5),
            text = "+",
        }) then
            nextPianoRoll = #PianoRollContext.all + 1
            PianoRollContext.current = PianoRoll.new("Sheet " .. nextPianoRoll)
            PianoRollContext.all[nextPianoRoll] = PianoRollContext.current
        end

        if selectionIndex ~= nextPianoRoll then
            selectionIndex = nextPianoRoll
            PianoRollContext.current = PianoRollContext.all[selectionIndex]
            if PianoRollContext.current ~= nil then
                PianoRollContext.current:jumpTo(PianoRollContext.current.previewGT)
            end
        end
    end,
}