return {
    name = "Experiments",
    update = function()
    end,
    draw = function()
        local one_frame_preview = Mupen_lua_ugui.toggle_button({
            uid = 0,
            is_enabled = true,
            rectangle = grid_rect(0, 0, 4, 1),
            text = "1-frame preview",
            is_checked = Settings.one_frame_preview
        })

        if not Settings.one_frame_preview and one_frame_preview then
            Settings.one_frame_preview_counter = 1
            savestate.savefile("oneframepreview.st")
        end

        Settings.one_frame_preview = one_frame_preview
    end
}
