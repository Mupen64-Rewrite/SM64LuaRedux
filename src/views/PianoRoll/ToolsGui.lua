local UID = dofile(views_path .. "PianoRoll/UID.lua")

return {
    Render = function()

        local controlHeight = 0.75
        local top = 9

        if ugui.button({
            uid = UID.TrimEnd,
            rectangle = grid_rect(0, top, 1.5, controlHeight),
            text = "Trim",
        }) then
            PianoRollContext.current:trimEnd()
        end

        PianoRollContext.copyEntireState = ugui.toggle_button({
            uid = UID.CopyEntireState,
            rectangle = grid_rect(4.5, top, 3.5, controlHeight),
            text = "Copy entire state",
            is_checked = PianoRollContext.copyEntireState,
        })

        if PianoRollContext.current ~= nil then
            if (ugui.button({
                uid = UID.SavePianoRoll,

                rectangle = grid_rect(1.5, top, 1.5, controlHeight),
                is_enabled = true,
                text = 'Save'
            })) then
                ugui.end_frame()
                local filePath = iohelper.filediag("*.pianoroll", 1)
                if filePath ~= "" then
                    PianoRollContext.current:save(filePath)
                end
            end

            if (ugui.button({
                uid = UID.LoadPianoRoll,

                rectangle = grid_rect(3, top, 1.5, controlHeight),
                is_enabled = true,
                text = 'Load'
            })) then
                ugui.end_frame()
                local filePath = iohelper.filediag("*.pianoroll", 0)
                if filePath ~= "" then
                    PianoRollContext.current:load(filePath)
                end
            end
        end
    end,
}