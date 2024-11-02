local UID = dofile(views_path .. "PianoRoll/UID.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

local selectionIndex = 0
local createdSheetCount = 0

return {
    Render = function()

        local controlHeight = 0.75
        local top = 15 - controlHeight

        local availablePianoRolls = {}
        for i = 1, #PianoRollContext.all, 1 do
            availablePianoRolls[i] = PianoRollContext.all[i].name
        end
        availablePianoRolls[#availablePianoRolls + 1] = "Off"

        local nextPianoRoll = ugui.carrousel_button(
            {
                uid = UID.SelectionSpinner,

                rectangle = grid_rect(3, top, 4, controlHeight),
                items = availablePianoRolls,
                selected_index = selectionIndex,
                is_enabled = #availablePianoRolls > 1
            }
        )

        if (ugui.button({
            uid = UID.Delete,

            rectangle = grid_rect(2, top, 1, controlHeight),
            text = "-",
            is_enabled = PianoRollContext.all[nextPianoRoll] ~= nil,
        })) then
            table.remove(PianoRollContext.all, selectionIndex)
        end

        if ugui.button({
            uid = UID.AddPianoRoll,

            rectangle = grid_rect(7, top, 1, controlHeight),
            text = "+",
        }) then
            nextPianoRoll = #PianoRollContext.all + 1
            createdSheetCount = createdSheetCount + 1
            PianoRollContext.current = PianoRoll.new("Sheet " .. createdSheetCount)
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