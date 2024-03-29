
local views = {
    dofile(views_path .. "VisualSettings.lua"),
    dofile(views_path .. "VarWatchSettings.lua"),
    dofile(views_path .. "MemorySettings.lua"),
}

return {
    name = "Settings",
    draw = function()
        Settings.settings_tab_index = ugui.carrousel_button({
            uid = 100,
            rectangle = grid_rect(0, 14, 8, 1),
            items = lualinq.select_key(views, "name"),
            selected_index = Settings.settings_tab_index,
        })

        views[Settings.settings_tab_index].draw()

    end
}
