return {
    name = "Ghost",
    update = function()
    end,
    draw = function()
        if Mupen_lua_ugui.button({
                uid = 5,
                is_enabled = true,
                rectangle = grid_rect(0, 0, 4, 1),
                text = Settings.recording_ghost and "Stop Recording" or "Start Recording",
            }) then
            Ghost.toggle_recording()
        end
    end
}
