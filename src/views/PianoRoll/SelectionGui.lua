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

        if PianoRollContext.current ~= nil then
            if (ugui.button({
                uid = UID.SavePianoRoll,

                rectangle = grid_rect(0, 13.5, 1.5, 0.5),
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

                rectangle = grid_rect(1.5, 13.5, 1.5, 0.5),
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