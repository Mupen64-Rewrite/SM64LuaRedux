OneFramePreview = {}

OneFramePreview.update = function()
    if not Settings.one_frame_preview then
        return
    end
    Settings.one_frame_preview_counter = Settings.one_frame_preview_counter - 1
    if Settings.one_frame_preview_counter < 0 then
        savestate.loadfile("oneframepreview.st")
    end
    emu.pause(true)
end
