local UID = dofile(views_path .. "PianoRoll/UID.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

return {
    Render = function()
        local top = 9

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
            PianoRollContext.current = PianoRoll.new(PianoRollContext.current.name)
        end

        if PianoRollContext.current ~= nil then
            if (ugui.button({
                uid = UID.SavePianoRoll,

                rectangle = grid_rect(2, top, 1, 0.5),
                is_enabled = true,
                text = 'Save'
            })) then
                ugui.end_frame()
                local filePath = iohelper.filediag("*.pianoroll", 1)
                if filePath ~= "" then
                    persistence.store(filePath,
                        {
                            frames      = PianoRollContext.current.frames,
                            name        = PianoRollContext.current.name,
                            startGT     = PianoRollContext.current.startGT,
                            endGT       = PianoRollContext.current.endGT,
                            editingGT   = PianoRollContext.current.editingGT,
                            previewGT   = PianoRollContext.current.previewGT,
                        }
                    )
                end
            end

            if (ugui.button({
                uid = UID.LoadPianoRoll,

                rectangle = grid_rect(3, top, 1, 0.5),
                is_enabled = true,
                text = 'Load'
            })) then
                ugui.end_frame()
                local filePath = iohelper.filediag("*.pianoroll", 0)
                local contents = persistence.load(filePath);
                if contents ~= nil then
                    CloneInto(PianoRollContext.current, contents)
                    PianoRollContext.current:jumpTo(PianoRollContext.current.previewGT)
                end
            end
        end
    end,
}